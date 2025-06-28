@echo off
title SCUM Server Setup - Administrator Required

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ===================================================
    echo         ADMINISTRATOR PRIVILEGES REQUIRED
    echo ===================================================
    echo.
    echo This script needs to run as Administrator to:
    echo   - Configure Windows Firewall
    echo   - Install required dependencies
    echo   - Set up SCUM Dedicated Server
    echo.
    echo Requesting administrator privileges...
    echo.
    
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

echo.
echo ===================================================
echo       ADMINISTRATOR PRIVILEGES CONFIRMED
echo ===================================================
echo.

cd /d "%~dp0"

echo Starting SCUM Server Setup Script...
echo Current directory: %CD%
echo Batch file location: %~dp0
echo.

echo Files in current directory:
dir /b *.ps1 *.bat
echo.

echo Checking for PowerShell script...

if not exist "Setup-SCUMServer.ps1" (
    echo ERROR: Setup-SCUMServer.ps1 NOT found!
    echo.
    echo Full directory listing:
    dir /a
    echo.
    pause
    exit /b 1
)

echo SUCCESS: Setup-SCUMServer.ps1 found successfully!
for %%F in ("Setup-SCUMServer.ps1") do echo File size: %%~zF bytes
echo.
echo Continuing with PowerShell execution...

echo Running PowerShell script as Administrator...
echo Please wait while the setup process completes...
echo.

echo Creating temporary PowerShell wrapper script...
echo try { > "%temp%\run_scum_setup.ps1"
echo     Write-Host "PowerShell script starting..." -ForegroundColor Green >> "%temp%\run_scum_setup.ps1"
echo     Set-Location '%~dp0' >> "%temp%\run_scum_setup.ps1"
echo     Write-Host "Working directory: $PWD" -ForegroundColor Cyan >> "%temp%\run_scum_setup.ps1"
echo     if (Test-Path '.\Setup-SCUMServer.ps1') { >> "%temp%\run_scum_setup.ps1"
echo         Write-Host "Found Setup-SCUMServer.ps1, executing..." -ForegroundColor Green >> "%temp%\run_scum_setup.ps1"
echo         ^& '.\Setup-SCUMServer.ps1' >> "%temp%\run_scum_setup.ps1"
echo     } else { >> "%temp%\run_scum_setup.ps1"
echo         Write-Host "ERROR: Setup-SCUMServer.ps1 not found in $PWD" -ForegroundColor Red >> "%temp%\run_scum_setup.ps1"
echo         Get-ChildItem *.ps1 ^| Format-Table Name, Length >> "%temp%\run_scum_setup.ps1"
echo         throw "PowerShell script file not found" >> "%temp%\run_scum_setup.ps1"
echo     } >> "%temp%\run_scum_setup.ps1"
echo     exit 0 >> "%temp%\run_scum_setup.ps1"
echo } catch { >> "%temp%\run_scum_setup.ps1"
echo     Write-Host "CRITICAL ERROR in PowerShell script:" -ForegroundColor Red >> "%temp%\run_scum_setup.ps1"
echo     Write-Host $_.Exception.Message -ForegroundColor Red >> "%temp%\run_scum_setup.ps1"
echo     Write-Host "Press any key to return to batch script..." -ForegroundColor Yellow >> "%temp%\run_scum_setup.ps1"
echo     $null = $Host.UI.RawUI.ReadKey^("NoEcho,IncludeKeyDown"^) >> "%temp%\run_scum_setup.ps1"
echo     exit 1 >> "%temp%\run_scum_setup.ps1"
echo } >> "%temp%\run_scum_setup.ps1"

if not exist "%temp%\run_scum_setup.ps1" (
    echo ERROR: Failed to create temporary PowerShell script!
    echo Check if you have write permissions to %temp%
    pause
    exit /b 1
)

echo Temporary script created successfully.
echo Script location: %temp%\run_scum_setup.ps1
echo.

echo Attempting to run PowerShell script directly...
echo You should see a UAC prompt - please accept it to continue.
echo.

powershell -Command "& {try {Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%temp%\run_scum_setup.ps1\"' -Verb RunAs -Wait; Write-Host 'PowerShell execution completed'} catch {Write-Host 'PowerShell execution failed:' $_.Exception.Message; pause}}"

set POWERSHELL_EXIT_CODE=%errorlevel%

echo.
echo PowerShell execution returned with exit code: %POWERSHELL_EXIT_CODE%
echo.

if exist "%temp%\run_scum_setup.ps1" (
    echo Cleaning up temporary script...
    del "%temp%\run_scum_setup.ps1" 2>nul
) else (
    echo Warning: Temporary script not found for cleanup.
)

if %POWERSHELL_EXIT_CODE% equ 0 (
    echo.
    echo ===================================================
    echo                SETUP COMPLETED SUCCESSFULLY
    echo ===================================================
    echo.
    echo Your SCUM server installation is complete!
    echo Check the PowerShell window output for details.
    echo.
    if exist "scum-server-setup.log" (
        echo Log file created: scum-server-setup.log
    )
) else (
    echo.
    echo ===================================================
    echo              SETUP FAILED WITH ERRORS
    echo ===================================================
    echo.
    echo PowerShell Exit Code: %POWERSHELL_EXIT_CODE%
    echo.
    echo Possible causes:
    echo   - User cancelled the UAC prompt
    echo   - PowerShell script encountered errors
    echo   - Required dependencies missing
    echo   - Network connectivity issues
    echo   - Insufficient permissions
    echo.
    echo Solutions:
    echo   1. Check the log file: scum-server-setup.log
    echo   2. Make sure you accept the UAC prompt
    echo   3. Check your internet connection
    echo   4. Run Windows Updates
    echo   5. Temporarily disable antivirus
    echo.
    
    if exist "scum-server-setup.log" (
        echo Press any key to view the log file...
        pause >nul
        echo.
        echo =============== LOG FILE CONTENTS ===============
        type "scum-server-setup.log"
        echo.
        echo ============== END OF LOG FILE ================
        echo.
    ) else (
        echo Log file not found. The PowerShell script may not have started properly.
    )
    
    echo.
    echo If the problem persists, try the manual method:
    echo   1. Right-click on PowerShell and select "Run as Administrator"
    echo   2. Navigate to this folder: cd "%CD%"
    echo   3. Run: .\Setup-SCUMServer.ps1
    echo.
    echo Would you like to try a different approach? (Y/N)
    set /p RETRY_CHOICE=Enter choice: 
    if /i "%RETRY_CHOICE%"=="Y" (
        echo.
        echo Trying alternative method - running PowerShell directly...
        echo Please manually accept any UAC prompts that appear.
        echo.
        powershell -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%CD%\Setup-SCUMServer.ps1\"' -Verb RunAs"
        echo.
        echo Alternative method attempted. Check if a PowerShell window opened.
        echo If successful, the installation will continue in the PowerShell window.
    )
)

echo.
echo Press any key to exit...
pause >nul 