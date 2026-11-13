# NetLogo GIS Model for Indian Regions

## Overview
This NetLogo model simulates various aspects of Indian geography, demographics, and socio-economic patterns using GIS data.

## Generated Data Files

### Core GIS Data
- `indian_states_data.csv` - Complete data for all Indian states including coordinates, area, and population density
- `indian_major_cities.csv` - Data for 30 major Indian cities with populations and classifications
- `netlogo_coordinates.csv` - NetLogo world coordinates for all states

### Integration Files
- `netlogo_data_loader.nls` - NetLogo include file with procedures to load and use the data
- `migration_patterns.csv` - Sample inter-state migration data
- `economic_indicators.csv` - Sample economic data for states

## Data Sources
- Administrative boundaries: Survey of India
- Population data: Census of India 2011
- City data: Various official sources
- Coordinates: Geographic coordinate system (WGS84)

## Usage Instructions

### 1. NetLogo Setup
1. Download and install NetLogo 6.0+ from https://ccl.northwestern.edu/netlogo/
2. Place all generated files in your NetLogo model directory
3. Include the data loader in your model: `__includes ["gis_data/netlogo_data_loader.nls"]`

### 2. Basic Model Integration
```netlogo
; In your setup procedure
to setup
  clear-all
  load-indian-gis-data
  setup-real-indian-states
  setup-real-indian-cities
  reset-ticks
end
```

### 3. Using the Data
```netlogo
; Get population density for a state
let pop-density get-state-population-density "Maharashtra"

; Get coordinates for a state
let coords get-state-coordinates "Delhi"

; Get city information
let city-info get-city-data "Mumbai"
```

## Model Features

### Geographic Features
- Accurate state boundaries and coordinates
- Major cities with population data
- Population density visualization
- Urban/rural classification

### Demographic Features
- Population density by state
- Migration patterns between states
- Urban population distribution

### Economic Features
- GDP per capita by state
- Unemployment rates
- Literacy rates

## Customization Options

### Adding New Data
1. Create CSV files with your data
2. Add loading procedures in `netlogo_data_loader.nls`
3. Use the data in your model logic

### Modifying Coordinates
- Adjust world size by changing coordinate scaling
- Add more precise coordinate mappings
- Include district-level data

### Extending the Model
- Add more cities or towns
- Include geographic features (rivers, mountains)
- Add time-series data
- Include network connections between cities

## Sample Use Cases

### 1. Migration Simulation
```netlogo
; Simulate people moving between states
ask agents [
  let origin-state home-state
  let destination-state find-migration-destination origin-state
  if destination-state != nobody [
    migrate-to destination-state
  ]
]
```

### 2. Economic Development
```netlogo
; Model economic growth based on state characteristics
ask patches [
  let state-name [state-name] of self
  let gdp get-state-gdp state-name
  let growth-rate calculate-growth-rate gdp literacy-rate
  update-development-level growth-rate
]
```

### 3. Urban Planning
```netlogo
; Simulate urban expansion around major cities
ask cities [
  let growth-rate calculate-urban-growth city-population
  expand-urban-area growth-rate
]
```

## Technical Details

### Coordinate System
- Input: Geographic coordinates (WGS84)
- Output: NetLogo world coordinates (-50 to 50)
- Projection: Simplified linear scaling

### Data Format
- CSV files with headers
- UTF-8 encoding
- Comma-separated values
- Numeric data in standard format

### Performance Considerations
- Tables used for fast data lookup
- Coordinate conversion cached
- Efficient state-patch mapping

## Generated: 2025-07-16 17:07:59

## Support
For questions or issues:
1. Check NetLogo documentation
2. Review the generated data files
3. Modify the data loader procedures as needed
