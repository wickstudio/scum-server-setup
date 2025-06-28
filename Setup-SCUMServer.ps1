# SCUM Server Setup Script
# Note: Administrator privileges will be checked during execution

<#
.SYNOPSIS
    SCUM Dedicated Server Setup Script for Windows
    
.DESCRIPTION
    This script fully automates the setup of a SCUM dedicated server on Windows 10/11.
    It handles firewall configuration, dependency installation, SteamCMD setup, 
    and SCUM server installation.
    
.PARAMETER Port
    TCP port for the SCUM server (default: 7010)
    
.PARAMETER QueryPort
    UDP query port for the SCUM server (default: 27015)
    
.PARAMETER InstallPath
    Installation path for the SCUM server (default: C:\scumserver)
    
.PARAMETER SteamCMDPath
    Installation path for SteamCMD (default: C:\steamcmd)
    
.EXAMPLE
    .\Setup-SCUMServer.ps1
    
.EXAMPLE
    .\Setup-SCUMServer.ps1 -Port 7011 -QueryPort 27016
    
.NOTES
    Author: SCUM Server Setup Script
    Version: 1.0
    Requires: Windows 10/11, PowerShell 5.1+, Administrator privileges
#>

param(
    [int]$Port = 7010,
    [int]$QueryPort = 27015,
    [string]$InstallPath = "C:\scumserver",
    [string]$SteamCMDPath = "C:\steamcmd"
)

try {
    Write-Host "SCUM Server Setup Script Starting..." -ForegroundColor Green
    Write-Host "Checking execution environment..." -ForegroundColor Yellow
    
    $executionPolicy = Get-ExecutionPolicy
    Write-Host "Current PowerShell Execution Policy: $executionPolicy" -ForegroundColor Cyan
    
    if ($executionPolicy -eq "Restricted") {
        Write-Host "`nWARNING: PowerShell execution policy is set to 'Restricted'" -ForegroundColor Yellow
        Write-Host "This script should be run through the clickme.bat file which handles execution policy." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error checking execution environment: $($_.Exception.Message)" -ForegroundColor Red
}

$LogFile = "scum-server-setup.log"
$ErrorCount = 0

trap {
    Write-Host "`n`nFATAL ERROR OCCURRED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nScript execution failed. Check the log file for details: $LogFile" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

function Write-StatusMessage {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Type] $Message"
    
    switch ($Type) {
        "INFO" { Write-Host $LogMessage -ForegroundColor Green }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Cyan }
    }
    
    Add-Content -Path $LogFile -Value $LogMessage
}

