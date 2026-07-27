<#
  Hält die beiden Ablagen neben index.html aktuell:

    archiv\              Kopien der session-results-CSVs, die F1 25 nach
                         "Renndaten speichern" schreibt. Quelle der Rennen.
    mrl-standalone.html  Kopie der Seite mit eingebetteten Schriften,
                         ohne einen einzigen externen Request.

  Aufruf aus dem Projektordner heraus:

      powershell -ExecutionPolicy Bypass -File .\kopien-aktualisieren.ps1

  Nach jedem Rennen laufen lassen, nachdem index.html ergänzt wurde.
#>

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path

# F1 25 legt die CSVs im per OneDrive umgeleiteten Dokumente-Ordner ab.
$quellen = @(
  (Join-Path $env:USERPROFILE "OneDrive\Dokumente\My Games\F1 25\session results"),
  (Join-Path $env:USERPROFILE "Documents\My Games\F1 25\session results")
)

# ── 1. CSVs ins Archiv spiegeln ──────────────────────────────────────
$archiv = Join-Path $repo "archiv"
New-Item -ItemType Directory -Force -Path $archiv | Out-Null

$neu = 0; $gesamt = 0
foreach ($q in $quellen) {
  if (-not (Test-Path -LiteralPath $q)) { continue }
  foreach ($f in Get-ChildItem -LiteralPath $q -Filter "*.csv" -File) {
    $gesamt++
    $ziel = Join-Path $archiv $f.Name
    if (-not (Test-Path -LiteralPath $ziel) -or
        (Get-Item -LiteralPath $ziel).Length -ne $f.Length) {
      Copy-Item -LiteralPath $f.FullName -Destination $ziel -Force
      Write-Host "  neu im Archiv: $($f.Name)"
      $neu++
    }
  }
}
Write-Host "Archiv: $gesamt CSV gefunden, $neu kopiert."

# ── 2. Standalone-Kopie der Seite bauen ──────────────────────────────
$schriften = Join-Path $repo "schriften"
$quelle    = Join-Path $repo "index.html"

# UTF-8 explizit: Get-Content nähme unter PowerShell 5.1 die ANSI-Codepage
# und würde Umlaute und das Minuszeichen U+2212 zerlegen.
$html = [System.IO.File]::ReadAllText($quelle, [System.Text.Encoding]::UTF8)

$faces = New-Object System.Text.StringBuilder
$regeln = @(
  @{ datei = "JetBrainsMono-variable.woff2";  fam = "JetBrains Mono"; stil = "normal"; gew = "100 800" },
  @{ datei = "TitilliumWeb-normal_300.woff2"; fam = "Titillium Web";  stil = "normal"; gew = "300" },
  @{ datei = "TitilliumWeb-normal_400.woff2"; fam = "Titillium Web";  stil = "normal"; gew = "400" },
  @{ datei = "TitilliumWeb-normal_600.woff2"; fam = "Titillium Web";  stil = "normal"; gew = "600" },
  @{ datei = "TitilliumWeb-normal_700.woff2"; fam = "Titillium Web";  stil = "normal"; gew = "700" },
  @{ datei = "TitilliumWeb-normal_900.woff2"; fam = "Titillium Web";  stil = "normal"; gew = "900" },
  @{ datei = "TitilliumWeb-italic_600.woff2"; fam = "Titillium Web";  stil = "italic"; gew = "600" }
)
foreach ($r in $regeln) {
  $pfad = Join-Path $schriften $r.datei
  if (-not (Test-Path -LiteralPath $pfad)) { throw "Schrift fehlt: $pfad" }
  $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($pfad))
  [void]$faces.AppendLine(
    "@font-face{font-family:'$($r.fam)';font-style:$($r.stil);font-weight:$($r.gew);" +
    "font-display:swap;src:url(data:font/woff2;base64,$b64) format('woff2')}")
}

# Google-Fonts-Verweise raus, Schriften direkt in den head
$html = $html -replace '(?m)^\s*<link rel="preconnect"[^>]*>\r?\n', ''
$html = $html -replace '(?m)^\s*<link href="https://fonts\.googleapis\.com[^>]*>\r?\n', ''
$html = $html -replace '</head>', "<style>`n$($faces.ToString())</style>`n</head>"

$ziel = Join-Path $repo "mrl-standalone.html"
[System.IO.File]::WriteAllText($ziel, $html, (New-Object System.Text.UTF8Encoding $false))

# ── 3. Kontrolle ─────────────────────────────────────────────────────
$c = [System.IO.File]::ReadAllText($ziel, [System.Text.Encoding]::UTF8)
$extern   = ([regex]::Matches($c, 'https?://(?!www\.w3\.org)')).Count
$mojibake = ([regex]::Matches($c, 'Ã')).Count
$schnitte = ([regex]::Matches($c, '@font-face')).Count

Write-Host ""
Write-Host "mrl-standalone.html: $([math]::Round((Get-Item $ziel).Length/1KB)) KB, $schnitte Schriftschnitte"
if ($extern -gt 0)   { Write-Warning "$extern externe URL(s) enthalten - bitte prüfen" }
if ($mojibake -gt 0) { Write-Warning "$mojibake kaputte Umlaute - Encoding prüfen" }
if ($extern -eq 0 -and $mojibake -eq 0) { Write-Host "Kontrolle bestanden: keine externen Requests, Umlaute intakt." }
