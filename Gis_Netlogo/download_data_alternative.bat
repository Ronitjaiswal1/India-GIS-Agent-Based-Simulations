@echo off
echo NetLogo Indian Map Data Download (Alternative Method)
echo ================================================

echo Creating data directory...
if not exist "data" mkdir data

echo.
echo Downloading Natural Earth data using curl...
echo This may take a few minutes depending on your internet connection.
echo.

echo Downloading countries data...
curl -L -o "data\countries.zip" "https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_0_countries.zip"

if exist "data\countries.zip" (
    echo Extracting countries data...
    powershell -command "Expand-Archive -Path 'data\countries.zip' -DestinationPath 'data\countries' -Force"
    echo Countries data extracted successfully
) else (
    echo Failed to download countries data
)

echo.
echo Downloading states data...
curl -L -o "data\states.zip" "https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_1_states_provinces_lakes.zip"

if exist "data\states.zip" (
    echo Extracting states data...
    powershell -command "Expand-Archive -Path 'data\states.zip' -DestinationPath 'data\states' -Force"
    echo States data extracted successfully
) else (
    echo Failed to download states data
)

echo.
echo Creating extraction instructions...
echo # Instructions to Extract India Data > "data\extraction_instructions.txt"
echo. >> "data\extraction_instructions.txt"
echo If you have QGIS installed: >> "data\extraction_instructions.txt"
echo 1. Open QGIS >> "data\extraction_instructions.txt"
echo 2. Load data/countries/ne_50m_admin_0_countries.shp >> "data\extraction_instructions.txt"
echo 3. Select by expression: "NAME" = 'India' >> "data\extraction_instructions.txt"
echo 4. Export as 'india_boundary.shp' in data folder >> "data\extraction_instructions.txt"
echo. >> "data\extraction_instructions.txt"
echo For states data: >> "data\extraction_instructions.txt"
echo 1. Load data/states/ne_50m_admin_1_states_provinces.shp >> "data\extraction_instructions.txt"
echo 2. Select by expression: "admin" = 'India' >> "data\extraction_instructions.txt"
echo 3. Export as 'india_states.shp' in data folder >> "data\extraction_instructions.txt"

echo.
echo Next Steps:
echo 1. Use QGIS to filter the data for India (see data\extraction_instructions.txt)
echo 2. Or manually download from: https://www.naturalearthdata.com/downloads/50m-cultural-vectors/
echo 3. Place india_boundary.shp and india_states.shp in the data directory
echo 4. Run the NetLogo model
echo.
echo For more detailed instructions, see setup_instructions.md
echo.
pause
