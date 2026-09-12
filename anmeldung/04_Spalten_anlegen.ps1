<#
.SYNOPSIS
    Legt die Liste "Anmeldungen" an und ergaenzt Patientenstamm um die
    Kontaktspalten der Anmelde-App.

.DESCRIPTION
    Grundsaetze:
      * ZUERST PRUEFEN. Jede Liste und jede Spalte wird gesucht - ueber den
        internen Namen UND ueber den Anzeigenamen. Ist sie da, bleibt sie
        unangetastet.
      * NICHTS LOESCHEN, NICHTS UMBENENNEN, KEINEN TYP AENDERN.
      * KEINE DATEN ANFASSEN.
      * WIEDERHOLBAR. Ein zweiter Lauf aendert nichts mehr.

    Die beiden bestehenden Apps sind nicht betroffen: an Patientenstamm
    kommen nur Spalten DAZU, und Anmeldungen ist eine neue Liste.

    Fuehren Sie das Skript zuerst mit -WhatIf aus und lesen Sie die Vorschau.

.PARAMETER SiteUrl
    URL der SharePoint-Website mit den Listen.

.EXAMPLE
    .\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis" -WhatIf
    .\04_Spalten_anlegen.ps1 -SiteUrl "https://IHRE-ADRESSE/sites/Praxis"

.NOTES
    Voraussetzung: Install-Module PnP.PowerShell -Scope CurrentUser
    Dieses Skript wurde statisch geschrieben und NICHT ausgefuehrt - in der
    Entwicklungsumgebung stand keine PowerShell zur Verfuegung. Deshalb
    unbedingt zuerst -WhatIf verwenden.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$SiteUrl
)

$ErrorActionPreference = 'Stop'
Import-Module PnP.PowerShell -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -Interactive

$hinweise = [System.Collections.Generic.List[string]]::new()
$angelegt = 0; $vorhanden = 0

# ---------------------------------------------------------------------
# 1. Die Liste Anmeldungen
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Liste ==" -ForegroundColor Cyan

$anmeldungen = Get-PnPList -Identity 'Anmeldungen' -ErrorAction SilentlyContinue
if ($anmeldungen) {
    Write-Host "  vorhanden : Anmeldungen" -ForegroundColor DarkGray
    $vorhanden++
}
elseif ($PSCmdlet.ShouldProcess("Anmeldungen", "Liste anlegen")) {
    try {
        New-PnPList -Title 'Anmeldungen' -Template GenericList -OnQuickLaunch -ErrorAction Stop | Out-Null
        Write-Host "  angelegt  : Anmeldungen" -ForegroundColor Green
        $angelegt++
    } catch {
        $hinweise.Add("Liste 'Anmeldungen' konnte nicht angelegt werden: $($_.Exception.Message)")
    }
}

# ---------------------------------------------------------------------
# 2. Spalten
#    PLZ und Telefon sind bewusst Text: fuehrende Nullen.
# ---------------------------------------------------------------------
$spalten = @(
    @{ Liste = 'Patientenstamm'; Anzeige = 'Telefon';             Intern = 'Telefon';             Typ = 'Text'     }
    @{ Liste = 'Patientenstamm'; Anzeige = 'EMail';               Intern = 'EMail';               Typ = 'Text'     }
    @{ Liste = 'Patientenstamm'; Anzeige = 'Strasse';             Intern = 'Strasse';             Typ = 'Text'     }
    @{ Liste = 'Patientenstamm'; Anzeige = 'PLZ';                 Intern = 'PLZ';                 Typ = 'Text'     }
    @{ Liste = 'Patientenstamm'; Anzeige = 'Ort';                 Intern = 'Ort';                 Typ = 'Text'     }
    @{ Liste = 'Anmeldungen';    Anzeige = 'PatientID';           Intern = 'PatientID';           Typ = 'Number'   }
    @{ Liste = 'Anmeldungen';    Anzeige = 'Anmeldedatum';        Intern = 'Anmeldedatum';        Typ = 'DateTime' }
    @{ Liste = 'Anmeldungen';    Anzeige = 'Vertragsstand';       Intern = 'Vertragsstand';       Typ = 'Text'     }
    @{ Liste = 'Anmeldungen';    Anzeige = 'Honorar_Zugestimmt';  Intern = 'Honorar_Zugestimmt';  Typ = 'Boolean'  }
    @{ Liste = 'Anmeldungen';    Anzeige = 'Honorar_Name';        Intern = 'Honorar_Name';        Typ = 'Text'     }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Zugestimmt';       Intern = 'DS_Zugestimmt';       Typ = 'Boolean'  }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Name';             Intern = 'DS_Name';             Typ = 'Text'     }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Rechnung_EMail';   Intern = 'DS_Rechnung_EMail';   Typ = 'Boolean'  }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Kontakt_EMail';    Intern = 'DS_Kontakt_EMail';    Typ = 'Boolean'  }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Kontakt_Telefon';  Intern = 'DS_Kontakt_Telefon';  Typ = 'Boolean'  }
    @{ Liste = 'Anmeldungen';    Anzeige = 'DS_Kontakt_WhatsApp'; Intern = 'DS_Kontakt_WhatsApp'; Typ = 'Boolean'  }
)

# Auswahlspalten getrennt: sie brauchen ihre Werteliste.
$auswahlspalten = @(
    @{ Liste = 'Anmeldungen'; Anzeige = 'Versicherung'; Intern = 'Versicherung'
       Werte = @('Privat versichert', 'Beihilfeberechtigt', 'Gesetzlich versichert', 'Selbstzahler') }
    @{ Liste = 'Anmeldungen'; Anzeige = 'DS_SocialMedia'; Intern = 'DS_SocialMedia'
       Werte = @('Einverstanden', 'Nicht einverstanden') }
)

