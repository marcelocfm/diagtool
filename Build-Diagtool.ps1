
# Build-DIAG.ps1
# Compiles ExportEvents.ps1 into an EXE using ps2exe and organizes distribution

$ErrorActionPreference = "Stop"

# Check if the ps2exe module is installed
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "Installing ps2exe module..."
    Install-Module -Name ps2exe -Scope CurrentUser -Force
}

# File paths
$scriptPath = "ExportEvents.ps1"
$outputExe = "DIAGS.exe"
$iconPath = "diag_temp_icon.ico"

# Compile the EXE with icon and UAC elevation
Invoke-ps2exe -inputFile $scriptPath `
              -outputFile $outputExe `
              -icon $iconPath `
              -noConsole `
              -requireAdmin

# Create distribution folders
New-Item -ItemType Directory -Path ".\dist\full" -Force | Out-Null
New-Item -ItemType Directory -Path ".\dist\portable" -Force | Out-Null

# Copy files for the full version
Copy-Item -Path "DIAGS.exe", "ExportEvents.bat", "README.txt", "CHANGELOG.txt" -Destination ".\dist\full" -Force

# Copy only the EXE for the portable version
Copy-Item -Path "DIAGS.exe" -Destination ".\dist\portable" -Force

Write-Host "Build completed. Check the /dist folders."
