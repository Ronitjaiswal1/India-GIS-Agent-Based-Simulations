# How to Run the NetLogo GIS Model - Step by Step Guide

## **Quick Start (Most Important Steps)**

### 1. **Download and Install NetLogo**
- Go to: https://ccl.northwestern.edu/netlogo/
- Download NetLogo 6.0 or later
- Install it on your computer

### 2. **Open the Model**
- Launch NetLogo
- Click **File → Open**
- Navigate to: `d:\PYTHON_MESA\netlogo_gis_model\`
- Select: **`india_gis_standalone.nlogo`** (use this file, not the other one!)

### 3. **Run the Model**
- Click the **"Setup"** button (this loads all the Indian data)
- Click the **"Go"** button to start the simulation
- Try the display buttons: **"set-display-states"**, **"set-display-population"**

## **If You Get Errors**

### Error: "Cannot find file"
**Solution**: Make sure the `gis_data` folder is in the same directory as your NetLogo file.

If missing, run this in your terminal:
```bash
cd d:\PYTHON_MESA\netlogo_gis_model
python simple_data_generator.py
```

### Error: "Extension not found"
**Solution**: NetLogo 6.0+ should have the GIS extension built-in. If not:
1. Check you have NetLogo 6.0 or later
2. Try without GIS features (the model will use default data)

### Error: "Cannot load model"
**Solution**: Use the **`india_gis_standalone.nlogo`** file instead of the original one.

## **What You'll See**

### When Setup Runs:
```
Loading Indian GIS data...
States data loaded successfully
Cities data loaded successfully
Coordinate mappings loaded successfully
Indian GIS data loaded successfully!
```

### Visual Elements:
- **Colored patches** = Different Indian states
- **Red circles** = Major cities (Mumbai, Delhi, etc.)
- **Blue dots** = Agents (people) moving around
- **Different colors** = Population density when you change display mode

## **Interactive Features**

### Buttons to Try:
1. **Setup** - Load the Indian geographical data
2. **Go** - Start/stop the simulation
3. **set-display-states** - Show states in different colors
4. **set-display-population** - Show population density heatmap
5. **set-display-elevation** - Show elevation data
6. **analyze-region** - Click on patches then this button for statistics
7. **export-data** - Save results to CSV file

### What to Do:
1. Click **Setup** first
2. Try **set-display-states** to see different Indian states
3. Click **Go** to see agents (people) moving
4. Click on any patch, then **analyze-region** for details
5. Try **set-display-population** to see population density

## **Understanding the Display**

### States Mode (set-display-states):
- **Red** = Maharashtra
- **Green** = Karnataka  
- **Blue** = Tamil Nadu
- **Yellow** = Kerala
- **Orange** = Andhra Pradesh
- **Pink** = Telangana
- **Cyan** = Gujarat
- **Magenta** = Rajasthan
- And more...

### Population Mode (set-display-population):
- **Dark Red** = High population density (like Delhi, Mumbai)
- **Light Red/Pink** = Medium population density
- **White** = Low population density (rural areas)

### Cities:
- **Large Red Circles** = Metro cities (Mumbai, Delhi, Bangalore)
- **Medium Orange Circles** = Urban cities (Pune, Jaipur)

## **Monitors to Watch**

Look at the right side of NetLogo interface for:
- **total-population** = Total population across all patches
- **average-elevation** = Average elevation of the region
- **selected-state-name** = Name of the state you clicked on

## **Step-by-Step Walkthrough**

### Step 1: Basic Setup
1. Open NetLogo
2. Open `india_gis_standalone.nlogo`
3. Click **Setup**
4. You should see colored patches representing Indian states

### Step 2: Explore States
1. Click **set-display-states**
2. You'll see different Indian states in different colors
3. Click on any colored patch
4. Click **analyze-region** 
5. Check the Command Center (bottom) for state statistics

### Step 3: See Population Density
1. Click **set-display-population**
2. Dark red areas = high population (Delhi, Mumbai regions)
3. Light areas = low population (rural areas)

### Step 4: Start Simulation
1. Click **Go**
2. Watch blue dots (agents) move around
3. They tend to move toward red circles (cities)
4. This simulates people moving toward urban areas

### Step 5: Analyze Data
1. Let the simulation run for a while
2. Click **export-data**
3. Check your folder for `india_gis_model_data.csv`
4. Open it in Excel to see all the data

## **Common Issues and Solutions**

### Issue 1: "File not found" errors
```
Warning: States data file not found. Using default data.
Warning: Cities data file not found. Using default data.
Warning: Coordinate data file not found. Using default coordinates.
```

**Solution**: This is OK! The model will work with default data. If you want real data:
1. Run: `python simple_data_generator.py`
2. Then click **Setup** again in NetLogo

### Issue 2: Model appears empty
**Solution**: Click **Setup** button first, then try the display buttons.

### Issue 3: Nothing happens when clicking Go
**Solution**: Make sure you clicked **Setup** first.

### Issue 4: Cannot see cities
**Solution**: They might be outside the view. Try:
1. Click **set-display-states** first
2. Look for small red and orange circles
3. Zoom out if needed

## **What the Model Simulates**

### Agents (Blue Dots):
- Represent people or households
- Move around the landscape
- Attracted to cities (red circles)
- Have different mobility factors

### Cities (Red/Orange Circles):
- Based on real Indian cities
- Size indicates population
- Red = Metro cities (>5 million people)
- Orange = Urban cities (>500,000 people)

### States (Colored Patches):
- Based on real Indian state boundaries
- Colors help distinguish different states
- Each has real population density data

## **Advanced Features**

### Export Data:
- Click **export-data** to save simulation results
- Creates `india_gis_model_data.csv` with all patch data
- Includes coordinates, state names, population density, etc.

### Regional Analysis:
- Click on any patch to select a state
- Click **analyze-region** for detailed statistics
- Shows population, elevation, urban patches, etc.

### Custom Modifications:
- Edit the code to add new features
- Modify agent behavior
- Add new data sources
- Create custom visualizations

## **Need Help?**

If you're still having issues:
1. Make sure you're using `india_gis_standalone.nlogo` (not the other file)
2. Try running without the gis_data folder (model has defaults)
3. Check that NetLogo is version 6.0 or later
4. Look at the Command Center (bottom of NetLogo) for error messages

## **Success Indicators**

You know it's working when:
- You see colored patches (states)
- You see red circles (cities) 
- Blue dots move around when you click Go
- Display modes change the colors
- analyze-region gives you statistics

**Happy Modeling!** 
