<#
.SYNOPSIS
    Liest den IST-Zustand der vier SharePoint-Listen aus und gleicht ihn gegen
    03_Schema_Mapping.json ab.

.DESCRIPTION
    Dieses Skript aendert NICHTS. Es liest ausschliesslich Metadaten und
    schreibt einen Bericht.

    Es beantwortet genau die Fragen, die ohne Tenant-Zugriff offen bleiben
    mussten:
      - Wie heissen die Spalten wirklich (Anzeigename und interner Name)?
      - Welchen Typ haben sie?
      - Wohin zeigen "Patient" und "Rezept" - und sind sie Einfach- oder
        Mehrfachauswahl?
      - Wie heisst die Titelspalte im Rezept wirklich?

    Fuehren Sie dieses Skript aus, BEVOR Sie Ergaenze-Schema.ps1 starten und
    bevor Sie die Flows bauen.

.PARAMETER SiteUrl
    URL der SharePoint-Website mit den Listen.

.PARAMETER BerichtPfad
    Zieldatei fuer den Bericht. Standard: .\Schema-Bericht.md

.EXAMPLE
    .\Pruefe-Schema.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Praxis"

.NOTES
    Voraussetzung: PnP.PowerShell (Install-Module PnP.PowerShell -Scope CurrentUser)
    Leserechte auf den Listen genuegen.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SiteUrl,
    [string]$BerichtPfad = (Join-Path $PSScriptRoot 'Schema-Bericht.md'),
    [string]$ZuordnungPfad = (Join-Path $PSScriptRoot '..\03_Schema_Mapping.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell fehlt. Bitte ausfuehren: Install-Module PnP.PowerShell -Scope CurrentUser"
}
Import-Module PnP.PowerShell -ErrorAction Stop

if (-not (Test-Path $ZuordnungPfad)) {
    throw "Feldzuordnung nicht gefunden: $ZuordnungPfad"
}
$zuordnung = Get-Content $ZuordnungPfad -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "Verbinde mit $SiteUrl ..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteUrl -Interactive

$zeilen = [System.Collections.Generic.List[string]]::new()
$zeilen.Add("# Schemabericht (IST-Zustand)")
$zeilen.Add("")
$zeilen.Add("Erzeugt am $(Get-Date -Format 'yyyy-MM-dd HH:mm') aus ``$SiteUrl``.")
$zeilen.Add("")
$zeilen.Add("Dieser Bericht ist die belastbare Quelle. Wo er von 03_Datenmodell.md")
$zeilen.Add("abweicht, gilt der Bericht.")
$zeilen.Add("")

$abweichungen = [System.Collections.Generic.List[string]]::new()

