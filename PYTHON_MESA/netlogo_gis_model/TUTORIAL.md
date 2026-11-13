# NetLogo GIS Model Tutorial: Getting Started with Indian Regions

## Tutorial: Setting Up and Running Your First Simulation

### Step 1: Installation and Setup

#### What You'll Need:
- NetLogo 6.0 or later
- The generated model files (already created!)

#### Download NetLogo:
1. Go to https://ccl.northwestern.edu/netlogo/
2. Download the appropriate version for your operating system
3. Install NetLogo following the standard installation process

### Step 2: Opening the Model

1. **Launch NetLogo**
2. **Open the model file**: 
   - Click File → Open
   - Navigate to `d:\PYTHON_MESA\netlogo_gis_model\`
   - Select `india_region_gis_model.nlogo`

### Step 3: Understanding the Interface

When you open the model, you'll see:

#### Main Controls:
- **Setup**: Initializes the model with real Indian geographical data
- **Go**: Starts the simulation (agents begin moving)
- **Display Buttons**: Change visualization modes

#### Display Modes:
- **set-display-states**: Shows Indian states in different colors
- **set-display-population**: Shows population density as a heatmap
- **set-display-elevation**: Shows elevation data as a heatmap

#### Analysis Tools:
- **analyze-region**: Click to get statistics about regions
- **export-data**: Save simulation data to CSV files

### Step 4: Running Your First Simulation

1. **Click the "Setup" button**
   - This loads real Indian state data
   - Creates 30 major cities with accurate locations
   - Initializes 200 agents (people) randomly across the map

2. **Choose a display mode**
   - Try "set-display-states" first to see state boundaries
   - The model will show different Indian states in different colors

3. **Click "Go" to start the simulation**
   - Blue dots (agents) will start moving around
   - Red circles show major cities like Mumbai, Delhi, Bangalore
   - Agents tend to move toward cities

4. **Interact with the model**
   - Click on any patch to select a state
   - Click "analyze-region" to see statistics
   - Try different display modes to explore the data

### Step 5: Exploring Different Visualizations

#### Population Density View:
1. Click "set-display-population"
2. Red areas = high population density (Delhi, Mumbai region)
3. Green areas = low population density (rural areas)

#### States View:
1. Click "set-display-states"
2. Each state appears in a different color
3. You can identify major states like Maharashtra, Uttar Pradesh, etc.

#### Elevation View:
1. Click "set-display-elevation"
2. Shows mock elevation data across the region

### Step 6: Advanced Features

#### Regional Analysis:
1. Click on any patch in the model
2. Click "analyze-region" 
3. Check the Command Center for detailed statistics about that state

#### Data Export:
1. Run the simulation for a while
2. Click "export-data"
3. Check the model directory for exported CSV files

### Step 7: Understanding the Data

The model uses real Indian geographical data:

#### States:
- 30 Indian states and union territories
- Real population densities from Census data
- Accurate geographic coordinates

#### Cities:
- 30 major Indian cities
- Real population figures
- Metro vs. urban classification

#### Agents:
- Represent people or households
- Move around the landscape
- Attracted to urban centers

### Step 8: Customization Ideas

#### Modify Agent Behavior:
- Change movement patterns
- Add different types of agents
- Modify migration rules

#### Add New Data:
- Include your own CSV data files
- Add economic indicators
- Include transportation networks

#### Create New Visualizations:
- Add custom color schemes
- Create time-series animations
- Include network connections

### Step 9: Troubleshooting

#### Common Issues:

**Model loads but shows no data:**
- Make sure the `gis_data` folder is present
- Check that CSV files were generated correctly
- Run `simple_data_generator.py` to regenerate data

**Simulation runs slowly:**
- Reduce the number of agents in the code
- Simplify visualizations
- Use a smaller world size

**Error messages:**
- Check that all required extensions are loaded
- Verify file paths are correct
- Ensure NetLogo version is 6.0+

### Step 10: Next Steps

#### Learn More:
- Read the full documentation in `PROJECT_OVERVIEW.md`
- Explore the generated data files in `gis_data/`
- Check out NetLogo's built-in examples

#### Extend the Model:
- Add time-series data
- Include economic variables
- Create network analysis
- Add climate data

#### Share Your Work:
- Export your results
- Create visualizations
- Document your modifications
- Share with the community

---

## Quick Reference Commands

### Essential Buttons:
- `Setup` → Initialize model
- `Go` → Start/stop simulation
- `set-display-states` → Show state boundaries
- `set-display-population` → Show population density
- `analyze-region` → Get region statistics

### Key Files:
- `india_region_gis_model.nlogo` → Main model
- `gis_data/indian_states_data.csv` → State information
- `gis_data/indian_major_cities.csv` → City data
- `gis_data/README.md` → Data documentation

### Useful Monitors:
- `total-population` → Sum of all patch populations
- `selected-state-name` → Currently clicked state
- `average-elevation` → Mean elevation across patches

---

**Happy Modeling!** 

This tutorial should get you started with the Indian GIS model. Experiment with different settings, try various visualizations, and don't hesitate to modify the code to suit your specific research needs.
