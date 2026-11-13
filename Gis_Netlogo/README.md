# NetLogo Indian Map Project

This project demonstrates how to load and display an Indian map in NetLogo using the GIS extension.

## Project Structure

```
Gis_Netlogo/
├── indian_map_model.nlogo    # Main NetLogo model file
├── data/                     # Directory for GIS data files
│   ├── india_boundary.shp    # Indian boundary shapefile (to be downloaded)
│   ├── india_boundary.shx    # Shapefile index file
│   ├── india_boundary.dbf    # Shapefile attribute table
│   ├── india_states.shp      # Indian states shapefile (optional)
│   ├── india_states.shx      # States shapefile index file
│   └── india_states.dbf      # States shapefile attribute table
├── README.md                 # This file
└── setup_instructions.md     # Detailed setup instructions
```

## Prerequisites

1. **NetLogo 6.0 or later** - Download from [NetLogo website](https://ccl.northwestern.edu/netlogo/)
2. **GIS Extension** - Included with NetLogo installation
3. **Indian Map Shapefiles** - Download from appropriate sources (see below)

## Quick Start

1. **Install NetLogo** if you haven't already
2. **Open the model**: Double-click `indian_map_model.nlogo` or open it from within NetLogo
3. **Click "setup"** to initialize the model
4. **Click "go"** to start the simulation (optional - for moving agents)

## Features

- **Indian Map Display**: Shows the outline of India
- **State Boundaries**: Displays state boundaries (if shapefile is available)
- **Major Cities**: Shows major Indian cities with labels
- **Interactive Agents**: Sample agents that move around the map
- **Mouse Interaction**: Click on map areas to get information
- **Basic Statistics**: Reports on land patches, agents, and cities

## Model Components

### Global Variables
- `india-dataset`: Stores the Indian boundary GIS data
- `states-dataset`: Stores the states GIS data
- `india-envelope`: Geographic envelope of the map

### Breeds
- `cities`: Represents major Indian cities
- `agents`: Sample agents that can move around the map

### Patch Properties
- `state-name`: Name of the state the patch belongs to
- `is-land?`: Boolean indicating if the patch is land or water

### City Properties
- `city-name`: Name of the city
- `population`: Population of the city

## Main Procedures

- `setup`: Initializes the model and loads map data
- `load-india-map`: Loads GIS shapefiles and applies them to the world
- `create-basic-india-outline`: Creates a basic India outline when shapefiles are not available
- `go`: Main simulation loop
- `handle-mouse-click`: Handles mouse interactions with the map

## Data Requirements

To get the most accurate map representation, you need to download Indian map shapefiles:

### Recommended Sources:
1. **Natural Earth**: [naturalearthdata.com](https://www.naturalearthdata.com/)
2. **OpenStreetMap**: [download.geofabrik.de](https://download.geofabrik.de/)
3. **Indian Government**: [surveyofindia.gov.in](https://www.surveyofindia.gov.in/)

### Required Files:
- `india_boundary.shp` - Main shapefile with Indian boundary
- `india_boundary.shx` - Shapefile index
- `india_boundary.dbf` - Attribute table
- `india_states.shp` - Optional: State boundaries
- `india_states.shx` - Optional: States index
- `india_states.dbf` - Optional: States attributes

## Usage Instructions

1. **Setup Phase**:
   - Click the "setup" button to initialize the model
   - The model will automatically load GIS data if available
   - If shapefiles are not found, a basic India outline will be created

2. **Simulation Phase**:
   - Click "go" to start the simulation
   - Watch agents move around the map
   - Use "go" button for single steps or "go forever" for continuous simulation

3. **Interaction**:
   - Click on any part of the map to get information about that location
   - Use "reset-colors" to restore original map colors

## Customization

### Adding More Cities
Modify the `create-major-cities` procedure to add more cities:

```netlogo
create-cities 1 [
  set city-name "Your City Name"
  set population 1000000
  setxy x-coordinate y-coordinate
  set color red
  set size 3
  set shape "circle"
]
```

### Changing Agent Behavior
Modify the `move-agent` procedure to change how agents move:

```netlogo
to move-agent
  ; Your custom movement logic here
end
```

### Adding New Features
- Modify patch properties to store additional geographic information
- Add new breeds for different types of entities
- Implement custom visualization features

## Troubleshooting

1. **GIS Extension Not Found**: Ensure you're using NetLogo 6.0+ with GIS extension
2. **Shapefile Loading Errors**: Check that shapefile paths are correct and files are in the data folder
3. **Map Display Issues**: Verify that the coordinate system of your shapefiles is appropriate
4. **Performance Issues**: Large shapefiles may slow down the model - consider simplifying the data

## Next Steps

1. **Download Real Shapefiles**: Replace the basic outline with actual Indian map data
2. **Add More Geographic Data**: Include rivers, mountains, or other geographic features
3. **Implement Specific Models**: Use the map as a base for demographic, economic, or environmental models
4. **Add Data Visualization**: Display statistical data on the map using color coding

## License

This project is for educational purposes. Ensure you have appropriate licenses for any GIS data you use.

## Support

For NetLogo-specific questions, refer to the [NetLogo documentation](https://ccl.northwestern.edu/netlogo/docs/) or [NetLogo users group](https://groups.google.com/forum/#!forum/netlogo-users).
