# Manual Download Guide for Indian Map Data

If the automated download scripts are not working, follow these manual steps:

## Method 1: Direct Downloads (Recommended)

### Step 1: Download Countries Data
1. Go to: https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_0_countries.zip
2. Download the file
3. Extract to `data\countries\` folder

### Step 2: Download States Data
1. Go to: https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_1_states_provinces_lakes.zip
2. Download the file
3. Extract to `data\states\` folder

## Method 2: Natural Earth Website

### Step 1: Visit Natural Earth
1. Go to: https://www.naturalearthdata.com/
2. Click "Downloads" in the top menu
3. Select "Cultural" from the dropdown

### Step 2: Download Countries
1. Look for "Admin 0 – Countries" section
2. Download the 1:50m scale version (good balance of detail and performance)
3. Extract to `data\countries\` folder

### Step 3: Download States/Provinces
1. Look for "Admin 1 – States, Provinces" section
2. Download the 1:50m scale version
3. Extract to `data\states\` folder

## Method 3: Alternative Sources

### OpenStreetMap Data
1. Go to: https://download.geofabrik.de/
2. Navigate to Asia → India
3. Download the shapefile format
4. Extract to `data\osm\` folder

### Indian Government Sources
1. Visit: https://www.surveyofindia.gov.in/
2. Look for downloadable boundary data
3. Follow their procedures for obtaining data

## Extracting India Data

Once you have the world data, you need to extract just India:

### Using QGIS (Recommended)
1. **Install QGIS** from https://qgis.org/ (free)
2. **Open QGIS**
3. **Load the countries shapefile**:
   - Drag `data\countries\ne_50m_admin_0_countries.shp` into QGIS
4. **Filter for India**:
   - Right-click the layer → "Open Attribute Table"
   - Click "Select features using an expression" (calculator icon)
   - Enter: `"NAME" = 'India'`
   - Click "Select features"
5. **Export India data**:
   - Right-click the layer → "Export" → "Save Selected Features As"
   - Format: ESRI Shapefile
   - File name: `data\india_boundary.shp`
   - Click "OK"

### For States Data
1. **Load the states shapefile**:
   - Drag `data\states\ne_50m_admin_1_states_provinces.shp` into QGIS
2. **Filter for Indian states**:
   - Open attribute table
   - Select by expression: `"admin" = 'India'`
3. **Export Indian states**:
   - Save selected features as `data\india_states.shp`

## Quick Alternative: Pre-filtered Data

If you can't use QGIS, you can find pre-filtered India data from:

1. **DataMeet** (Indian open data community):
   - https://github.com/datameet/maps
   - Has ready-to-use Indian boundary and state shapefiles

2. **Humanitarian Data Exchange**:
   - https://data.humdata.org/
   - Search for "India administrative boundaries"

3. **OpenStreetMap Extracts**:
   - https://download.geofabrik.de/asia/india.html
   - Pre-filtered for India

## Final File Structure

After extraction, your data folder should contain:
```
data/
├── india_boundary.shp    # Indian national boundary
├── india_boundary.shx    # Shapefile index
├── india_boundary.dbf    # Attribute table
├── india_boundary.prj    # Projection info (optional)
├── india_states.shp      # Indian state boundaries
├── india_states.shx      # States index
├── india_states.dbf      # States attributes
└── india_states.prj      # States projection (optional)
```

## Testing the Data

1. **Open NetLogo**
2. **Load the model**: `india_advanced_simulation.nlogo`
3. **Click "setup"**
4. **Verify the map displays correctly**

## Troubleshooting

- **Files not loading**: Check file names match exactly
- **Map looks wrong**: Verify coordinate system is WGS84
- **Performance issues**: Use simplified geometries
- **Missing features**: Check attribute table for correct field names

## Need Help?

- Check `setup_instructions.md` for detailed setup guide
- Visit NetLogo user forums for technical support
- QGIS has extensive documentation and tutorials online
