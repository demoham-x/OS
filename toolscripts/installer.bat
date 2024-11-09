@echo off
:: Check if the script is running with administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal

:: Check for Chocolatey installation
where choco >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Chocolatey is not installed. Installing Chocolatey...

    :: Install Chocolatey via PowerShell
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression"
    
    :: Verify Chocolatey installation
    where choco >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install Chocolatey. Please install it manually from https://chocolatey.org/install
        pause
        exit /b
    )
    echo Chocolatey installed successfully.
) else (
    echo Chocolatey is already installed.
)

:: List of tools to install
set tools=nasm qemu

for %%t in (%tools%) do (
    where %%t >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo %%t is not installed.
        echo Installing %%t via Chocolatey...
        choco install %%t -y
        set "tool_path=C:\Program Files\%%t"
        if exist "%tool_path%" (
            echo Adding %%t to PATH.
            setx PATH "%PATH%;%tool_path%"
        ) else (
            echo %%t installation path not found.
        )
    ) else (
        echo %%t is already installed.
    )
)

echo Installation complete. Restart the terminal if PATH was updated.
endlocal
pause
