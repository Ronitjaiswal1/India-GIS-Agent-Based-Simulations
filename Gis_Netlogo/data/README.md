# Data Directory

This directory should contain the GIS shapefiles for the Indian map.

## Required Files

For the basic Indian boundary map, you need:

- `india_boundary.shp` - Main shapefile with Indian boundary geometry
- `india_boundary.shx` - Shapefile index file
- `india_boundary.dbf` - Attribute table file
- `india_boundary.prj` - Projection information (recommended)

## Optional Files

For enhanced functionality with state boundaries:

- `india_states.shp` - State boundaries shapefile
- `india_states.shx` - State boundaries index file
- `india_states.dbf` - State boundaries attribute table
- `india_states.prj` - State boundaries projection information

## Data Sources

### Recommended Sources:
1. **Natural Earth**: https://www.naturalearthdata.com/
   - Free, high-quality geographic data
   - Multiple scales available
   - Regular updates

2. **OpenStreetMap**: https://download.geofabrik.de/
   - Community-driven data
   - Very detailed
   - Free to use

3. **Indian Government Sources**:
   - Survey of India: https://www.surveyofindia.gov.in/
   - Official government data
   - May require permissions

## File Preparation

1. **Download** the appropriate shapefiles from one of the sources above
2. **Extract** the files to this directory
3. **Rename** the files to match the expected names:
   - Main boundary: `india_boundary.*`
   - States: `india_states.*`
4. **Verify** that all required files (.shp, .shx, .dbf) are present
5. **Test** by running the NetLogo model

## Notes

- All shapefiles should use the same coordinate system (WGS84 recommended)
- For better performance, consider simplifying complex geometries
- Ensure you have the right to use the data according to its license
- The model will work without shapefiles but will show a basic outline instead

## File Size Considerations

- Keep shapefiles reasonably sized (< 50MB) for good performance
- Use appropriate level of detail for your use case
- Consider using simplified versions for overview maps
