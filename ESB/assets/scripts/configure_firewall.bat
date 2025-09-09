@echo off
REM --- This script opens port 8000 for server-to-server Django communication ---

SET RULE_NAME="Django Backend Comms (Port 8000)"

REM Check if the firewall rule already exists
netsh advfirewall firewall show rule name=%RULE_NAME% >nul
IF %ERRORLEVEL%==0 (
    echo Firewall rule '%RULE_NAME%' already exists. No action needed.
) ELSE (
    echo Creating firewall rule '%RULE_NAME%'...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=8000
    echo.
    echo Firewall rule created successfully. Port 8000 is now open for inbound connections.
)

echo.