
# Build-DIAG.ps1
# Compila o ExportEvents.ps1 para EXE usando ps2exe e organiza distribuição

$ErrorActionPreference = "Stop"

# Verifica se o módulo ps2exe está instalado
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "Installing ps2exe module..."
    Install-Module -Name ps2exe -Scope CurrentUser -Force
}

# Caminhos
$scriptPath = "ExportEvents.ps1"
$outputExe = "DIAGS.exe"
$iconPath = "diag_temp_icon.ico"

# Compilar EXE com ícone e UAC
Invoke-ps2exe -inputFile $scriptPath `
              -outputFile $outputExe `
              -icon $iconPath `
              -noConsole `
              -requireAdmin

# Criar estrutura de distribuição
New-Item -ItemType Directory -Path ".\dist\full" -Force | Out-Null
New-Item -ItemType Directory -Path ".\dist\portable" -Force | Out-Null

# Copiar arquivos para versão completa
Copy-Item -Path "DIAGS.exe", "ExportEvents.bat", "README.txt", "CHANGELOG.txt" -Destination ".\dist\full" -Force

# Copiar somente EXE para versão portátil
Copy-Item -Path "DIAGS.exe" -Destination ".\dist\portable" -Force

Write-Host "Build completed. Check the /dist folders."
