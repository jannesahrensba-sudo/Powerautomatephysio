<#
.SYNOPSIS
    Legt die fehlenden Spalten, Auswahlwerte und Indizes an - wiederholt
    ausfuehrbar und ohne stille Aenderungen an Vorhandenem.

.DESCRIPTION
    Grundsaetze dieses Skripts:

      * ZUERST PRUEFEN. Jede Spalte wird vor dem Anlegen gesucht. Ist sie da,
        wird sie uebersprungen und nicht veraendert.
      * NICHTS LOESCHEN, NICHTS UMBENENNEN. Es werden ausschliesslich fehlende
        Dinge ergaenzt. Ein vorhandener Typ wird nie geaendert.
      * KEINE DATEN ANFASSEN. Das Skript schreibt keine Listenelemente, mit
        einer Ausnahme: die eine Einstellungszeile, falls sie fehlt - und auch
        die nur mit -EinstellungszeileAnlegen.
      * WIEDERHOLBAR. Ein zweiter Lauf aendert nichts mehr.

    Was dieses Skript BEWUSST NICHT tut:
      - Es korrigiert NICHT den Anzeigenamen der Doku-Spalte 'AltEinheiten'.
        Das ist ein eigener, bestaetigungspflichtiger Schritt. Siehe
        Pruefe-Bestandsdaten.ps1 und README.md.
      - Es verschiebt KEINE vorhandenen Zaehlerwerte von der Dokumentation an
        das Rezept. Auch das ist ein eigener Schritt mit vorheriger Pruefung.
      - Es entfernt NICHT den falschen Standardwert von 'MailGesendetam'.
        Dafuer gibt es den Schalter -StandardwertMailGesendetamEntfernen.

.PARAMETER SiteUrl
    URL der SharePoint-Website mit den Listen.

.PARAMETER WhatIf
    Zeigt nur an, was geschehen wuerde. Bitte immer zuerst so ausfuehren.

.PARAMETER EinstellungszeileAnlegen
    Legt die eine Einstellungszeile (Typart = "Einstellung") an, falls sie
    fehlt - mit den Standardwerten aus dem Auftrag. Versand bleibt AUS.

.PARAMETER StandardwertMailGesendetamEntfernen
    Entfernt den fehlerhaften heutigen Standardwert von 'MailGesendetam'
    (Befund 9). Vorhandene Werte in Zeilen bleiben unangetastet.

.EXAMPLE
    .\Ergaenze-Schema.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Praxis" -WhatIf
    .\Ergaenze-Schema.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Praxis"

.NOTES
    Voraussetzung: PnP.PowerShell. Es werden Rechte zum Aendern der Listen benoetigt.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$SiteUrl,
    [string]$ErgaenzungenPfad = (Join-Path $PSScriptRoot 'Schema-Ergaenzungen.json'),
    [switch]$EinstellungszeileAnlegen,
    [switch]$StandardwertMailGesendetamEntfernen
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell fehlt. Bitte ausfuehren: Install-Module PnP.PowerShell -Scope CurrentUser"
}
Import-Module PnP.PowerShell -ErrorAction Stop

if (-not (Test-Path $ErgaenzungenPfad)) { throw "Nicht gefunden: $ErgaenzungenPfad" }
$plan = Get-Content $ErgaenzungenPfad -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "Verbinde mit $SiteUrl ..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteUrl -Interactive

$angelegt = 0; $uebersprungen = 0; $probleme = [System.Collections.Generic.List[string]]::new()

function Test-ListeVorhanden {
    param([string]$Name)
    $l = Get-PnPList -Identity $Name -ErrorAction SilentlyContinue
    return $null -ne $l
}

# ---------------------------------------------------------------------
# 1. Fehlende Spalten anlegen
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Spalten ==" -ForegroundColor Cyan

