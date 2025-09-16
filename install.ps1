# === CHECK FOR ADMIN PRIVILEGES ===
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "UAC is required. Restarting as administrator..."

    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs

    exit
}

# === CONFIGURATION ===
$scriptDir = "C:\PolicyBypass"
$batUrl = "https://raw.githubusercontent.com/appelmoesgg/policyBypass/refs/heads/main/editRegOnBoot.bat"
$regUrl = "https://github.com/appelmoesgg/policyBypass/raw/refs/heads/main/policyBypass.reg"
$taskUrl = "https://github.com/appelmoesgg/policyBypass/raw/refs/heads/main/policyBypass.xml"
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

# === CREATE NEW SCHEDULED TASK ===
Write-Host "Creating scheduled task..."
schtasks /Create /XML $taskPath /TN $taskName

Write-Host "Scheduled task '$taskName' created successfully and will run at startup."
Read-Host -Prompt "Druk op Enter om af te sluiten"
exit

