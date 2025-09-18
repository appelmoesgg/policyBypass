# === CHECK FOR ADMIN PRIVILEGES ===
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "This script requires Administrator privileges. Restarting as Administrator..."

    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/appelmoesgg/policyBypass/refs/heads/main/install.ps1 | iex`"" `
        -Verb RunAs

    exit
}

Write-Host "Starting bypass installation..."

# === CONFIGURATION ===
$scriptDir = "C:\PolicyBypass"
$batUrl = "https://raw.githubusercontent.com/appelmoesgg/policyBypass/refs/heads/main/editRegOnBoot.bat"
$regUrl = "https://raw.githubusercontent.com/appelmoesgg/policyBypass/refs/heads/main/policyBypass.reg"
$taskUrl = "https://raw.githubusercontent.com/appelmoesgg/policyBypass/refs/heads/main/policyBypass.xml"
$batPath = Join-Path $scriptDir "editRegOnBoot.bat"
$regPath = Join-Path $scriptDir "policyBypass.reg"
$taskPath = Join-Path $scriptDir "policyBypass.xml"
$taskName = "policyBypass"

# === CREATE SCRIPT FOLDER IF NOT EXISTS ===
if (-not (Test-Path $scriptDir)) {
    New-Item -Path $scriptDir -ItemType Directory -Force
}

# === DOWNLOAD FILES ==
Write-Host "Downloading .bat file..."
Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing
Write-Host "Downloading regkey file..."
Invoke-WebRequest -Uri $regUrl -OutFile $regPath -UseBasicParsing
Write-Host "Downloading task xml..."
Invoke-WebRequest -Uri $taskUrl -outFile $taskPath -UseBasicParsing

# === UNBLOCK FILES ===
Unblock-File -Path $batPath
Unblock-File -Path $regPath
Unblock-File -Path $taskPath

# === REMOVE EXISTING TASK IF EXISTS ===
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Host "Deleting old task..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# === ENCODING ===
#$xmlContent = Get-Content $taskPath -Encoding Unicode
#$xmlContent | Set-Content -Path $taskPath -Encoding Unicode

# === CREATE NEW SCHEDULED TASK ===
Write-Host "Creating scheduled task..."
schtasks /Create /XML $taskPath /TN $taskName

Write-Host "Bypass gefixt leuk toch"
Read-Host -Prompt "Druk op Enter om af te sluiten..."
exit







