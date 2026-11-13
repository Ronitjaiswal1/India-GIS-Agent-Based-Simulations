# Detailed Setup Instructions for NetLogo Indian Map Project

## Step 1: Install NetLogo

1. **Download NetLogo**:
   - Go to [https://ccl.northwestern.edu/netlogo/](https://ccl.northwestern.edu/netlogo/)
   - Download NetLogo 6.0 or later (6.3+ recommended)
   - Install following the standard installation process for your operating system

2. **Verify Installation**:
   - Launch NetLogo
   - Check that the GIS extension is available by typing `extensions [gis]` in the code tab

## Step 2: Download Indian Map Shapefiles

### Option A: Natural Earth Data (Recommended)
1. Go to [https://www.naturalearthdata.com/](https://www.naturalearthdata.com/)
2. Navigate to "Downloads" → "Cultural" → "Admin 0 - Countries"
3. Download "Admin 0 - Countries" (1:50m scale is sufficient)
4. Extract the zip file
5. Look for files related to India or filter for India from the world data

### Option B: OpenStreetMap Data
1. Go to [https://download.geofabrik.de/](https://download.geofabrik.de/)
2. Navigate to Asia → India
3. Download the shapefile format
4. Extract the files

### Option C: Indian Government Sources
1. Visit [https://www.surveyofindia.gov.in/](https://www.surveyofindia.gov.in/)
2. Look for downloadable boundary data
3. Follow their procedures for obtaining boundary data

## Step 3: Prepare the Data Files

1. **Create the data folder** in your project directory:
   ```
   d:\Gis_Netlogo\data\
   ```

2. **Required files for basic functionality**:
   - `india_boundary.shp` - Main shapefile
   - `india_boundary.shx` - Shapefile index
   - `india_boundary.dbf` - Attribute table
   - `india_boundary.prj` - Projection information (optional but recommended)

3. **Optional files for enhanced functionality**:
   - `india_states.shp` - State boundaries
   - `india_states.shx` - State index
   - `india_states.dbf` - State attributes
   - `india_states.prj` - State projection

4. **File naming**: Make sure your files are named exactly as expected by the model, or modify the model code to match your file names.

## Step 4: Prepare Shapefiles for NetLogo

### Using QGIS (Recommended for data processing):

1. **Download QGIS** (free): [https://qgis.org/](https://qgis.org/)

2. **Filter for India**:
   - Open the world countries shapefile in QGIS
   - Use "Select by Attribute" to select India
   - Right-click the layer → "Export" → "Save Selected Features As"
   - Save as `india_boundary.shp`

3. **Simplify geometry** (optional, for better performance):
   - Use "Vector" → "Geometry Tools" → "Simplify"
   - Set tolerance to 0.01 or 0.001 degrees
   - Save the simplified version

4. **Check coordinate system**:
   - Ensure the shapefile uses WGS84 (EPSG:4326) for best compatibility
   - If not, reproject using "Vector" → "Data Management Tools" → "Reproject Layer"

### Using alternative tools:
- **ogr2ogr** (command line): Can filter and reproject shapefiles
- **MapShaper** (online): [https://mapshaper.org/](https://mapshaper.org/) for simplifying geometries

## Step 5: Configure the NetLogo Model

1. **Open the model**:
   - Double-click `indian_map_model.nlogo`
   - Or open NetLogo and use File → Open

2. **Check file paths**:
   - Verify that the paths in the code match your file structure
   - Look for lines like: `"data/india_boundary.shp"`

3. **Modify if necessary**:
   - If your files have different names, update the code accordingly
   - For example, change `"data/india_boundary.shp"` to `"data/your_filename.shp"`

## Step 6: Test the Model

1. **Initial test**:
   - Click the "setup" button
   - Check for any error messages in the command center
   - Verify that the map displays correctly

2. **Common issues and solutions**:
   - **"File not found"**: Check file paths and names
   - **"Extension not found"**: Ensure you're using NetLogo 6.0+
   - **Map doesn't display**: Check coordinate system and data format
   - **Performance issues**: Consider simplifying the shapefile

## Step 7: Customize the Model

### Adding more detailed state data:
1. Download state-level shapefiles for India
2. Place them in the data folder
3. Modify the `load-india-map` procedure to load state data
4. Update the `gis:apply-coverage` calls to use state attributes

### Adding cities data:
1. Download city point data for India
2. Modify the `create-major-cities` procedure
3. Load city data from shapefile instead of hardcoding

### Enhancing visualization:
1. Add color schemes based on data attributes
2. Implement different visualization modes
3. Add legends and labels

## Step 8: Advanced Configuration

### Memory optimization:
- For large shapefiles, consider increasing NetLogo's memory:
  - Add `-Xmx2g` to NetLogo's startup parameters for 2GB memory
  - Or use simpler, generalized shapefiles

### Coordinate system handling:
- Ensure all shapefiles use the same coordinate system
- Consider using projected coordinates for better distance calculations
- Test with different projections if needed

### Performance optimization:
- Use simplified geometries for better performance
- Consider loading only necessary attributes
- Use appropriate scale (1:50m rather than 1:10m for overview maps)

## Troubleshooting Guide

### Common Errors:

1. **"gis:load-dataset: couldn't find file"**:
   - Check that the file exists in the specified path
   - Verify the file extension is correct (.shp)
   - Ensure the file is not corrupted

2. **"gis:set-world-envelope: envelope is empty"**:
   - The shapefile might be empty or corrupted
   - Try loading a different shapefile
   - Check the coordinate system

3. **Map displays but looks wrong**:
   - Coordinate system mismatch
   - Try reprojecting to WGS84
   - Check the shapefile in QGIS first

4. **Performance is very slow**:
   - Simplify the shapefile geometry
   - Use a smaller scale version
   - Reduce the number of features

### Getting Help:
- NetLogo Users Group: [https://groups.google.com/forum/#!forum/netlogo-users](https://groups.google.com/forum/#!forum/netlogo-users)
- NetLogo Documentation: [https://ccl.northwestern.edu/netlogo/docs/](https://ccl.northwestern.edu/netlogo/docs/)
- GIS Extension Documentation: [https://ccl.northwestern.edu/netlogo/docs/gis.html](https://ccl.northwestern.edu/netlogo/docs/gis.html)

## Final Verification

1. **Model loads without errors**
2. **Map displays Indian boundaries**
3. **Cities are visible and labeled**
4. **Agents move around the map**
5. **Mouse interaction works**
6. **All buttons function correctly**

Once you've completed these steps, your NetLogo Indian map interface should be fully functional!
