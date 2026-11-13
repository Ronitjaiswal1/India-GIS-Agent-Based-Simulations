@echo off
echo Setting up NetLogo GIS Model for Indian Regions
echo ================================================

echo.
echo Step 1: Installing Python requirements...
pip install -r requirements.txt

echo.
echo Step 2: Running GIS data processor...
python india_gis_processor.py

echo.
echo Step 3: Setup complete!
echo.
echo Next steps:
echo 1. Download and install NetLogo from: https://ccl.northwestern.edu/netlogo/
echo 2. Open the file: india_region_gis_model.nlogo
echo 3. Click the "setup" button in NetLogo
echo 4. Start exploring the model!
echo.
echo Check the README.md file for detailed instructions.
pause
