<#
.SYNOPSIS
    Prueft die 16 Spalten der einfachen Fassung und legt fehlende an.

.DESCRIPTION
    Grundsaetze:
      * ZUERST PRUEFEN. Jede Spalte wird gesucht - ueber den internen Namen
        UND ueber den Anzeigenamen. Ist sie da, bleibt sie unangetastet.
      * NICHTS LOESCHEN, NICHTS UMBENENNEN, KEINEN TYP AENDERN.
      * KEINE DATEN ANFASSEN.
      * WIEDERHOLBAR. Ein zweiter Lauf aendert nichts mehr.

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

# Liste, Anzeigename, interner Name, Typ
$spalten = @(
    @{ Liste = 'Rezepte';                  Anzeige = 'PatientID';        Intern = 'PatientID';        Typ = 'Number'   }
    @{ Liste = 'Rezepte';                  Anzeige = 'Erstbefund';       Intern = 'Erstbefund';       Typ = 'Note'     }
    @{ Liste = 'Rezepte';                  Anzeige = 'Anamnese';         Intern = 'Anamnese';         Typ = 'Note'     }
    @{ Liste = 'Behandlungsdokumentation'; Anzeige = 'PatientID';        Intern = 'PatientID';        Typ = 'Number'   }
    @{ Liste = 'Behandlungsdokumentation'; Anzeige = 'Behandlungsdatum'; Intern = 'Behandlungsdatum'; Typ = 'DateTime' }
    @{ Liste = 'Behandlungsdokumentation'; Anzeige = 'Massnahmen';       Intern = 'Massnahmen';       Typ = 'Note'     }
    @{ Liste = 'Behandlungsdokumentation'; Anzeige = 'Reaktion';         Intern = 'Reaktion';         Typ = 'Note'     }
    @{ Liste = 'Behandlungsdokumentation'; Anzeige = 'Heimuebungen';     Intern = 'Heimuebungen';     Typ = 'Note'     }
)

# Spalten, auf die gefiltert wird - ohne Index bricht die Abfrage ab
# 5000 Listenelementen ab.
$indizes = @(
    @{ Liste = 'Behandlungsdokumentation'; Intern = 'PatientID' }
    @{ Liste = 'Rezepte';                  Intern = 'PatientID' }
    @{ Liste = 'Patientenstamm';           Intern = 'Nachname'  }
)

$angelegt = 0; $vorhanden = 0
$hinweise = [System.Collections.Generic.List[string]]::new()

Write-Host ""
Write-Host "== Spalten ==" -ForegroundColor Cyan

foreach ($s in $spalten) {

    if (-not (Get-PnPList -Identity $s.Liste -ErrorAction SilentlyContinue)) {
        $hinweise.Add("Liste '$($s.Liste)' nicht gefunden - '$($s.Anzeige)' uebersprungen.")
        continue
    }

    $felder = Get-PnPField -List $s.Liste
    $treffer = $felder | Where-Object {
        $_.InternalName -eq $s.Intern -or $_.Title -eq $s.Anzeige
    } | Select-Object -First 1

    if ($treffer) {
        Write-Host ("  vorhanden : {0}.{1}  (intern '{2}', Typ {3})" -f `
            $s.Liste, $s.Anzeige, $treffer.InternalName, $treffer.TypeAsString) -ForegroundColor DarkGray
        if ($treffer.TypeAsString -ne $s.Typ) {
            $hinweise.Add("$($s.Liste).$($s.Anzeige): Typ ist '$($treffer.TypeAsString)', erwartet '$($s.Typ)'. NICHT geaendert - bitte fachlich pruefen.")
        }
        if ($treffer.InternalName -ne $s.Intern) {
            $hinweise.Add("$($s.Liste).$($s.Anzeige): interner Name ist '$($treffer.InternalName)', dokumentiert war '$($s.Intern)'.")
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
Write-Host "== Indizes ==" -ForegroundColor Cyan
foreach ($i in $indizes) {
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

Write-Host ""
Write-Host "== Auswahlwerte Therapeut ==" -ForegroundColor Cyan
$t = Get-PnPField -List 'Behandlungsdokumentation' -Identity 'Therapeut' -ErrorAction SilentlyContinue
if (-not $t) {
    $hinweise.Add("Spalte 'Therapeut' nicht gefunden. Die App braucht sie als Auswahlfeld.")
} elseif ($t.TypeAsString -notlike 'Choice*') {
    $hinweise.Add("'Therapeut' ist kein Auswahlfeld (Typ $($t.TypeAsString)). Die App liest die Werte mit Choices().")
} else {
    $werte = @(([xml]$t.SchemaXml).Field.CHOICES.CHOICE)
    Write-Host ("  hinterlegt: {0}" -f ($werte -join ', ')) -ForegroundColor DarkGray
    Write-Host "  Die App uebernimmt diese Werte unveraendert. Weitere Physios" -ForegroundColor DarkGray
    Write-Host "  tragen Sie direkt in SharePoint an dieser Spalte nach." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "Angelegt   : $angelegt"
Write-Host "Vorhanden  : $vorhanden"
Write-Host "Hinweise   : $($hinweise.Count)" -ForegroundColor $(if ($hinweise.Count) { 'Yellow' } else { 'Green' })
foreach ($h in $hinweise) { Write-Host "  - $h" -ForegroundColor Yellow }

Disconnect-PnPOnline
