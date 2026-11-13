# PowerShell Script to Download Indian Map Data
# This script helps download and prepare Indian map shapefiles for NetLogo

Write-Host "NetLogo Indian Map Data Setup Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Check if data directory exists
if (-not (Test-Path "data")) {
    Write-Host "Creating data directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "data" -Force
}

# Function to download file
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        Write-Host "Downloading from: $Url" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Host "Downloaded successfully: $OutputPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to download: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Natural Earth Data URLs (50m scale - good balance of detail and performance)
$naturalEarthCountries = "https://www.naturalearthdata.com/http/www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip"
$naturalEarthStates = "https://www.naturalearthdata.com/http/www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_1_states_provinces.zip"

# Alternative direct download URLs
$altCountriesUrl = "https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_0_countries.zip"
$altStatesUrl = "https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_1_states_provinces_lakes.zip"

Write-Host "`nDownloading Natural Earth data..." -ForegroundColor Yellow
Write-Host "This may take a few minutes depending on your internet connection." -ForegroundColor Yellow

# Download countries data
Write-Host "Trying to download countries data..." -ForegroundColor Cyan
$countriesDownloaded = $false

if (Download-File -Url $naturalEarthCountries -OutputPath "data\countries.zip") {
    $countriesDownloaded = $true
} elseif (Download-File -Url $altCountriesUrl -OutputPath "data\countries.zip") {
    $countriesDownloaded = $true
} else {
    Write-Host "Failed to download countries data from both sources" -ForegroundColor Red
}

if ($countriesDownloaded) {
    Write-Host "Extracting countries data..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path "data\countries.zip" -DestinationPath "data\countries" -Force
        Write-Host "Countries data extracted successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to extract countries data: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Download states data
Write-Host "Trying to download states data..." -ForegroundColor Cyan
$statesDownloaded = $false

if (Download-File -Url $naturalEarthStates -OutputPath "data\states.zip") {
    $statesDownloaded = $true
} elseif (Download-File -Url $altStatesUrl -OutputPath "data\states.zip") {
    $statesDownloaded = $true
} else {
    Write-Host "Failed to download states data from both sources" -ForegroundColor Red
}

if ($statesDownloaded) {
    Write-Host "Extracting states data..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path "data\states.zip" -DestinationPath "data\states" -Force
        Write-Host "States data extracted successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to extract states data: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to create a simple India shapefile filter instruction
function Create-IndiaFilterInstructions {
    $instructions = @"
# Instructions to Extract India Data

If you have QGIS installed, you can automatically filter the data for India:

1. Open QGIS
2. Load the countries shapefile: data/countries/ne_50m_admin_0_countries.shp
3. Open the attribute table
4. Use 'Select by expression' and enter: "NAME" = 'India'
5. Right-click the layer → Export → Save Selected Features As
6. Save as 'india_boundary.shp' in the data folder

For states:
1. Load the states shapefile: data/states/ne_50m_admin_1_states_provinces.shp
2. Use 'Select by expression' and enter: "admin" = 'India'
3. Export selected features as 'india_states.shp' in the data folder

Alternative: Manual download from these working links:
- Countries: https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_0_countries.zip
- States: https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_1_states_provinces_lakes.zip
"@
    
    $instructions | Out-File -FilePath "data\extraction_instructions.txt" -Encoding UTF8
    Write-Host "Created extraction instructions file: data\extraction_instructions.txt" -ForegroundColor Green
}

# Create extraction instructions
Create-IndiaFilterInstructions

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Use QGIS or similar tool to filter the data for India" -ForegroundColor White
Write-Host "2. Export the filtered data as 'india_boundary.shp' and 'india_states.shp'" -ForegroundColor White
Write-Host "3. Place these files in the data directory" -ForegroundColor White
Write-Host "4. Run the NetLogo model" -ForegroundColor White

Write-Host "`nAlternative: Manual Download Links" -ForegroundColor Yellow
Write-Host "Countries: https://www.naturalearthdata.com/downloads/50m-cultural-vectors/" -ForegroundColor Cyan
Write-Host "States: https://www.naturalearthdata.com/downloads/50m-cultural-vectors/" -ForegroundColor Cyan

Write-Host "`nFor more detailed instructions, see setup_instructions.md" -ForegroundColor Green

# Check if required tools are available
Write-Host "`nChecking for required tools..." -ForegroundColor Yellow

# Check for NetLogo installation
$netlogoPath = Get-Command "NetLogo*" -ErrorAction SilentlyContinue
if ($netlogoPath) {
    Write-Host "✓ NetLogo found" -ForegroundColor Green
} else {
    Write-Host "✗ NetLogo not found - please install from https://ccl.northwestern.edu/netlogo/" -ForegroundColor Red
}

# Check for QGIS installation
$qgisPath = Get-Command "qgis*" -ErrorAction SilentlyContinue
if ($qgisPath) {
    Write-Host "✓ QGIS found" -ForegroundColor Green
} else {
    Write-Host "! QGIS not found - recommended for data processing. Download from https://qgis.org/" -ForegroundColor Yellow
}

Write-Host "`nSetup script completed!" -ForegroundColor Green