foreach ($listenName in $zuordnung.listen.PSObject.Properties.Name) {

    Write-Host "Lese Liste '$listenName' ..." -ForegroundColor Cyan
    $liste = Get-PnPList -Identity $listenName -ErrorAction SilentlyContinue

    $zeilen.Add("## Liste: $listenName")
    $zeilen.Add("")

    if ($null -eq $liste) {
        $zeilen.Add("> **Diese Liste wurde nicht gefunden.** Bitte pruefen, ob der Name")
        $zeilen.Add("> abweicht. In der App muss die Datenquelle dann umbenannt werden.")
        $zeilen.Add("")
        $abweichungen.Add("Liste fehlt oder heisst anders: $listenName")
        continue
    }

    $zeilen.Add("Elemente: $($liste.ItemCount)")
    $zeilen.Add("")
    $zeilen.Add("| Anzeigename | Interner Name | Typ | Pflicht | Standardwert | Besonderheit |")
    $zeilen.Add("|---|---|---|---|---|---|")

    $felder = Get-PnPField -List $listenName | Where-Object { -not $_.Hidden }

    foreach ($feld in ($felder | Sort-Object Title)) {

        $besonderheit = @()

        # Lookup: Ziel-Liste und Einfach-/Mehrfachauswahl aufloesen (Befund 6).
        if ($feld.TypeAsString -like 'Lookup*') {
            try {
                $xml = [xml]$feld.SchemaXml
                $zielId = $xml.Field.List
                $mehrfach = $xml.Field.Mult -eq 'TRUE'
                $zielListe = $null
                if ($zielId) {
                    $zielListe = (Get-PnPList | Where-Object { "{$($_.Id)}" -eq $zielId -or $_.Id.ToString() -eq $zielId.Trim('{','}') }).Title
                }
                $besonderheit += "Ziel-Liste: $(if ($zielListe) { $zielListe } else { "unbekannt ($zielId)" })"
                $besonderheit += "$(if ($mehrfach) { 'MEHRFACHauswahl' } else { 'Einfachauswahl' })"
                $besonderheit += "Ziel-Feld: $($xml.Field.ShowField)"
            } catch {
                $besonderheit += "Lookup-Details nicht lesbar"
            }
        }

        if ($feld.TypeAsString -like 'Choice*' -or $feld.TypeAsString -like 'MultiChoice*') {
            try {
                $xml = [xml]$feld.SchemaXml
                $werte = @($xml.Field.CHOICES.CHOICE)
                $besonderheit += "Werte: $($werte -join ' / ')"
            } catch { }
        }

        if ($feld.TypeAsString -eq 'DateTime') {
            try {
                $xml = [xml]$feld.SchemaXml
                $besonderheit += "Anzeige: $($xml.Field.Format)"   # DateOnly oder DateTime
            } catch { }
        }

        if ($feld.Title -ne $feld.InternalName) {
            $besonderheit += "Anzeigename weicht vom internen Namen ab"
        }

        $standard = if ($feld.DefaultValue) { '`' + $feld.DefaultValue + '`' } else { '-' }

        $zeilen.Add(("| {0} | ``{1}`` | {2} | {3} | {4} | {5} |" -f `
            $feld.Title, $feld.InternalName, $feld.TypeAsString,
            $(if ($feld.Required) { 'ja' } else { 'nein' }),
            $standard,
            $(if ($besonderheit.Count) { $besonderheit -join '; ' } else { '-' })))
    }
    $zeilen.Add("")

    # --- Abgleich gegen die dokumentierte Zuordnung -------------------
    $vorhandeneAnzeige = @($felder | ForEach-Object { $_.Title })
    $vorhandeneIntern  = @($felder | ForEach-Object { $_.InternalName })

    foreach ($erwartet in $zuordnung.listen.$listenName) {
        if ($erwartet.status -eq 'system') { continue }

        $trefferAnzeige = $vorhandeneAnzeige -contains $erwartet.anzeigename
        $trefferIntern  = $vorhandeneIntern  -contains $erwartet.interner_name

        if (-not $trefferAnzeige -and -not $trefferIntern) {
            if ($erwartet.status -eq 'ergaenzung') {
                $abweichungen.Add("$listenName : '$($erwartet.anzeigename)' fehlt - wird von Ergaenze-Schema.ps1 angelegt.")
            } else {
                $abweichungen.Add("$listenName : '$($erwartet.anzeigename)' NICHT gefunden, war aber erwartet ($($erwartet.status)). Bitte pruefen.")
            }
        }
        elseif ($trefferAnzeige -and -not $trefferIntern) {
            $tatsaechlich = ($felder | Where-Object { $_.Title -eq $erwartet.anzeigename }).InternalName
            $abweichungen.Add("$listenName : '$($erwartet.anzeigename)' hat den internen Namen '$tatsaechlich', dokumentiert war '$($erwartet.interner_name)'. FLOWS ANPASSEN.")
        }
        elseif ($trefferIntern -and -not $trefferAnzeige) {
            $tatsaechlich = ($felder | Where-Object { $_.InternalName -eq $erwartet.interner_name }).Title
            $abweichungen.Add("$listenName : intern '$($erwartet.interner_name)' heisst angezeigt '$tatsaechlich', dokumentiert war '$($erwartet.anzeigename)'. POWER-FX-FORMELN ANPASSEN.")
        }
    }
}

$zeilen.Add("## Abweichungen gegenueber 03_Datenmodell.md")
$zeilen.Add("")
if ($abweichungen.Count -eq 0) {
    $zeilen.Add("Keine. Die dokumentierte Zuordnung deckt sich mit dem IST-Zustand.")
} else {
    foreach ($a in $abweichungen) { $zeilen.Add("- $a") }
}
$zeilen.Add("")
$zeilen.Add("## Was jetzt zu tun ist")
$zeilen.Add("")
$zeilen.Add("1. Jede Zeile oben abarbeiten, die 'FLOWS ANPASSEN' oder")
$zeilen.Add("   'POWER-FX-FORMELN ANPASSEN' enthaelt.")
$zeilen.Add("2. Danach ``Ergaenze-Schema.ps1 -WhatIf`` ausfuehren und die Vorschau pruefen.")
$zeilen.Add("3. Erst dann ``Ergaenze-Schema.ps1`` ohne ``-WhatIf`` ausfuehren.")

$zeilen -join "`r`n" | Set-Content -Path $BerichtPfad -Encoding UTF8

Write-Host ""
Write-Host "Bericht geschrieben: $BerichtPfad" -ForegroundColor Green
Write-Host "Abweichungen: $($abweichungen.Count)" -ForegroundColor $(if ($abweichungen.Count) { 'Yellow' } else { 'Green' })
Disconnect-PnPOnline
