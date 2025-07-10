# Build Windows Desktop App Script
# Usage: .\scripts\build-windows.ps1 [-CreateInstaller] [-SelfSign]

param(
    [switch]$CreateInstaller = $false,
    [switch]$SelfSign = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
Build Windows Desktop App Script

Usage: .\scripts\build-windows.ps1 [OPTIONS]

Options:
  -CreateInstaller    Create NSIS installer package
  -SelfSign          Self-sign the executable and installer
  -Help              Show this help message

Examples:
  .\scripts\build-windows.ps1                           # Basic build
  .\scripts\build-windows.ps1 -CreateInstaller          # Build with installer
  .\scripts\build-windows.ps1 -CreateInstaller -SelfSign # Build, install, and sign

Note: Self-signed applications will show Windows security warnings.
For production, use a proper code signing certificate.
"@
    exit 0
}

Write-Host "🚀 Building Advent Hymnals Windows Desktop App..." -ForegroundColor Cyan

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter not found. Please install Flutter and add it to PATH." -ForegroundColor Red
    exit 1
}

# Enable Windows desktop support
Write-Host "📱 Enabling Windows desktop support..." -ForegroundColor Yellow
flutter config --enable-windows-desktop

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Build the app
Write-Host "🔨 Building Windows app..." -ForegroundColor Yellow
flutter build windows --release --verbose

$exePath = "build\windows\x64\runner\Release\Advent Hymnals.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "❌ Build failed. Executable not found at: $exePath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host "📁 Executable location: $exePath" -ForegroundColor Cyan

# Self-sign if requested
if ($SelfSign) {
    Write-Host "🔐 Creating self-signed certificate..." -ForegroundColor Yellow
    
    try {
        $cert = New-SelfSignedCertificate -Subject "CN=Advent Hymnals" -Type CodeSigning -KeyUsage DigitalSignature -FriendlyName "Advent Hymnals Code Signing" -CertStoreLocation "Cert:\CurrentUser\My" -KeyLength 2048
        
        Write-Host "✍️ Signing executable..." -ForegroundColor Yellow
        Set-AuthenticodeSignature -FilePath $exePath -Certificate $cert
        Write-Host "✅ Executable signed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Failed to sign executable: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Create installer if requested
if ($CreateInstaller) {
    Write-Host "📦 Creating installer..." -ForegroundColor Yellow
    
    # Check if NSIS is installed
    if (-not (Get-Command makensis -ErrorAction SilentlyContinue)) {
        Write-Host "⚠️ NSIS not found. Installing via Chocolatey..." -ForegroundColor Yellow
        
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install nsis -y
        } else {
            Write-Host "❌ Chocolatey not found. Please install NSIS manually from https://nsis.sourceforge.io/" -ForegroundColor Red
            Write-Host "   Or install Chocolatey first: https://chocolatey.org/install" -ForegroundColor Yellow
            exit 1
        }
    }
    
    # Create LICENSE file if missing
    if (-not (Test-Path "LICENSE")) {
        Write-Host "📄 Creating LICENSE file..." -ForegroundColor Yellow
        $license = @"
MIT License

Copyright (c) 2024 Advent Hymnals

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
        $license | Out-File -FilePath "LICENSE" -Encoding UTF8
    }
    
    # Create installer script
    Write-Host "📝 Creating installer script..." -ForegroundColor Yellow
    $installerScript = @"
!define APP_NAME "Advent Hymnals"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "Advent Hymnals"
!define APP_URL "https://adventhymnals.org"
!define APP_DESCRIPTION "Comprehensive hymnal desktop application"

!include "MUI2.nsh"

Name "`${APP_NAME}"
OutFile "advent-hymnals-installer.exe"
InstallDir "`$PROGRAMFILES64\`${APP_NAME}"
InstallDirRegKey HKLM "Software\`${APP_NAME}" "InstallPath"
RequestExecutionLevel admin

!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Section "Main Application" SecMain
  SetOutPath "`$INSTDIR"
  
  File /r "build\windows\x64\runner\Release\*"
  
  WriteRegStr HKLM "Software\`${APP_NAME}" "InstallPath" "`$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "DisplayName" "`${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "UninstallString" "`$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "DisplayIcon" "`$INSTDIR\Advent Hymnals.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "Publisher" "`${APP_PUBLISHER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "URLInfoAbout" "`${APP_URL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "DisplayVersion" "`${APP_VERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}" "NoRepair" 1
  
  CreateDirectory "`$SMPROGRAMS\`${APP_NAME}"
  CreateShortcut "`$SMPROGRAMS\`${APP_NAME}\`${APP_NAME}.lnk" "`$INSTDIR\Advent Hymnals.exe"
  CreateShortcut "`$SMPROGRAMS\`${APP_NAME}\Uninstall.lnk" "`$INSTDIR\uninstall.exe"
  CreateShortcut "`$DESKTOP\`${APP_NAME}.lnk" "`$INSTDIR\Advent Hymnals.exe"
  
  WriteUninstaller "`$INSTDIR\uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "`$INSTDIR\*"
  RMDir /r "`$INSTDIR"
  
  Delete "`$SMPROGRAMS\`${APP_NAME}\*"
  RMDir "`$SMPROGRAMS\`${APP_NAME}"
  Delete "`$DESKTOP\`${APP_NAME}.lnk"
  
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_NAME}"
  DeleteRegKey HKLM "Software\`${APP_NAME}"
SectionEnd
"@
    
    $installerScript | Out-File -FilePath "installer.nsi" -Encoding UTF8
    
    # Build installer
    Write-Host "🔨 Building installer..." -ForegroundColor Yellow
    makensis installer.nsi
    
    if (Test-Path "advent-hymnals-installer.exe") {
        Write-Host "✅ Installer created successfully!" -ForegroundColor Green
        Write-Host "📁 Installer location: advent-hymnals-installer.exe" -ForegroundColor Cyan
        
        # Sign installer if requested
        if ($SelfSign) {
            Write-Host "✍️ Signing installer..." -ForegroundColor Yellow
            try {
                $cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Subject -eq "CN=Advent Hymnals" } | Select-Object -First 1
                if ($cert) {
                    Set-AuthenticodeSignature -FilePath "advent-hymnals-installer.exe" -Certificate $cert
                    Write-Host "✅ Installer signed successfully!" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "⚠️ Failed to sign installer: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "❌ Installer creation failed!" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "🎉 Build Summary:" -ForegroundColor Cyan
Write-Host "  📱 App Name: Advent Hymnals" -ForegroundColor White
Write-Host "  📁 Executable: $exePath" -ForegroundColor White

if (Test-Path $exePath) {
    $size = (Get-Item $exePath).Length / 1MB
    Write-Host "  📊 Size: $([math]::Round($size, 1)) MB" -ForegroundColor White
}

if ($CreateInstaller -and (Test-Path "advent-hymnals-installer.exe")) {
    $installerSize = (Get-Item "advent-hymnals-installer.exe").Length / 1MB
    Write-Host "  📦 Installer: advent-hymnals-installer.exe ($([math]::Round($installerSize, 1)) MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "⚠️  Installation Notes:" -ForegroundColor Yellow
Write-Host "  • Windows will show security warnings for self-signed apps" -ForegroundColor White
Write-Host "  • Users should click 'More info' → 'Run anyway' to proceed" -ForegroundColor White
Write-Host "  • Consider purchasing a code signing certificate for production" -ForegroundColor White

Write-Host ""
Write-Host "✅ Build completed successfully!" -ForegroundColor Green