function Write-ErrorMessage {
    param(
        [string]$ErrorMessage,
        [bool]$Fatal = $false
    )
    
    $script:ErrorCount++
    Write-StatusMessage "ERROR: $ErrorMessage" "ERROR"
    
    if ($Fatal) {
        Write-StatusMessage "Fatal error encountered. Exiting script." "ERROR"
        Write-Host "`nPress any key to exit..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FileWithProgress {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )
    
    try {
        Write-StatusMessage "Downloading $Description..."
        
        try {
            $ProgressPreference = 'SilentlyContinue'
            
            $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -ErrorAction SilentlyContinue
            $totalSize = $response.Headers.'Content-Length'
            
            if ($totalSize) {
                $totalSize = [int64]$totalSize
                Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
            } else {
                Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
            }
            
            $ProgressPreference = 'Continue'
            Write-Progress -Activity "Downloading $Description" -Completed
            Write-StatusMessage "$Description downloaded successfully." "SUCCESS"
            return $true
        }
        catch {
            Write-StatusMessage "Trying alternative download method..."
            
            $webClient = New-Object System.Net.WebClient
            
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            
            $progressEventHandler = {
                param($eventSender, $e)
                if ($e.TotalBytesToReceive -gt 0) {
                    $percent = [math]::Round(($e.BytesReceived / $e.TotalBytesToReceive) * 100, 2)
                    Write-Progress -Activity "Downloading $Description" -Status "$percent% Complete" -PercentComplete $percent
                }
            }
            
            Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action $progressEventHandler | Out-Null
            
            $webClient.DownloadFile($Url, $OutputPath)
            
            $webClient.Dispose()
            Write-Progress -Activity "Downloading $Description" -Completed
            
            Write-StatusMessage "$Description downloaded successfully." "SUCCESS"
            return $true
        }
    }
    catch {
        Write-ErrorMessage "Failed to download $Description`: $($_.Exception.Message)"
        
        Write-StatusMessage "Download URL: $Url" "WARNING"
        Write-StatusMessage "Output Path: $OutputPath" "WARNING"
        Write-StatusMessage "Try running the script again, or check your internet connection." "WARNING"
        
        return $false
    }
}

function Open-FirewallPorts {
    Write-StatusMessage "Configuring Windows Firewall..."
    
    try {
        Remove-NetFirewallRule -DisplayName "SCUM Server TCP" -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName "SCUM Server Query UDP" -ErrorAction SilentlyContinue
        
        New-NetFirewallRule -DisplayName "SCUM Server TCP" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
        New-NetFirewallRule -DisplayName "SCUM Server Query UDP" -Direction Inbound -Protocol UDP -LocalPort $QueryPort -Action Allow | Out-Null
        
        Write-StatusMessage "Firewall ports opened successfully (TCP:$Port, UDP:$QueryPort)" "SUCCESS"
        return $true
    }
    catch {
        Write-ErrorMessage "Failed to configure firewall: $($_.Exception.Message)"
        return $false
    }
}

function Install-VCRedist {
    Write-StatusMessage "Installing Visual C++ Redistributable x64..."
    
    $vcRedistUrls = @(
        "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe",
        "https://aka.ms/vs/17/release/vc_redist.x64.exe",
        "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe"
    )
    
    $vcRedistPath = "$env:TEMP\vc_redist.x64.exe"
    $downloadSuccessful = $false
    
    foreach ($url in $vcRedistUrls) {
        try {
            Write-StatusMessage "Trying download from: $url"
            
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            
            $webClient.DownloadFile($url, $vcRedistPath)
            $webClient.Dispose()
            
            if ((Test-Path $vcRedistPath) -and ((Get-Item $vcRedistPath).Length -gt 1MB)) {
                Write-StatusMessage "Visual C++ Redistributable downloaded successfully." "SUCCESS"
                $downloadSuccessful = $true
                break
            } else {
                Write-StatusMessage "Downloaded file appears invalid, trying next URL..." "WARNING"
                Remove-Item $vcRedistPath -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-StatusMessage "Download failed from $url`: $($_.Exception.Message)" "WARNING"
            Remove-Item $vcRedistPath -Force -ErrorAction SilentlyContinue
            continue
        }
    }
    
    if (-not $downloadSuccessful) {
        Write-ErrorMessage "Failed to download Visual C++ Redistributable from all available URLs"
        Write-StatusMessage "You may need to manually download and install Visual C++ Redistributable x64" "WARNING"
        return $false
    }
    
    try {
        Write-StatusMessage "Installing Visual C++ Redistributable (this may take a few minutes)..."
        $process = Start-Process -FilePath $vcRedistPath -ArgumentList "/quiet", "/norestart" -Wait -PassThru
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-StatusMessage "Visual C++ Redistributable installed successfully." "SUCCESS"
            Remove-Item $vcRedistPath -Force -ErrorAction SilentlyContinue
            return $true
        } else {
            Write-ErrorMessage "Visual C++ Redistributable installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-ErrorMessage "Failed to install Visual C++ Redistributable: $($_.Exception.Message)"
        return $false
    }
}

function Install-DirectX {
    Write-StatusMessage "Installing DirectX End-User Runtime..."
    
    $directxUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
    $directxPath = "$env:TEMP\dxwebsetup.exe"
    
    try {
        if (Get-FileWithProgress -Url $directxUrl -OutputPath $directxPath -Description "DirectX End-User Runtime") {
            Write-StatusMessage "Installing DirectX (this may take a few minutes)..."
            $process = Start-Process -FilePath $directxPath -ArgumentList "/Q" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-StatusMessage "DirectX installed successfully." "SUCCESS"
                Remove-Item $directxPath -Force -ErrorAction SilentlyContinue
                return $true
            } else {
                Write-ErrorMessage "DirectX installation failed with exit code: $($process.ExitCode)"
                return $false
            }
        }
        return $false
    }
    catch {
        Write-ErrorMessage "Failed to install DirectX: $($_.Exception.Message)"
        return $false
    }
}

function Install-SteamCMD {
    Write-StatusMessage "Setting up SteamCMD..."
    
    $steamCmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
    $steamCmdZip = "$env:TEMP\steamcmd.zip"
    
    try {
        if (!(Test-Path $SteamCMDPath)) {
            New-Item -ItemType Directory -Path $SteamCMDPath -Force | Out-Null
        }
        
        if (Get-FileWithProgress -Url $steamCmdUrl -OutputPath $steamCmdZip -Description "SteamCMD") {
            Write-StatusMessage "Extracting SteamCMD..."
            
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($steamCmdZip, $SteamCMDPath)
            
            Remove-Item $steamCmdZip -Force -ErrorAction SilentlyContinue
            Write-StatusMessage "SteamCMD setup completed successfully." "SUCCESS"
            return $true
        }
        return $false
    }
    catch {
        Write-ErrorMessage "Failed to setup SteamCMD: $($_.Exception.Message)"
        return $false
    }
}

function Install-SCUMServer {
    Write-StatusMessage "Installing SCUM Dedicated Server (this may take 15-30 minutes depending on your internet connection)..."
    
    try {
        if (!(Test-Path $InstallPath)) {
            New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        }
        
        $steamCmdExe = Join-Path $SteamCMDPath "steamcmd.exe"
        $arguments = "+force_install_dir `"$InstallPath`" +login anonymous +app_update 3792580 validate +quit"
        
        Write-StatusMessage "Running SteamCMD to download SCUM server files..."
        $process = Start-Process -FilePath $steamCmdExe -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
        
        if ($process.ExitCode -eq 0) {
            Write-StatusMessage "SCUM server installation completed successfully." "SUCCESS"
            return $true
        } else {
            Write-ErrorMessage "SCUM server installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-ErrorMessage "Failed to install SCUM server: $($_.Exception.Message)"
        return $false
    }
}

function New-StartBatch {
    Write-StatusMessage "Creating server startup script..."
    
    try {
        $startBatPath = Join-Path $InstallPath "start.bat"
        $batchContent = @"
@echo off
echo Starting SCUM Dedicated Server...
echo Server Port: $Port
echo Query Port: $QueryPort
echo.
cd /d "$InstallPath\SCUM\Binaries\Win64"
start SCUMServer.exe -log -port=$Port -QueryPort=$QueryPort
echo Server startup command executed.
echo Check the server console window for status.
pause
"@
        
        Set-Content -Path $startBatPath -Value $batchContent -Encoding ASCII
        Write-StatusMessage "Server startup script created at: $startBatPath" "SUCCESS"
        return $true
    }
    catch {
        Write-ErrorMessage "Failed to create startup script: $($_.Exception.Message)"
        return $false
    }
}

function Show-Summary {
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "SCUM DEDICATED SERVER SETUP SUMMARY" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Server Port (TCP): $Port" -ForegroundColor White
    Write-Host "Query Port (UDP): $QueryPort" -ForegroundColor White
    Write-Host "Installation Path: $InstallPath" -ForegroundColor White
    Write-Host "SteamCMD Path: $SteamCMDPath" -ForegroundColor White
    Write-Host "`nThe following actions will be performed:" -ForegroundColor Yellow
    Write-Host "• Open firewall ports (TCP:$Port, UDP:$QueryPort)" -ForegroundColor Gray
    Write-Host "• Install Visual C++ Redistributable x64" -ForegroundColor Gray
    Write-Host "• Install DirectX End-User Runtime" -ForegroundColor Gray
    Write-Host "• Download and setup SteamCMD" -ForegroundColor Gray
    Write-Host "• Download and install SCUM Dedicated Server" -ForegroundColor Gray
    Write-Host "• Create server startup script" -ForegroundColor Gray
    Write-Host "`nEstimated time: 20-40 minutes (depending on internet speed)" -ForegroundColor Yellow
    Write-Host "="*60 -ForegroundColor Cyan
}

function Main {
    "SCUM Dedicated Server Setup Log - $(Get-Date)" | Out-File $LogFile
    
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                  SCUM DEDICATED SERVER SETUP                 ║
║                    Automated Installation                    ║
║                    Created by Wick Studio                    ║
║                 GitHub: github.com/wickstudio                ║
║                   Discord: discord.gg/wicks                  ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    if (!(Test-Administrator)) {
        Write-ErrorMessage "This script must be run as Administrator. Please right-click on PowerShell and select 'Run as Administrator'." $true
    }
    
    Write-StatusMessage "Administrator privileges confirmed." "SUCCESS"
    
    Show-Summary
    
    do {
        $confirmation = Read-Host "`nDo you want to continue? (Y/N)"
        $confirmation = $confirmation.ToUpper()
        
        if ($confirmation -eq "N") {
            Write-StatusMessage "Installation cancelled by user."
            exit 0
        }
    } while ($confirmation -ne "Y")
    
    Write-Host "`nStarting installation process..." -ForegroundColor Green
    
    $steps = @(
        { Open-FirewallPorts },
        { Install-VCRedist },
        { Install-DirectX },
        { Install-SteamCMD },
        { Install-SCUMServer },
        { New-StartBatch }
    )
    
    $stepNames = @(
        "Opening firewall ports",
        "Installing Visual C++ Redistributable",
        "Installing DirectX",
        "Installing SteamCMD",
        "Installing SCUM server",
        "Creating startup script"
    )
    
    for ($i = 0; $i -lt $steps.Count; $i++) {
        $stepNumber = $i + 1
        $totalSteps = $steps.Count
        
        Write-Host "`n[$stepNumber/$totalSteps] $($stepNames[$i])..." -ForegroundColor Magenta
        
        if (!(&$steps[$i])) {
            Write-Host "`nSome errors occurred during installation. Check the log file: $LogFile" -ForegroundColor Red
        }
    }
    
    Write-Host "`n" + "="*60 -ForegroundColor Green
    if ($ErrorCount -eq 0) {
        Write-Host "🎉 SCUM SERVER INSTALLATION COMPLETE! 🎉" -ForegroundColor Green
        Write-Host "="*60 -ForegroundColor Green
        Write-Host "`nTo start your server:" -ForegroundColor Yellow
        Write-Host "1. Navigate to: $InstallPath" -ForegroundColor White
        Write-Host "2. Run: start.bat" -ForegroundColor White
        Write-Host "`nYour server will be accessible on:" -ForegroundColor Yellow
        Write-Host "• Server Port: $Port (TCP)" -ForegroundColor White
        Write-Host "• Query Port: $QueryPort (UDP)" -ForegroundColor White
        Write-Host "`nFor configuration, edit files in:" -ForegroundColor Yellow
        Write-Host "$InstallPath\SCUM\Saved\Config\WindowsServer" -ForegroundColor White
    } else {
        Write-Host "⚠️  INSTALLATION COMPLETED WITH $ErrorCount ERROR(S) ⚠️" -ForegroundColor Yellow
        Write-Host "="*60 -ForegroundColor Yellow
        Write-Host "Please check the log file for details: $LogFile" -ForegroundColor White
        Write-Host "You may need to manually complete some steps." -ForegroundColor White
    }
    
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

try {
    Main
}
catch {
    Write-Host "`n`nUNEXPECTED ERROR OCCURRED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    Write-Host "`nScript execution failed. Check the log file for details: $LogFile" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Red
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
finally {
    if ($Host.UI.RawUI) {
        Write-Host "`nScript execution completed. Press any key to close this window..." -ForegroundColor Gray
        try {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        catch {
            Start-Sleep -Seconds 5
        }
    }
}