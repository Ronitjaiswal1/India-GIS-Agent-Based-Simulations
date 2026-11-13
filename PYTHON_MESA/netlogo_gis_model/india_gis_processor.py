"""
GIS Data Downloader and Processor for NetLogo India Model
This script helps download and process GIS data for Indian regions
"""

import os
import requests
import zipfile
import geopandas as gpd
import rasterio
from rasterio import features
import numpy as np
import pandas as pd
from urllib.parse import urljoin
import json

class IndiaGISDataProcessor:
    def __init__(self, data_dir="gis_data"):
        self.data_dir = data_dir
        self.base_url = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/"
        
        # Create data directory if it doesn't exist
        os.makedirs(self.data_dir, exist_ok=True)
        
    def download_natural_earth_data(self):
        """Download Indian administrative boundaries from Natural Earth"""
        
        # URLs for Natural Earth data
        urls = {
            "admin_0_countries": "10m/cultural/ne_10m_admin_0_countries.zip",
            "admin_1_states": "10m/cultural/ne_10m_admin_1_states_provinces.zip",
            "populated_places": "10m/cultural/ne_10m_populated_places.zip",
            "rivers": "10m/physical/ne_10m_rivers_lake_centerlines.zip",
            "coastline": "10m/physical/ne_10m_coastline.zip"
        }
        
        for name, url_path in urls.items():
            full_url = urljoin(self.base_url, url_path)
            zip_path = os.path.join(self.data_dir, f"{name}.zip")
            
            print(f"Downloading {name}...")
            try:
                response = requests.get(full_url)
                response.raise_for_status()
                
                with open(zip_path, 'wb') as f:
                    f.write(response.content)
                
                # Extract zip file
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(os.path.join(self.data_dir, name))
                
                print(f"Downloaded and extracted {name}")
                
            except Exception as e:
                print(f"Error downloading {name}: {e}")
    
    def process_indian_states(self):
        """Process Indian states data"""
        
        # Path to states shapefile
        states_dir = os.path.join(self.data_dir, "admin_1_states")
        states_shp = None
        
        # Find the shapefile
        for file in os.listdir(states_dir):
            if file.endswith('.shp'):
                states_shp = os.path.join(states_dir, file)
                break
        
        if not states_shp:
            print("States shapefile not found!")
            return
        
        # Load and filter for India
        print("Processing Indian states...")
        gdf = gpd.read_file(states_shp)
        
        # Filter for India
        india_states = gdf[gdf['admin'] == 'India'].copy()
        
        # Save Indian states
        output_path = os.path.join(self.data_dir, "indian_states.shp")
        india_states.to_file(output_path)
        
        print(f"Indian states saved to {output_path}")
        
        # Create a simplified version for NetLogo
        self.create_netlogo_compatible_data(india_states)
        
        return india_states
    
    def create_netlogo_compatible_data(self, gdf):
        """Create NetLogo-compatible data files"""
        
        # Create a simplified CSV with state information
        state_data = []
        
        for idx, row in gdf.iterrows():
            # Get centroid for each state
            centroid = row.geometry.centroid
            
            state_info = {
                'state_name': row.get('name', 'Unknown'),
                'state_code': row.get('postal', 'XX'),
                'centroid_lon': centroid.x,
                'centroid_lat': centroid.y,
                'area_km2': row.geometry.area * 111000,  # Approximate conversion
                'type': row.get('type', 'State')
            }
            state_data.append(state_info)
        
        # Save to CSV
        df = pd.DataFrame(state_data)
        csv_path = os.path.join(self.data_dir, "indian_states_data.csv")
        df.to_csv(csv_path, index=False)
        
        print(f"State data saved to {csv_path}")
        
        # Create NetLogo coordinate mapping
        self.create_netlogo_coordinates(df)
    
    def create_netlogo_coordinates(self, df):
        """Create NetLogo world coordinates from geographic coordinates"""
        
        # Get bounds
        min_lon, max_lon = df['centroid_lon'].min(), df['centroid_lon'].max()
        min_lat, max_lat = df['centroid_lat'].min(), df['centroid_lat'].max()
        
        # NetLogo world size (adjust as needed)
        world_size = 100  # -50 to 50
        
        # Scale coordinates
        df['netlogo_x'] = ((df['centroid_lon'] - min_lon) / (max_lon - min_lon) * world_size) - (world_size / 2)
        df['netlogo_y'] = ((df['centroid_lat'] - min_lat) / (max_lat - min_lat) * world_size) - (world_size / 2)
        
        # Save NetLogo coordinates
        netlogo_path = os.path.join(self.data_dir, "netlogo_coordinates.csv")
        df.to_csv(netlogo_path, index=False)
        
        print(f"NetLogo coordinates saved to {netlogo_path}")
    
    def create_mock_population_data(self):
        """Create mock population density data"""
        
        # Indian states with approximate population densities (people per km²)
        population_data = {
            'Delhi': 11320,
            'Chandigarh': 9252,
            'Puducherry': 2598,
            'Lakshadweep': 2013,
            'Daman and Diu': 1413,
            'West Bengal': 1028,
            'Bihar': 1106,
            'Kerala': 860,
            'Uttar Pradesh': 828,
            'Haryana': 573,
            'Tamil Nadu': 555,
            'Punjab': 551,
            'Jharkhand': 414,
            'Assam': 398,
            'Goa': 394,
            'Andaman and Nicobar Islands': 46,
            'Tripura': 350,
            'Odisha': 270,
            'Andhra Pradesh': 308,
            'Telangana': 312,
            'Karnataka': 319,
            'Maharashtra': 365,
            'Gujarat': 308,
            'Rajasthan': 200,
            'Madhya Pradesh': 236,
            'Chhattisgarh': 189,
            'Himachal Pradesh': 123,
            'Uttarakhand': 189,
            'Jammu and Kashmir': 57,
            'Manipur': 122,
            'Meghalaya': 132,
            'Nagaland': 119,
            'Sikkim': 86,
            'Mizoram': 52,
            'Arunachal Pradesh': 17
        }
        
        # Save to CSV
        pop_df = pd.DataFrame(list(population_data.items()), columns=['state_name', 'population_density'])
        pop_path = os.path.join(self.data_dir, "indian_population_density.csv")
        pop_df.to_csv(pop_path, index=False)
        
        print(f"Population density data saved to {pop_path}")
    
    def create_major_cities_data(self):
        """Create major cities data for India"""
        
        # Major Indian cities with coordinates and population
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
            {'city': 'Vadodara', 'state': 'Gujarat', 'lat': 22.3072, 'lon': 73.1812, 'population': 1666703, 'type': 'urban'}
        ]
        
        cities_df = pd.DataFrame(cities_data)
        cities_path = os.path.join(self.data_dir, "indian_major_cities.csv")
        cities_df.to_csv(cities_path, index=False)
        
        print(f"Major cities data saved to {cities_path}")
    
    def create_netlogo_integration_code(self):
        """Create NetLogo code for loading the processed data"""
        
        netlogo_code = """
; Additional NetLogo procedures for loading processed GIS data

to load-processed-gis-data
  ; Load state data
  if file-exists? "gis_data/indian_states_data.csv" [
    file-open "gis_data/indian_states_data.csv"
    let header file-read-line ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data csv:from-row line
      ; Process state data
      ; data contains: state_name, state_code, centroid_lon, centroid_lat, area_km2, type
    ]
    file-close
  ]
  
  ; Load population data
  if file-exists? "gis_data/indian_population_density.csv" [
    file-open "gis_data/indian_population_density.csv"
    let header file-read-line ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data csv:from-row line
      ; Process population data
      ; data contains: state_name, population_density
    ]
    file-close
  ]
  
  ; Load cities data
  if file-exists? "gis_data/indian_major_cities.csv" [
    file-open "gis_data/indian_major_cities.csv"
    let header file-read-line ; Skip header
    
    while [not file-at-end?] [
      let line file-read-line
      let data csv:from-row line
      ; Process cities data
      ; data contains: city, state, lat, lon, population, type
    ]
    file-close
  ]
end

to setup-real-indian-cities
  ; Create cities based on real data
  ; This procedure would use the loaded cities data
  ; to create city agents at correct locations
end
"""
        
        code_path = os.path.join(self.data_dir, "netlogo_data_loader.nls")
        with open(code_path, 'w') as f:
            f.write(netlogo_code)
        
        print(f"NetLogo integration code saved to {code_path}")
    
    def generate_readme(self):
        """Generate README with instructions"""
        
        readme_content = """# NetLogo GIS Model for Indian Regions

## Overview
This directory contains GIS data and NetLogo model files for simulating Indian geographical regions.

## Files Description

### NetLogo Model Files
- `india_region_gis_model.nlogo` - Main NetLogo model file
- `netlogo_data_loader.nls` - Additional procedures for loading processed data

### GIS Data Files
- `indian_states_data.csv` - Indian states with geographic information
- `indian_population_density.csv` - Population density data by state
- `indian_major_cities.csv` - Major Indian cities with coordinates and population
- `netlogo_coordinates.csv` - NetLogo world coordinates for states

### Raw GIS Data (if downloaded)
- `admin_1_states/` - State boundaries shapefile
- `admin_0_countries/` - Country boundaries
- `populated_places/` - Cities and towns
- `rivers/` - River networks
- `coastline/` - Coastal boundaries

## Setup Instructions

1. **Install NetLogo**: Download and install NetLogo from https://ccl.northwestern.edu/netlogo/
2. **Install GIS Extension**: The GIS extension should be included with NetLogo
3. **Load the Model**: Open `india_region_gis_model.nlogo` in NetLogo
4. **Run Setup**: Click the "setup" button to initialize the model

## Model Features

### Display Modes
- **States Mode**: Shows different Indian states in different colors
- **Population Mode**: Shows population density as a heatmap
- **Elevation Mode**: Shows elevation data as a heatmap

### Interactive Features
- Click on patches to select states and get information
- Agents (people) move around the landscape
- Cities are displayed as red circles
- Various analysis tools are available

### Data Analysis
- Click "analyze-region" to get statistics about selected states
- Use "export-data" to save model data to CSV
- Monitor displays show real-time statistics

## Customization

### Adding Real GIS Data
1. Download Indian state shapefiles (e.g., from Survey of India or Natural Earth)
2. Place shapefiles in the `gis_data/` directory
3. Uncomment the GIS loading code in the NetLogo model
4. Modify the `load-gis-data` procedure to load your specific files

### Modifying the Model
- Adjust world size in `setup-world-envelope`
- Add more cities in `setup-cities`
- Modify agent behavior in `move-agents`
- Change visualization in display procedures

## Data Sources
- Administrative boundaries: Natural Earth Data
- Population data: Census of India (approximate values)
- City data: Various official sources

## Requirements
- NetLogo 6.0 or later
- GIS extension (included with NetLogo)
- Python 3.x (for data processing script)

## Python Data Processing
Use the `india_gis_processor.py` script to:
- Download GIS data from Natural Earth
- Process shapefiles for NetLogo compatibility
- Create coordinate mappings
- Generate mock population data

## Notes
- The model uses mock data for demonstration
- Real GIS data integration requires additional setup
- Coordinate system is simplified for NetLogo compatibility
- Population and elevation data are approximated
"""
        
        readme_path = os.path.join(self.data_dir, "README.md")
        with open(readme_path, 'w') as f:
            f.write(readme_content)
        
        print(f"README generated at {readme_path}")

def main():
    """Main function to run the GIS data processor"""
    
    print("India GIS Data Processor for NetLogo")
    print("=" * 40)
    
    processor = IndiaGISDataProcessor()
    
    # Create all necessary data files
    print("Creating mock population data...")
    processor.create_mock_population_data()
    
    print("Creating major cities data...")
    processor.create_major_cities_data()
    
    print("Creating NetLogo integration code...")
    processor.create_netlogo_integration_code()
    
    print("Generating README...")
    processor.generate_readme()
    
    # Option to download real GIS data
    download_real_data = input("\\nDo you want to download real GIS data from Natural Earth? (y/n): ")
    if download_real_data.lower() == 'y':
        print("Downloading Natural Earth data...")
        processor.download_natural_earth_data()
        
        print("Processing Indian states data...")
        processor.process_indian_states()
    
    print("\\nSetup complete!")
    print("You can now open the NetLogo model file:")
    print("  india_region_gis_model.nlogo")
    print("\\nCheck the README.md file for detailed instructions.")

if __name__ == "__main__":
    main()
