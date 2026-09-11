<#
.SYNOPSIS
    Bewertet die Bestandsdaten zu den beiden ungeklaerten Punkten aus Befund 3
    und Befund 4. Aendert NICHTS.

.DESCRIPTION
    Zwei Fragen lassen sich nur an den echten Daten beantworten:

    (1) Befund 3 - Was ist die Doku-Spalte mit dem Anzeigenamen 'AltEinheiten'
        und dem internen Namen 'Einheiten' fachlich?
        Der Standardwert 1 spricht fuer "Behandlungsmenge dieser einen Zeile".
        Der Anzeigename spricht fuer "Altbestand des Rezepts".
        Das Skript zeigt die tatsaechliche Werteverteilung. Sind fast alle
        Werte 1 oder 2, ist es eine Behandlungsmenge. Gibt es viele grosse
        Werte, die je Rezept nur einmal vorkommen, ist es ein Altbestand.

    (2) Befund 4 - Stehen in der Dokumentation Zaehlerwerte (EinheitenApp,
        Erbracht, Offen, LetzterAppTermin, InaktivTage), die eigentlich an das
        Rezept gehoeren? Das Skript zaehlt, wie viele Zeilen betroffen sind -
        damit klar ist, ob ein Umzug ueberhaupt Daten betrifft.

    Das Skript schreibt nichts. Es gibt eine Empfehlung aus, entscheidet aber
    nicht.

.PARAMETER SiteUrl
    URL der SharePoint-Website mit den Listen.

.PARAMETER MengenSpalte
    Interner Name der zu bewertenden Doku-Spalte. Standard: Einheiten.
    Falls Pruefe-Schema.ps1 einen anderen internen Namen gemeldet hat,
    diesen hier angeben.

.EXAMPLE
    .\Pruefe-Bestandsdaten.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Praxis"

.NOTES
    Voraussetzung: PnP.PowerShell. Leserechte genuegen.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SiteUrl,
    [string]$MengenSpalte = 'Einheiten',
    [string]$BerichtPfad = (Join-Path $PSScriptRoot 'Bestandsdaten-Bericht.md')
)

$ErrorActionPreference = 'Stop'
Import-Module PnP.PowerShell -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -Interactive

$zeilen = [System.Collections.Generic.List[string]]::new()
$zeilen.Add("# Bestandsdatenbericht")
$zeilen.Add("")
$zeilen.Add("Erzeugt am $(Get-Date -Format 'yyyy-MM-dd HH:mm'). Dieses Skript hat nichts veraendert.")
$zeilen.Add("")

Write-Host "Lese Behandlungsdokumentation (seitenweise) ..." -ForegroundColor Cyan

# Seitenweise lesen: -PageSize holt auch Listen ueber 5000 Elemente vollstaendig.
$alle = Get-PnPListItem -List 'Behandlungsdokumentation' -PageSize 2000
$gesamt = $alle.Count
$zeilen.Add("Zeilen in der Behandlungsdokumentation: **$gesamt**")
$zeilen.Add("")

# --- (1) Werteverteilung der Mengenspalte -----------------------------
$zeilen.Add("## Befund 3 - Spalte ``$MengenSpalte`` (Anzeigename bisher 'AltEinheiten')")
$zeilen.Add("")

$werte = foreach ($e in $alle) {
    $v = $e.FieldValues[$MengenSpalte]
    if ($null -ne $v) { [double]$v }
}
$werte = @($werte)

