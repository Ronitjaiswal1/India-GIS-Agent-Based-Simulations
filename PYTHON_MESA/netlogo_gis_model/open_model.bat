@echo off
echo Opening NetLogo GIS Model for Indian Regions
echo ============================================

REM Check if NetLogo is installed in common locations
set NETLOGO_PATH=""

if exist "C:\Program Files\NetLogo 6.4.0\NetLogo 6.4.0.exe" (
    set NETLOGO_PATH="C:\Program Files\NetLogo 6.4.0\NetLogo 6.4.0.exe"
) else if exist "C:\Program Files\NetLogo 6.3.0\NetLogo 6.3.0.exe" (
    set NETLOGO_PATH="C:\Program Files\NetLogo 6.3.0\NetLogo 6.3.0.exe"
) else if exist "C:\Program Files\NetLogo 6.2.2\NetLogo 6.2.2.exe" (
    set NETLOGO_PATH="C:\Program Files\NetLogo 6.2.2\NetLogo 6.2.2.exe"
) else if exist "C:\Program Files\NetLogo 6.1.1\NetLogo 6.1.1.exe" (
    set NETLOGO_PATH="C:\Program Files\NetLogo 6.1.1\NetLogo 6.1.1.exe"
) else if exist "C:\Program Files\NetLogo 6.0.4\NetLogo 6.0.4.exe" (
    set NETLOGO_PATH="C:\Program Files\NetLogo 6.0.4\NetLogo 6.0.4.exe"
)

if %NETLOGO_PATH%=="" (
    echo NetLogo not found in standard locations.
    echo Please install NetLogo 6.0+ from: https://ccl.northwestern.edu/netlogo/
    echo Then open the file manually: india_gis_standalone.nlogo
    pause
    exit
)

echo Found NetLogo at: %NETLOGO_PATH%
echo Opening model: india_gis_standalone.nlogo
echo.

REM Open the model file
start %NETLOGO_PATH% "india_gis_standalone.nlogo"

echo Model opened in NetLogo!
echo.
echo Next steps:
echo 1. Click the "Setup" button to load Indian data
echo 2. Click "Go" to start the simulation
echo 3. Try the display buttons (set-display-states, set-display-population)
echo.
echo Check HOW_TO_RUN.md for detailed instructions.
pause