foreach ($spalte in $plan.spalten) {

    if (-not (Test-ListeVorhanden -Name $spalte.liste)) {
        $probleme.Add("Liste '$($spalte.liste)' nicht gefunden - '$($spalte.anzeigename)' uebersprungen.")
        continue
    }

    # Sowohl ueber den internen Namen als auch ueber den Anzeigenamen suchen:
    # eine Spalte kann unter einem der beiden Namen bereits bestehen.
    $vorhandeneFelder = Get-PnPField -List $spalte.liste
    $treffer = $vorhandeneFelder | Where-Object {
        $_.InternalName -eq $spalte.interner_name -or $_.Title -eq $spalte.anzeigename
    } | Select-Object -First 1

    if ($treffer) {
        Write-Host ("  uebersprungen: {0}.{1} (vorhanden als '{2}', Typ {3})" -f `
            $spalte.liste, $spalte.anzeigename, $treffer.InternalName, $treffer.TypeAsString) -ForegroundColor DarkGray
        if ($treffer.TypeAsString -ne $spalte.typ) {
            $probleme.Add("$($spalte.liste).$($spalte.anzeigename): vorhandener Typ '$($treffer.TypeAsString)' weicht vom erwarteten '$($spalte.typ)' ab. NICHT automatisch geaendert - bitte fachlich pruefen.")
        }
        $uebersprungen++
        continue
    }

    $ziel = "$($spalte.liste).$($spalte.anzeigename) ($($spalte.typ))"
    if (-not $PSCmdlet.ShouldProcess($ziel, "Spalte anlegen")) { continue }

    try {
        $parameter = @{
            List         = $spalte.liste
            DisplayName  = $spalte.anzeigename
            InternalName = $spalte.interner_name
            Type         = $spalte.typ
            AddToDefaultView = $true
            ErrorAction  = 'Stop'
        }
        if ($spalte.typ -eq 'Choice') { $parameter['Choices'] = $spalte.auswahlwerte }

        $neu = Add-PnPField @parameter
        Write-Host ("  angelegt:      {0}.{1} [{2}]" -f $spalte.liste, $spalte.anzeigename, $spalte.typ) -ForegroundColor Green
        $angelegt++

        # Datumsspalten ohne Uhrzeit anzeigen, wo fachlich nur der Tag zaehlt.
        if ($spalte.typ -eq 'DateTime' -and $spalte.anzeige) {
            Set-PnPField -List $spalte.liste -Identity $spalte.interner_name `
                         -Values @{ DisplayFormat = $(if ($spalte.anzeige -eq 'DateOnly') { 0 } else { 1 }) } -ErrorAction Stop
        }
        if ($spalte.standardwert) {
            Set-PnPField -List $spalte.liste -Identity $spalte.interner_name `
                         -Values @{ DefaultValue = $spalte.standardwert } -ErrorAction Stop
        }
    }
    catch {
        $probleme.Add("$ziel konnte nicht angelegt werden: $($_.Exception.Message)")
        Write-Host ("  FEHLER:        {0} - {1}" -f $ziel, $_.Exception.Message) -ForegroundColor Red
    }
}

# ---------------------------------------------------------------------
# 2. Fehlende Auswahlwerte an vorhandenen Spalten ergaenzen
#    (Vorhandene Werte bleiben erhalten - es wird nur ergaenzt.)
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Auswahlwerte ==" -ForegroundColor Cyan

foreach ($eintrag in $plan.auswahlwerte_ergaenzen) {

    if (-not (Test-ListeVorhanden -Name $eintrag.liste)) {
        $probleme.Add("Liste '$($eintrag.liste)' nicht gefunden - Auswahlwerte '$($eintrag.interner_name)' uebersprungen.")
        continue
    }

    $feld = Get-PnPField -List $eintrag.liste -Identity $eintrag.interner_name -ErrorAction SilentlyContinue
    if (-not $feld) {
        $probleme.Add("$($eintrag.liste).$($eintrag.interner_name) nicht gefunden - Auswahlwerte nicht ergaenzt.")
        continue
    }
    if ($feld.TypeAsString -notlike 'Choice*' -and $feld.TypeAsString -notlike 'MultiChoice*') {
        $probleme.Add("$($eintrag.liste).$($eintrag.interner_name) ist kein Auswahlfeld (Typ $($feld.TypeAsString)) - nicht veraendert.")
        continue
    }

    $xml = [xml]$feld.SchemaXml
    $vorhanden = @($xml.Field.CHOICES.CHOICE)
    $fehlend = @($eintrag.werte | Where-Object { $vorhanden -notcontains $_ })

    if ($fehlend.Count -eq 0) {
        Write-Host ("  uebersprungen: {0}.{1} - alle Werte vorhanden" -f $eintrag.liste, $eintrag.interner_name) -ForegroundColor DarkGray
        $uebersprungen++
        continue
    }

    $ziel = "$($eintrag.liste).$($eintrag.interner_name): + $($fehlend -join ', ')"
    if (-not $PSCmdlet.ShouldProcess($ziel, "Auswahlwerte ergaenzen")) { continue }

    try {
        # Bestehende Werte werden bewusst vorangestellt und behalten ihre Reihenfolge.
        $alle = @($vorhanden) + @($fehlend)
        Set-PnPField -List $eintrag.liste -Identity $eintrag.interner_name `
                     -Values @{ Choices = $alle } -ErrorAction Stop
        Write-Host ("  ergaenzt:      {0}" -f $ziel) -ForegroundColor Green
        $angelegt++
    }
    catch {
        $probleme.Add("$ziel fehlgeschlagen: $($_.Exception.Message)")
    }
}

# ---------------------------------------------------------------------
# 3. Indizes - noetig, damit Flows nicht in die 5000er-Grenze laufen
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Indizes ==" -ForegroundColor Cyan

foreach ($idx in $plan.indizes) {
    if (-not (Test-ListeVorhanden -Name $idx.liste)) { continue }
    $feld = Get-PnPField -List $idx.liste -Identity $idx.interner_name -ErrorAction SilentlyContinue
    if (-not $feld) {
        $probleme.Add("Index: $($idx.liste).$($idx.interner_name) nicht gefunden.")
        continue
    }
    if ($feld.Indexed) {
        Write-Host ("  uebersprungen: {0}.{1} bereits indiziert" -f $idx.liste, $idx.interner_name) -ForegroundColor DarkGray
        $uebersprungen++
        continue
    }
    if (-not $PSCmdlet.ShouldProcess("$($idx.liste).$($idx.interner_name)", "Index anlegen")) { continue }
    try {
        Set-PnPField -List $idx.liste -Identity $idx.interner_name -Values @{ Indexed = $true } -ErrorAction Stop
        Write-Host ("  indiziert:     {0}.{1}" -f $idx.liste, $idx.interner_name) -ForegroundColor Green
        $angelegt++
    } catch {
        $probleme.Add("Index $($idx.liste).$($idx.interner_name): $($_.Exception.Message)")
    }
}

# ---------------------------------------------------------------------
# 4. Optional: falscher Standardwert an MailGesendetam (Befund 9)
# ---------------------------------------------------------------------
if ($StandardwertMailGesendetamEntfernen) {
    Write-Host ""
    Write-Host "== Standardwert MailGesendetam ==" -ForegroundColor Cyan
    $feld = Get-PnPField -List 'AufgabenEinstellungen' -Identity 'MailGesendetam' -ErrorAction SilentlyContinue
    if (-not $feld) {
        $probleme.Add("MailGesendetam nicht gefunden.")
    }
    elseif ([string]::IsNullOrWhiteSpace($feld.DefaultValue)) {
        Write-Host "  uebersprungen: kein Standardwert gesetzt" -ForegroundColor DarkGray
    }
    elseif ($PSCmdlet.ShouldProcess("AufgabenEinstellungen.MailGesendetam", "Standardwert '$($feld.DefaultValue)' entfernen")) {
        Set-PnPField -List 'AufgabenEinstellungen' -Identity 'MailGesendetam' -Values @{ DefaultValue = '' } -ErrorAction Stop
        Write-Host "  entfernt:      Standardwert von MailGesendetam" -ForegroundColor Green
        Write-Host "  Hinweis: Bereits gesetzte Werte in vorhandenen Zeilen bleiben stehen." -ForegroundColor Yellow
        Write-Host "           Sie sind KEIN Versandnachweis." -ForegroundColor Yellow
        $angelegt++
    }
}

# ---------------------------------------------------------------------
# 5. Optional: die eine Einstellungszeile anlegen
# ---------------------------------------------------------------------
if ($EinstellungszeileAnlegen) {
    Write-Host ""
    Write-Host "== Einstellungszeile ==" -ForegroundColor Cyan
    $vorhandene = Get-PnPListItem -List 'AufgabenEinstellungen' `
        -Query "<View><Query><Where><Eq><FieldRef Name='Typart'/><Value Type='Text'>Einstellung</Value></Eq></Where></Query><RowLimit>1</RowLimit></View>" `
        -ErrorAction SilentlyContinue

    if ($vorhandene) {
        Write-Host "  uebersprungen: Einstellungszeile existiert bereits (ID $($vorhandene[0].Id))" -ForegroundColor DarkGray
    }
    elseif ($PSCmdlet.ShouldProcess("AufgabenEinstellungen", "Einstellungszeile anlegen")) {
        Add-PnPListItem -List 'AufgabenEinstellungen' -Values @{
            Typart              = 'Einstellung'
            Restschwelle        = 1
            InaktivTage         = 21
            Abrechnungsschwelle = 5
            VortagAktiv         = $false
            # Versand bleibt bewusst AUS. Interner Name mit Tippfehler (Befund 9).
            VerandAktiv         = $false
        } -ErrorAction Stop | Out-Null
        Write-Host "  angelegt:      Einstellungszeile (Versand AUS)" -ForegroundColor Green
        Write-Host "  Die interne Empfaengeradresse tragen Sie in der App unter" -ForegroundColor Yellow
        Write-Host "  Einstellungen ein." -ForegroundColor Yellow
        $angelegt++
    }
}

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "Angelegt/geaendert : $angelegt"
Write-Host "Uebersprungen      : $uebersprungen"
Write-Host "Hinweise           : $($probleme.Count)" -ForegroundColor $(if ($probleme.Count) { 'Yellow' } else { 'Green' })
foreach ($p in $probleme) { Write-Host "  - $p" -ForegroundColor Yellow }
Write-Host ""
Write-Host "NICHT erledigt (bewusst, jeweils eigener Schritt):" -ForegroundColor Yellow
Write-Host "  - Anzeigenamenkorrektur der Doku-Spalte 'AltEinheiten'"
Write-Host "  - Umzug vorhandener Zaehlerwerte von der Doku an das Rezept"
Write-Host "  Beides zuerst mit Pruefe-Bestandsdaten.ps1 bewerten."

Disconnect-PnPOnline
