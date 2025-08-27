@echo off
REM --- This script removes the firewall rule for port 8000 ---

SET RULE_NAME="Django Backend Comms (Port 8000)"

REM Check if the firewall rule exists before trying to delete it
netsh advfirewall firewall show rule name=%RULE_NAME% >nul
IF %ERRORLEVEL%==0 (
    echo Firewall rule '%RULE_NAME%' found. Removing...
    netsh advfirewall firewall delete rule name=%RULE_NAME%
    echo Rule removed successfully.
) ELSE (
    echo Firewall rule '%RULE_NAME%' not found. No action needed.
)

echo.