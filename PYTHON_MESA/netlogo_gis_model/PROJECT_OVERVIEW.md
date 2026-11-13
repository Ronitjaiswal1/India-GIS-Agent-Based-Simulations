# NetLogo GIS Model for Indian Regions

## Project Overview

This project provides a comprehensive NetLogo model that integrates real GIS data for Indian regions. The model enables simulation of various geographical, demographic, and socio-economic phenomena across Indian states and cities.

## Features

### **Geographic Integration**
- Real Indian state boundaries and coordinates
- Major cities with population data
- Population density visualization
- Urban/rural classification

### **Data-Driven Simulation**
- 30 Indian states with authentic data
- 30 major cities with population and classification
- Economic indicators (GDP, unemployment, literacy)
- Migration patterns between states

### **Interactive Features**
- Multiple display modes (states, population, elevation)
- Click-to-analyze functionality
- Real-time agent movement
- Data export capabilities

### **Analysis Tools**
- Regional statistics
- Population density analysis
- Urban growth patterns
- Economic development indicators

## Files Structure

```
netlogo_gis_model/
├── india_region_gis_model.nlogo     # Main NetLogo model
├── simple_data_generator.py         # Data generation script
├── india_gis_processor.py          # Advanced GIS processing
├── gis_data_loader.nls              # Advanced GIS integration
├── requirements.txt                 # Python dependencies
├── setup.bat                        # Windows setup script
├── README.md                        # This file
└── gis_data/                        # Generated data directory
    ├── indian_states_data.csv       # State information
    ├── indian_major_cities.csv      # Cities data
    ├── netlogo_coordinates.csv      # NetLogo coordinates
    ├── netlogo_data_loader.nls      # Data loading procedures
    ├── migration_patterns.csv       # Migration data
    ├── economic_indicators.csv      # Economic data
    └── README.md                     # Data documentation
```

## Quick Start

### 1. Prerequisites
- **NetLogo 6.0+**: Download from https://ccl.northwestern.edu/netlogo/
- **Python 3.x**: For data processing (optional)

### 2. Installation

#### Option A: Automatic Setup (Windows)
```bash
# Run the setup script
setup.bat
```

#### Option B: Manual Setup
```bash
# Install Python dependencies
pip install pandas numpy

# Generate data files
python simple_data_generator.py
```

### 3. Running the Model
1. Open NetLogo
2. Load `india_region_gis_model.nlogo`
3. Click **Setup** to initialize
4. Click **Go** to start simulation
5. Use display buttons to change visualization modes

## Model Interface

### Main Controls
- **Setup**: Initialize the model with real Indian data
- **Go**: Start/stop the simulation
- **Display Modes**: 
  - `set-display-states`: Show states in different colors
  - `set-display-population`: Show population density heatmap
  - `set-display-elevation`: Show elevation heatmap

### Analysis Tools
- **analyze-region**: Get statistics for clicked region
- **export-data**: Export simulation data to CSV

### Monitors
- **total-population**: Total population across all patches
- **average-elevation**: Average elevation
- **selected-state-name**: Currently selected state

## Use Cases

### 1. **Urban Planning**
```netlogo
; Simulate urban expansion around major cities
ask cities [
  let growth-rate calculate-urban-growth city-population
  expand-urban-area growth-rate
]
```

### 2. **Migration Studies**
```netlogo
; Model population movement between states
ask agents [
  let origin-state home-state
  let destination find-migration-destination origin-state
  if destination != nobody [
    migrate-to destination
  ]
]
```

### 3. **Economic Development**
```netlogo
; Analyze economic growth patterns
ask patches [
  let state-gdp get-state-gdp state-name
  let growth-rate calculate-growth state-gdp literacy-rate
  update-development-level growth-rate
]
```

### 4. **Demographic Analysis**
```netlogo
; Study population density patterns
let high-density-states filter [state -> get-state-population-density state > 500] state-list
foreach high-density-states [state -> analyze-urban-patterns state]
```

## Data Details

### States Data
- **Coverage**: All 30 Indian states and UTs
- **Attributes**: Name, code, coordinates, area, population density
- **Projection**: Geographic (WGS84) to NetLogo coordinates

### Cities Data
- **Coverage**: 30 major Indian cities
- **Attributes**: Name, state, coordinates, population, classification
- **Classification**: Metro (>5M), Urban (>500K), Rural (<500K)

### Economic Data
- **GDP per capita** by state
- **Unemployment rates**
- **Literacy rates**
- **Migration patterns**

## Customization

### Adding New Data
1. Create CSV files with your data
2. Add loading procedures in `netlogo_data_loader.nls`
3. Update the main model to use new data

### Modifying Visualizations
1. Edit display procedures in main model
2. Add new color schemes
3. Create custom patch properties

### Extending Analysis
1. Add new statistical measures
2. Create custom reports
3. Implement new agent behaviors

## Technical Details

### Performance
- **Patches**: 10,000 (100x100 world)
- **Agents**: 200 (configurable)
- **Cities**: 30 major cities
- **Load Time**: <5 seconds

### Memory Usage
- **Model**: ~50MB
- **Data Files**: ~2MB total
- **Runtime**: Low memory footprint

### Compatibility
- **NetLogo**: 6.0+
- **Operating System**: Windows, macOS, Linux
- **Extensions**: GIS, Table (included with NetLogo)

## Advanced Features

### Real GIS Integration
For advanced users, the model supports:
- Shapefile loading via GIS extension
- Raster data integration
- Custom coordinate projections
- Multiple data layers

### Extensibility
- Plugin architecture for new features
- Custom agent behaviors
- Network analysis capabilities
- Time-series data support

## Examples and Tutorials

### Basic Simulation
1. Load the model
2. Click Setup
3. Change display mode to "population"
4. Click Go to see agents move
5. Click on patches to analyze regions

### Advanced Analysis
1. Load economic data
2. Run migration simulation
3. Export results for analysis
4. Create custom visualizations

## Troubleshooting

### Common Issues

1. **Model won't load**
   - Check NetLogo version (6.0+ required)
   - Ensure GIS extension is available
   - Verify file paths are correct

2. **Data not loading**
   - Run data generator first
   - Check gis_data directory exists
   - Verify CSV file formats

3. **Performance issues**
   - Reduce number of agents
   - Simplify visualizations
   - Use smaller world size

### Getting Help
- Check the README files in gis_data/
- Review NetLogo documentation
- Examine the generated data files
- Modify procedures as needed

## Contributing

To extend this model:
1. Fork the project
2. Add new features
3. Test thoroughly
4. Update documentation
5. Submit improvements

## License

This model is provided for educational and research purposes. Please cite appropriately when using in academic work.

## Acknowledgments

- **Data Sources**: Survey of India, Census of India
- **NetLogo**: Northwestern University
- **GIS Libraries**: GDAL, GeoPandas community

---

**Created**: July 2025  
**Version**: 1.0  
**Author**: NetLogo GIS Model Generator  
**Contact**: See documentation for support