Write-Host ""
Write-Host "== Spalten ==" -ForegroundColor Cyan

foreach ($s in $spalten) {
    if (-not (Get-PnPList -Identity $s.Liste -ErrorAction SilentlyContinue)) {
        $hinweise.Add("Liste '$($s.Liste)' nicht gefunden - '$($s.Anzeige)' uebersprungen.")
        continue
    }
    $treffer = Get-PnPField -List $s.Liste | Where-Object {
        $_.InternalName -eq $s.Intern -or $_.Title -eq $s.Anzeige
    } | Select-Object -First 1

    if ($treffer) {
        Write-Host ("  vorhanden : {0}.{1}  (intern '{2}', Typ {3})" -f `
            $s.Liste, $s.Anzeige, $treffer.InternalName, $treffer.TypeAsString) -ForegroundColor DarkGray
        if ($treffer.TypeAsString -ne $s.Typ) {
            $hinweise.Add("$($s.Liste).$($s.Anzeige): Typ ist '$($treffer.TypeAsString)', erwartet '$($s.Typ)'. NICHT geaendert - bitte fachlich pruefen.")
        }
        $vorhanden++
        continue
    }

    if (-not $PSCmdlet.ShouldProcess("$($s.Liste).$($s.Anzeige) ($($s.Typ))", "Spalte anlegen")) { continue }
    try {
        Add-PnPField -List $s.Liste -DisplayName $s.Anzeige -InternalName $s.Intern `
                     -Type $s.Typ -AddToDefaultView -ErrorAction Stop | Out-Null
        Write-Host ("  angelegt  : {0}.{1} [{2}]" -f $s.Liste, $s.Anzeige, $s.Typ) -ForegroundColor Green
        $angelegt++
    } catch {
        $hinweise.Add("$($s.Liste).$($s.Anzeige) konnte nicht angelegt werden: $($_.Exception.Message)")
    }
}

Write-Host ""
Write-Host "== Auswahlspalten ==" -ForegroundColor Cyan

foreach ($a in $auswahlspalten) {
    if (-not (Get-PnPList -Identity $a.Liste -ErrorAction SilentlyContinue)) {
        $hinweise.Add("Liste '$($a.Liste)' nicht gefunden - '$($a.Anzeige)' uebersprungen.")
        continue
    }
    $treffer = Get-PnPField -List $a.Liste | Where-Object {
        $_.InternalName -eq $a.Intern -or $_.Title -eq $a.Anzeige
    } | Select-Object -First 1

    if ($treffer) {
        Write-Host ("  vorhanden : {0}.{1}" -f $a.Liste, $a.Anzeige) -ForegroundColor DarkGray
        $hinweise.Add("$($a.Liste).$($a.Anzeige) existiert bereits - die Auswahlwerte wurden NICHT geprueft. Bitte nachsehen, ob genau diese Werte hinterlegt sind: $($a.Werte -join ', ')")
        $vorhanden++
        continue
    }

    if (-not $PSCmdlet.ShouldProcess("$($a.Liste).$($a.Anzeige) (Auswahl)", "Auswahlspalte anlegen")) { continue }
    try {
        Add-PnPField -List $a.Liste -DisplayName $a.Anzeige -InternalName $a.Intern `
                     -Type Choice -Choices $a.Werte -AddToDefaultView -ErrorAction Stop | Out-Null
        Write-Host ("  angelegt  : {0}.{1} [Auswahl: {2}]" -f $a.Liste, $a.Anzeige, ($a.Werte -join ', ')) -ForegroundColor Green
        $angelegt++
    } catch {
        $hinweise.Add("$($a.Liste).$($a.Anzeige) konnte nicht angelegt werden: $($_.Exception.Message)")
    }
}

# ---------------------------------------------------------------------
# 3. Index auf PatientID - ohne den bricht die Abfrage ab, sobald die
#    Liste 5000 Elemente ueberschreitet.
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Indizes ==" -ForegroundColor Cyan
foreach ($i in @(@{ Liste = 'Anmeldungen'; Intern = 'PatientID' })) {
    $f = Get-PnPField -List $i.Liste -Identity $i.Intern -ErrorAction SilentlyContinue
    if (-not $f) { $hinweise.Add("Index: $($i.Liste).$($i.Intern) nicht gefunden."); continue }
    if ($f.Indexed) {
        Write-Host ("  vorhanden : {0}.{1}" -f $i.Liste, $i.Intern) -ForegroundColor DarkGray
        continue
    }
    if (-not $PSCmdlet.ShouldProcess("$($i.Liste).$($i.Intern)", "Index anlegen")) { continue }
    try {
        Set-PnPField -List $i.Liste -Identity $i.Intern -Values @{ Indexed = $true } -ErrorAction Stop
        Write-Host ("  indiziert : {0}.{1}" -f $i.Liste, $i.Intern) -ForegroundColor Green
        $angelegt++
    } catch {
        $hinweise.Add("Index $($i.Liste).$($i.Intern): $($_.Exception.Message)")
    }
}

# ---------------------------------------------------------------------
Write-Host ""
Write-Host "== Ergebnis ==" -ForegroundColor Cyan
Write-Host ("  vorhanden gelassen : {0}" -f $vorhanden)
Write-Host ("  neu angelegt       : {0}" -f $angelegt)
if ($hinweise.Count -gt 0) {
    Write-Host ""
    Write-Host "== Bitte ansehen ==" -ForegroundColor Yellow
    foreach ($h in $hinweise) { Write-Host ("  - {0}" -f $h) -ForegroundColor Yellow }
}
Write-Host ""
