"""
Simplified GIS Data Generator for NetLogo India Model
This script creates mock GIS data without requiring complex dependencies
"""

import os
import pandas as pd
import numpy as np
import json
from datetime import datetime

class SimpleIndiaDataGenerator:
    def __init__(self, data_dir="gis_data"):
        self.data_dir = data_dir
        os.makedirs(self.data_dir, exist_ok=True)
        
    def create_indian_states_data(self):
        """Create Indian states data with coordinates"""
        
        # Major Indian states with approximate centroid coordinates
        states_data = [
            {'state_name': 'Andhra Pradesh', 'state_code': 'AP', 'centroid_lat': 15.9129, 'centroid_lon': 79.7400, 'area_km2': 160205, 'population_density': 308},
            {'state_name': 'Arunachal Pradesh', 'state_code': 'AR', 'centroid_lat': 28.2180, 'centroid_lon': 94.7278, 'area_km2': 83743, 'population_density': 17},
            {'state_name': 'Assam', 'state_code': 'AS', 'centroid_lat': 26.2006, 'centroid_lon': 92.9376, 'area_km2': 78438, 'population_density': 398},
            {'state_name': 'Bihar', 'state_code': 'BR', 'centroid_lat': 25.0961, 'centroid_lon': 85.3131, 'area_km2': 94163, 'population_density': 1106},
            {'state_name': 'Chhattisgarh', 'state_code': 'CG', 'centroid_lat': 21.2787, 'centroid_lon': 81.8661, 'area_km2': 135192, 'population_density': 189},
            {'state_name': 'Delhi', 'state_code': 'DL', 'centroid_lat': 28.7041, 'centroid_lon': 77.1025, 'area_km2': 1484, 'population_density': 11320},
            {'state_name': 'Goa', 'state_code': 'GA', 'centroid_lat': 15.2993, 'centroid_lon': 74.1240, 'area_km2': 3702, 'population_density': 394},
            {'state_name': 'Gujarat', 'state_code': 'GJ', 'centroid_lat': 23.0225, 'centroid_lon': 72.5714, 'area_km2': 196244, 'population_density': 308},
            {'state_name': 'Haryana', 'state_code': 'HR', 'centroid_lat': 29.0588, 'centroid_lon': 76.0856, 'area_km2': 44212, 'population_density': 573},
            {'state_name': 'Himachal Pradesh', 'state_code': 'HP', 'centroid_lat': 31.1048, 'centroid_lon': 77.1734, 'area_km2': 55673, 'population_density': 123},
            {'state_name': 'Jharkhand', 'state_code': 'JH', 'centroid_lat': 23.6102, 'centroid_lon': 85.2799, 'area_km2': 79716, 'population_density': 414},
            {'state_name': 'Karnataka', 'state_code': 'KA', 'centroid_lat': 15.3173, 'centroid_lon': 75.7139, 'area_km2': 191791, 'population_density': 319},
            {'state_name': 'Kerala', 'state_code': 'KL', 'centroid_lat': 10.8505, 'centroid_lon': 76.2711, 'area_km2': 38852, 'population_density': 860},
            {'state_name': 'Madhya Pradesh', 'state_code': 'MP', 'centroid_lat': 22.9734, 'centroid_lon': 78.6569, 'area_km2': 308245, 'population_density': 236},
            {'state_name': 'Maharashtra', 'state_code': 'MH', 'centroid_lat': 19.7515, 'centroid_lon': 75.7139, 'area_km2': 307713, 'population_density': 365},
            {'state_name': 'Manipur', 'state_code': 'MN', 'centroid_lat': 24.6637, 'centroid_lon': 93.9063, 'area_km2': 22327, 'population_density': 122},
            {'state_name': 'Meghalaya', 'state_code': 'ML', 'centroid_lat': 25.4670, 'centroid_lon': 91.3662, 'area_km2': 22429, 'population_density': 132},
            {'state_name': 'Mizoram', 'state_code': 'MZ', 'centroid_lat': 23.1645, 'centroid_lon': 92.9376, 'area_km2': 21081, 'population_density': 52},
            {'state_name': 'Nagaland', 'state_code': 'NL', 'centroid_lat': 26.1584, 'centroid_lon': 94.5624, 'area_km2': 16579, 'population_density': 119},
            {'state_name': 'Odisha', 'state_code': 'OR', 'centroid_lat': 20.9517, 'centroid_lon': 85.0985, 'area_km2': 155707, 'population_density': 270},
            {'state_name': 'Punjab', 'state_code': 'PB', 'centroid_lat': 31.1471, 'centroid_lon': 75.3412, 'area_km2': 50362, 'population_density': 551},
            {'state_name': 'Rajasthan', 'state_code': 'RJ', 'centroid_lat': 27.0238, 'centroid_lon': 74.2179, 'area_km2': 342239, 'population_density': 200},
            {'state_name': 'Sikkim', 'state_code': 'SK', 'centroid_lat': 27.5330, 'centroid_lon': 88.5122, 'area_km2': 7096, 'population_density': 86},
            {'state_name': 'Tamil Nadu', 'state_code': 'TN', 'centroid_lat': 11.1271, 'centroid_lon': 78.6569, 'area_km2': 130060, 'population_density': 555},
            {'state_name': 'Telangana', 'state_code': 'TG', 'centroid_lat': 18.1124, 'centroid_lon': 79.0193, 'area_km2': 114840, 'population_density': 312},
            {'state_name': 'Tripura', 'state_code': 'TR', 'centroid_lat': 23.9408, 'centroid_lon': 91.9882, 'area_km2': 10486, 'population_density': 350},
            {'state_name': 'Uttar Pradesh', 'state_code': 'UP', 'centroid_lat': 26.8467, 'centroid_lon': 80.9462, 'area_km2': 240928, 'population_density': 828},
            {'state_name': 'Uttarakhand', 'state_code': 'UK', 'centroid_lat': 30.0668, 'centroid_lon': 79.0193, 'area_km2': 53483, 'population_density': 189},
            {'state_name': 'West Bengal', 'state_code': 'WB', 'centroid_lat': 22.9868, 'centroid_lon': 87.8550, 'area_km2': 88752, 'population_density': 1028},
            {'state_name': 'Jammu and Kashmir', 'state_code': 'JK', 'centroid_lat': 33.7782, 'centroid_lon': 76.5762, 'area_km2': 222236, 'population_density': 57},
            {'state_name': 'Ladakh', 'state_code': 'LA', 'centroid_lat': 34.1526, 'centroid_lon': 77.5771, 'area_km2': 59146, 'population_density': 5}
        ]
        
        # Convert to DataFrame and save
        df = pd.DataFrame(states_data)
        
        # Create NetLogo coordinates
        self.create_netlogo_coordinates(df)
        
        # Save to CSV
        csv_path = os.path.join(self.data_dir, "indian_states_data.csv")
        df.to_csv(csv_path, index=False)
        
        print(f"Indian states data saved to {csv_path}")
        return df
    
    def create_netlogo_coordinates(self, df):
        """Create NetLogo world coordinates from geographic coordinates"""
        
        # Get bounds
        min_lon, max_lon = df['centroid_lon'].min(), df['centroid_lon'].max()
        min_lat, max_lat = df['centroid_lat'].min(), df['centroid_lat'].max()
        
        # NetLogo world size
        world_size = 100  # -50 to 50
        
        # Scale coordinates
        df['netlogo_x'] = ((df['centroid_lon'] - min_lon) / (max_lon - min_lon) * world_size) - (world_size / 2)
        df['netlogo_y'] = ((df['centroid_lat'] - min_lat) / (max_lat - min_lat) * world_size) - (world_size / 2)
        
        # Save NetLogo coordinates
        netlogo_path = os.path.join(self.data_dir, "netlogo_coordinates.csv")
        df.to_csv(netlogo_path, index=False)
        
        print(f"NetLogo coordinates saved to {netlogo_path}")
    
    def create_major_cities_data(self):
        """Create major cities data for India"""
        
        cities_data = [
            {'city': 'Mumbai', 'state': 'Maharashtra', 'lat': 19.0760, 'lon': 72.8777, 'population': 12442373, 'type': 'metro'},
            {'city': 'Delhi', 'state': 'Delhi', 'lat': 28.6139, 'lon': 77.2090, 'population': 11007835, 'type': 'metro'},
            {'city': 'Bangalore', 'state': 'Karnataka', 'lat': 12.9716, 'lon': 77.5946, 'population': 8443675, 'type': 'metro'},
            {'city': 'Hyderabad', 'state': 'Telangana', 'lat': 17.3850, 'lon': 78.4867, 'population': 6809970, 'type': 'metro'},
            {'city': 'Ahmedabad', 'state': 'Gujarat', 'lat': 23.0225, 'lon': 72.5714, 'population': 5570585, 'type': 'metro'},
            {'city': 'Chennai', 'state': 'Tamil Nadu', 'lat': 13.0827, 'lon': 80.2707, 'population': 4681087, 'type': 'metro'},
            {'city': 'Kolkata', 'state': 'West Bengal', 'lat': 22.5726, 'lon': 88.3639, 'population': 4486679, 'type': 'metro'},
            {'city': 'Surat', 'state': 'Gujarat', 'lat': 21.1959, 'lon': 72.8302, 'population': 4467797, 'type': 'urban'},
            {'city': 'Pune', 'state': 'Maharashtra', 'lat': 18.5204, 'lon': 73.8567, 'population': 3124458, 'type': 'urban'},
            {'city': 'Jaipur', 'state': 'Rajasthan', 'lat': 26.9124, 'lon': 75.7873, 'population': 3046163, 'type': 'urban'},
            {'city': 'Lucknow', 'state': 'Uttar Pradesh', 'lat': 26.8467, 'lon': 80.9462, 'population': 2817105, 'type': 'urban'},
            {'city': 'Kanpur', 'state': 'Uttar Pradesh', 'lat': 26.4499, 'lon': 80.3319, 'population': 2767031, 'type': 'urban'},
            {'city': 'Nagpur', 'state': 'Maharashtra', 'lat': 21.1458, 'lon': 79.0882, 'population': 2405421, 'type': 'urban'},
            {'city': 'Indore', 'state': 'Madhya Pradesh', 'lat': 22.7196, 'lon': 75.8577, 'population': 1964086, 'type': 'urban'},
            {'city': 'Thane', 'state': 'Maharashtra', 'lat': 19.2183, 'lon': 72.9781, 'population': 1841128, 'type': 'urban'},
            {'city': 'Bhopal', 'state': 'Madhya Pradesh', 'lat': 23.2599, 'lon': 77.4126, 'population': 1798218, 'type': 'urban'},
            {'city': 'Visakhapatnam', 'state': 'Andhra Pradesh', 'lat': 17.6868, 'lon': 83.2185, 'population': 1730320, 'type': 'urban'},
            {'city': 'Pimpri-Chinchwad', 'state': 'Maharashtra', 'lat': 18.6298, 'lon': 73.7997, 'population': 1729359, 'type': 'urban'},
            {'city': 'Patna', 'state': 'Bihar', 'lat': 25.5941, 'lon': 85.1376, 'population': 1684222, 'type': 'urban'},
            {'city': 'Vadodara', 'state': 'Gujarat', 'lat': 22.3072, 'lon': 73.1812, 'population': 1666703, 'type': 'urban'},
            {'city': 'Ghaziabad', 'state': 'Uttar Pradesh', 'lat': 28.6692, 'lon': 77.4538, 'population': 1648643, 'type': 'urban'},
            {'city': 'Ludhiana', 'state': 'Punjab', 'lat': 30.9010, 'lon': 75.8573, 'population': 1618879, 'type': 'urban'},
            {'city': 'Agra', 'state': 'Uttar Pradesh', 'lat': 27.1767, 'lon': 78.0081, 'population': 1585704, 'type': 'urban'},
            {'city': 'Nashik', 'state': 'Maharashtra', 'lat': 19.9975, 'lon': 73.7898, 'population': 1486973, 'type': 'urban'},
            {'city': 'Faridabad', 'state': 'Haryana', 'lat': 28.4089, 'lon': 77.3178, 'population': 1414050, 'type': 'urban'},
            {'city': 'Meerut', 'state': 'Uttar Pradesh', 'lat': 28.9845, 'lon': 77.7064, 'population': 1309023, 'type': 'urban'},
            {'city': 'Rajkot', 'state': 'Gujarat', 'lat': 22.3039, 'lon': 70.8022, 'population': 1286995, 'type': 'urban'},
            {'city': 'Kalyan-Dombivli', 'state': 'Maharashtra', 'lat': 19.2350, 'lon': 73.1300, 'population': 1246381, 'type': 'urban'},
            {'city': 'Vasai-Virar', 'state': 'Maharashtra', 'lat': 19.4920, 'lon': 72.8000, 'population': 1221233, 'type': 'urban'},
            {'city': 'Varanasi', 'state': 'Uttar Pradesh', 'lat': 25.3176, 'lon': 82.9739, 'population': 1198491, 'type': 'urban'}
        ]
        
        cities_df = pd.DataFrame(cities_data)
        cities_path = os.path.join(self.data_dir, "indian_major_cities.csv")
        cities_df.to_csv(cities_path, index=False)
        
        print(f"Major cities data saved to {cities_path}")
        return cities_df
    
    def create_netlogo_integration_file(self):
        """Create NetLogo code for loading the data"""
        
        netlogo_code = '''
; NetLogo procedures for loading Indian GIS data
; Include this file in your main model with: __includes ["gis_data/netlogo_data_loader.nls"]

extensions [table]

globals [
  states-data-table
  cities-data-table
  states-coordinates-table
]

to load-indian-gis-data
  print "Loading Indian GIS data..."
  
  ; Load states data
  load-states-data
  
  ; Load cities data
  load-cities-data
  
  ; Load coordinate mappings
  load-coordinates-data
  
  print "Indian GIS data loaded successfully!"
end

to load-states-data
  set states-data-table table:make
  
  if file-exists? "gis_data/indian_states_data.csv" [
    file-open "gis_data/indian_states_data.csv"
    let header file-read-line  ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data split line ","
      
      if length data >= 6 [
        let state-name item 0 data
        let state-code item 1 data
        let lat read-from-string item 2 data
        let lon read-from-string item 3 data
        let area read-from-string item 4 data
        let pop-density read-from-string item 5 data
        
        table:put states-data-table state-name (list state-code lat lon area pop-density)
      ]
    ]
    
    file-close
    print "States data loaded successfully"
  ]
end

to load-cities-data
  set cities-data-table table:make
  
  if file-exists? "gis_data/indian_major_cities.csv" [
    file-open "gis_data/indian_major_cities.csv"
    let header file-read-line  ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data split line ","
      
      if length data >= 6 [
        let city-name item 0 data
        let state-name item 1 data
        let lat read-from-string item 2 data
        let lon read-from-string item 3 data
        let population read-from-string item 4 data
        let city-type item 5 data
        
        table:put cities-data-table city-name (list state-name lat lon population city-type)
      ]
    ]
    
    file-close
    print "Cities data loaded successfully"
  ]
end

to load-coordinates-data
  set states-coordinates-table table:make
  
  if file-exists? "gis_data/netlogo_coordinates.csv" [
    file-open "gis_data/netlogo_coordinates.csv"
    let header file-read-line  ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data split line ","
      
      if length data >= 8 [
        let state-name item 0 data
        let netlogo-x read-from-string item 6 data
        let netlogo-y read-from-string item 7 data
        
        table:put states-coordinates-table state-name (list netlogo-x netlogo-y)
      ]
    ]
    
    file-close
    print "Coordinate mappings loaded successfully"
  ]
end

; Utility functions
to-report get-state-population-density [state-name]
  if states-data-table != 0 and table:has-key? states-data-table state-name [
    let state-data table:get states-data-table state-name
    report item 4 state-data  ; population density
  ]
  report 100  ; default
end

to-report get-state-coordinates [state-name]
  if states-coordinates-table != 0 and table:has-key? states-coordinates-table state-name [
    report table:get states-coordinates-table state-name
  ]
  report (list 0 0)  ; default center
end

to-report get-city-data [city-name]
  if cities-data-table != 0 and table:has-key? cities-data-table city-name [
    report table:get cities-data-table city-name
  ]
  report nobody
end

to-report split [string delimiter]
  let result []
  let current-word ""
  let string-length length string
  
  let i 0
  while [i < string-length] [
    let char substring string i (i + 1)
    
    if char = delimiter [
      if current-word != "" [
        set result lput current-word result
        set current-word ""
      ]
    ] [
      set current-word (word current-word char)
    ]
    
    set i i + 1
  ]
  
  if current-word != "" [
    set result lput current-word result
  ]
  
  report result
end

; Setup procedures using real data
to setup-real-indian-states
  load-indian-gis-data
  
  ; Apply real state data to patches
  ask patches [
    ; Find closest state based on coordinates
    let closest-state ""
    let min-distance 1000000
    
    let state-names table:keys states-coordinates-table
    foreach state-names [ state-name ->
      let coords get-state-coordinates state-name
      let state-x item 0 coords
      let state-y item 1 coords
      let dist distance-to-point pxcor pycor state-x state-y
      
      if dist < min-distance [
        set min-distance dist
        set closest-state state-name
      ]
    ]
    
    ; Set patch properties based on closest state
    if closest-state != "" [
      set state-name closest-state
      set population-density get-state-population-density closest-state
      set is-urban (population-density > 500)
    ]
  ]
end

to setup-real-indian-cities
  load-indian-gis-data
  
  ; Create cities from real data
  let city-names table:keys cities-data-table
  foreach city-names [ city-name ->
    let city-data get-city-data city-name
    if city-data != nobody [
      let state-name item 0 city-data
      let lat item 1 city-data
      let lon item 2 city-data
      let population item 3 city-data
      let city-type item 4 city-data
      
      ; Convert to NetLogo coordinates
      let netlogo-coords convert-latlon-to-netlogo lat lon
      let x-coord item 0 netlogo-coords
      let y-coord item 1 netlogo-coords
      
      ; Create city if within bounds
      if x-coord >= min-pxcor and x-coord <= max-pxcor and
         y-coord >= min-pycor and y-coord <= max-pycor [
        create-cities 1 [
          setxy x-coord y-coord
          set city-name city-name
          set city-population population
          set city-type city-type
          
          ; Set appearance based on type
          if city-type = "metro" [
            set color red
            set size 3
          ] [
            set color orange
            set size 2
          ]
          
          set shape "circle"
        ]
      ]
    ]
  ]
end

to-report convert-latlon-to-netlogo [lat lon]
  ; Convert lat/lon to NetLogo coordinates (simplified)
  let min-lat 6.5
  let max-lat 37
  let min-lon 68
  let max-lon 97.5
  
  let world-width max-pxcor - min-pxcor
  let world-height max-pycor - min-pycor
  
  let netlogo-x min-pxcor + (lon - min-lon) / (max-lon - min-lon) * world-width
  let netlogo-y min-pycor + (lat - min-lat) / (max-lat - min-lat) * world-height
  
  report (list netlogo-x netlogo-y)
end

to-report distance-to-point [x1 y1 x2 y2]
  report sqrt ((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end
'''
        
        code_path = os.path.join(self.data_dir, "netlogo_data_loader.nls")
        with open(code_path, 'w') as f:
            f.write(netlogo_code)
        
        print(f"NetLogo integration code saved to {code_path}")
    
    def create_sample_scenario_data(self):
        """Create sample scenario data for different use cases"""
        
        # Scenario 1: Urban migration
        migration_data = [
            {'from_state': 'Bihar', 'to_state': 'Maharashtra', 'migration_rate': 0.15},
            {'from_state': 'Uttar Pradesh', 'to_state': 'Delhi', 'migration_rate': 0.12},
            {'from_state': 'Odisha', 'to_state': 'Karnataka', 'migration_rate': 0.08},
            {'from_state': 'West Bengal', 'to_state': 'Maharashtra', 'migration_rate': 0.10},
            {'from_state': 'Madhya Pradesh', 'to_state': 'Gujarat', 'migration_rate': 0.07}
        ]
        
        migration_df = pd.DataFrame(migration_data)
        migration_path = os.path.join(self.data_dir, "migration_patterns.csv")
        migration_df.to_csv(migration_path, index=False)
        
        # Scenario 2: Economic indicators
        economic_data = [
            {'state': 'Maharashtra', 'gdp_per_capita': 200000, 'unemployment_rate': 0.018, 'literacy_rate': 0.823},
            {'state': 'Tamil Nadu', 'gdp_per_capita': 180000, 'unemployment_rate': 0.019, 'literacy_rate': 0.804},
            {'state': 'Gujarat', 'gdp_per_capita': 175000, 'unemployment_rate': 0.020, 'literacy_rate': 0.787},
            {'state': 'Karnataka', 'gdp_per_capita': 165000, 'unemployment_rate': 0.022, 'literacy_rate': 0.753},
            {'state': 'Haryana', 'gdp_per_capita': 160000, 'unemployment_rate': 0.025, 'literacy_rate': 0.764},
            {'state': 'Bihar', 'gdp_per_capita': 45000, 'unemployment_rate': 0.055, 'literacy_rate': 0.635},
            {'state': 'Uttar Pradesh', 'gdp_per_capita': 50000, 'unemployment_rate': 0.045, 'literacy_rate': 0.673}
        ]
        
        economic_df = pd.DataFrame(economic_data)
        economic_path = os.path.join(self.data_dir, "economic_indicators.csv")
        economic_df.to_csv(economic_path, index=False)
        
        print(f"Sample scenario data created:")
        print(f"  Migration patterns: {migration_path}")
        print(f"  Economic indicators: {economic_path}")
    
    def create_readme(self):
        """Create comprehensive README file"""
        
        readme_content = f"""# NetLogo GIS Model for Indian Regions

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

## Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Support
For questions or issues:
1. Check NetLogo documentation
2. Review the generated data files
3. Modify the data loader procedures as needed
"""
        
        readme_path = os.path.join(self.data_dir, "README.md")
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)
        
        print(f"README created at {readme_path}")

def main():
    """Main function to generate all data files"""
    
    print("Simple India GIS Data Generator for NetLogo")
    print("=" * 50)
    
    generator = SimpleIndiaDataGenerator()
    
    print("\\n1. Creating Indian states data...")
    generator.create_indian_states_data()
    
    print("\\n2. Creating major cities data...")
    generator.create_major_cities_data()
    
    print("\\n3. Creating NetLogo integration code...")
    generator.create_netlogo_integration_file()
    
    print("\\n4. Creating sample scenario data...")
    generator.create_sample_scenario_data()
    
    print("\\n5. Creating README...")
    generator.create_readme()
    
    print("\\n" + "=" * 50)
    print("✓ All data files generated successfully!")
    print("\\nNext steps:")
    print("1. Download NetLogo from https://ccl.northwestern.edu/netlogo/")
    print("2. Open 'india_region_gis_model.nlogo' in NetLogo")
    print("3. Click 'setup' to initialize the model")
    print("4. Explore the different display modes and features")
    print("\\nCheck the README.md file for detailed usage instructions.")

if __name__ == "__main__":
    main()