if ($werte.Count -eq 0) {
    $zeilen.Add("Die Spalte ist in allen Zeilen leer oder nicht vorhanden.")
    $zeilen.Add("")
    $zeilen.Add("**Bewertung:** Ohne Bestandswerte ist eine Anzeigenamenkorrektur gefahrlos.")
    $empfehlung = "Anzeigename kann ohne Datenrisiko korrigiert werden."
}
else {
    $gruppen = $werte | Group-Object | Sort-Object { [double]$_.Name }
    $zeilen.Add("| Wert | Anzahl Zeilen | Anteil |")
    $zeilen.Add("|---|---|---|")
    foreach ($g in $gruppen) {
        $anteil = [math]::Round(100 * $g.Count / $werte.Count, 1)
        $zeilen.Add("| $($g.Name) | $($g.Count) | $anteil % |")
    }
    $zeilen.Add("")

    $anteilEins = [math]::Round(100 * (@($werte | Where-Object { $_ -eq 1 }).Count) / $werte.Count, 1)
    $anteilKlein = [math]::Round(100 * (@($werte | Where-Object { $_ -le 3 }).Count) / $werte.Count, 1)
    $maximum = ($werte | Measure-Object -Maximum).Maximum

    $zeilen.Add("- Anteil mit Wert genau 1: **$anteilEins %**")
    $zeilen.Add("- Anteil mit Wert bis 3: **$anteilKlein %**")
    $zeilen.Add("- Groesster Wert: **$maximum**")
    $zeilen.Add("")

    if ($anteilKlein -ge 90) {
        $empfehlung = "Die Werte sehen nach der Behandlungsmenge EINER Zeile aus."
        $zeilen.Add("**Bewertung:** $empfehlung")
        $zeilen.Add("")
        $zeilen.Add("Empfohlenes Vorgehen:")
        $zeilen.Add("1. Anzeigenamen dieser Spalte von 'AltEinheiten' auf **'Behandlungsmenge'** aendern.")
        $zeilen.Add("   Der interne Name ``$MengenSpalte`` bleibt unveraendert - bestehende Verweise brechen dadurch nicht.")
        $zeilen.Add("2. In der App die Patch-Zuweisung ``AltEinheiten:`` auf ``Behandlungsmenge:`` umstellen")
        $zeilen.Add("   (vier Fundstellen, siehe 06_Tests.md).")
        $zeilen.Add("3. Den Rezept-Altbestand fuehrt die neue Spalte ``Rezepte.AltEinheiten``.")
    }
    else {
        $empfehlung = "Die Werte sehen NICHT nach einer Behandlungsmenge je Zeile aus."
        $zeilen.Add("**Bewertung:** $empfehlung")
        $zeilen.Add("")
        $zeilen.Add("Hier ist Vorsicht geboten: Moeglicherweise wurde die Spalte tatsaechlich")
        $zeilen.Add("als Rezeptaltbestand befuellt. Dann darf sie NICHT als Behandlungsmenge")
        $zeilen.Add("weiterverwendet werden. Bitte fachlich klaeren, bevor irgendetwas")
        $zeilen.Add("umbenannt oder gezaehlt wird. Der Zaehler-Flow sollte bis dahin nicht")
        $zeilen.Add("scharf geschaltet werden.")
    }
}
$zeilen.Add("")

# --- (2) Zaehlerwerte in der Dokumentation ----------------------------
$zeilen.Add("## Befund 4 - Zaehlerwerte in der Dokumentation")
$zeilen.Add("")
$zeilen.Add("| Spalte | Zeilen mit Wert |")
$zeilen.Add("|---|---|")

$zaehlerSpalten = @('EinheitenApp', 'Erbracht', 'Offen', 'LetzterAppTermin', 'InaktivTage')
$betroffen = 0
foreach ($sp in $zaehlerSpalten) {
    $anzahl = @($alle | Where-Object {
        $v = $_.FieldValues[$sp]
        $null -ne $v -and "$v" -ne '' -and "$v" -ne '0'
    }).Count
    $betroffen += $anzahl
    $zeilen.Add("| ``$sp`` | $anzahl |")
}
$zeilen.Add("")

if ($betroffen -eq 0) {
    $zeilen.Add("**Bewertung:** In der Dokumentation stehen keine Zaehlerwerte.")
    $zeilen.Add("Es ist nichts umzuziehen. Die neuen Zaehlerspalten am Rezept koennen")
    $zeilen.Add("direkt vom Flow befuellt werden.")
} else {
    $zeilen.Add("**Bewertung:** Es gibt $betroffen befuellte Zaehlerfelder in der Dokumentation.")
    $zeilen.Add("")
    $zeilen.Add("Diese Werte duerfen **nicht** einfach an das Rezept kopiert und auch nicht")
    $zeilen.Add("zusaetzlich mitgezaehlt werden - sonst wird doppelt gezaehlt. Empfohlenes")
    $zeilen.Add("Vorgehen:")
    $zeilen.Add("1. Den Zaehler-Flow einmal ueber alle Rezepte laufen lassen. Er berechnet")
    $zeilen.Add("   die Werte NEU aus den Doku-Zeilen und uebernimmt nichts Altes.")
    $zeilen.Add("2. Die neu berechneten Rezeptwerte stichprobenartig gegen die alten")
    $zeilen.Add("   Doku-Werte halten.")
    $zeilen.Add("3. Erst danach entscheiden, ob die alten Doku-Spalten ausgeblendet werden.")
    $zeilen.Add("   Loeschen ist nicht noetig und nicht empfohlen.")
}
$zeilen.Add("")

$zeilen -join "`r`n" | Set-Content -Path $BerichtPfad -Encoding UTF8
Write-Host ""
Write-Host "Bericht geschrieben: $BerichtPfad" -ForegroundColor Green
Disconnect-PnPOnline
