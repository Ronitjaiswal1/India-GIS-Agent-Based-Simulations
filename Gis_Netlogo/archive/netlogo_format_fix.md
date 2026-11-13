# NetLogo 6.4 Model Format Fix Guide

## The Problem
NetLogo 6.4 requires models to be in a specific XML format. When you create a `.nlogo` file as plain text, NetLogo can't read it properly and shows the "unable to open with current format" error.

## Solution Options

### Option 1: Use the Simple Model (Recommended)
I've created `indian_map_simple.nlogo` which should work better with NetLogo 6.4.

**Steps:**
1. Try opening `indian_map_simple.nlogo` instead
2. If it works, you can use this as your base model
3. Add any customizations you need

### Option 2: Auto-Fix with PowerShell Script
Run the PowerShell script to automatically create a proper NetLogo model:

```powershell
.\create_model_netlogo64.ps1
```

This script will:
1. Find your NetLogo installation
2. Create a temporary model file
3. Open NetLogo with the model
4. Guide you to save it in proper format

### Option 3: Manual Fix in NetLogo
If the above options don't work:

1. **Open NetLogo 6.4**
2. **Create a new model** (File → New)
3. **Copy the code** from `indian_map_simple.nlogo` or the code section below
4. **Paste it into the Code tab** in NetLogo
5. **Add buttons and interface elements**:
   - Add a "setup" button
   - Add a "go" button  
   - Add a "go forever" button (with forever checkbox checked)
   - Add a "reset-colors" button
   - Add monitors for land patches, agents, and cities
6. **Save the model** (File → Save As → `indian_map_model.nlogo`)

### Option 4: Import the Code Manually

**Complete NetLogo Code to Copy-Paste:**

```netlogo
extensions [gis]

globals [
  india-dataset
  states-dataset
]

breed [cities city]
breed [agents agent]

patches-own [
  state-name
  is-land?
]

cities-own [
  city-name
  population
]

to setup
  clear-all
  
  ; Load the Indian map data
  load-india-map
  
  ; Set up the display
  setup-display
  
  ; Create some sample agents
  create-sample-agents
  
  reset-ticks
end

to load-india-map
  ; Try to load the India boundary shapefile
  if file-exists? "data/india_boundary.shp" [
    set india-dataset gis:load-dataset "data/india_boundary.shp"
    gis:set-world-envelope (gis:envelope-of india-dataset)
    gis:apply-coverage india-dataset "NAME" state-name
    
    ask patches [
      set is-land? (state-name != 0 and state-name != "")
      if is-land? [
        set pcolor green + 2
      ]
    ]
    
    gis:set-drawing-color black
    gis:draw india-dataset 2
  ]
  
  ; Load states dataset if available
  if file-exists? "data/india_states.shp" [
    set states-dataset gis:load-dataset "data/india_states.shp"
    gis:set-drawing-color white
    gis:draw states-dataset 1
  ]
  
  ; If shapefiles don't exist, create a basic map representation
  if not file-exists? "data/india_boundary.shp" [
    create-basic-india-outline
  ]
end

to create-basic-india-outline
  print "Shapefile not found. Creating basic India outline..."
  
  ask patches [
    let x pxcor
    let y pycor
    
    if (x >= -15 and x <= 15 and y >= -20 and y <= 20) [
      if (y > -15 and y < 15) [
        if (x >= -10 and x <= 10) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
      
      if (y >= 0 and y <= 15) [
        if (x >= -12 and x <= 12) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
      
      if (y >= -20 and y <= -10) [
        if (x >= -5 and x <= 5) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
    ]
  ]
  
  create-major-cities
end

to create-major-cities
  create-cities 1 [
    set city-name "New Delhi"
    set population 30000000
    setxy 0 8
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    set city-name "Mumbai"
    set population 20000000
    setxy -8 2
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    set city-name "Kolkata"
    set population 14000000
    setxy 8 5
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    set city-name "Chennai"
    set population 10000000
    setxy 5 -10
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    set city-name "Bangalore"
    set population 12000000
    setxy 2 -8
    set color red
    set size 3
    set shape "circle"
  ]
end

to setup-display
  ask patches [
    if not is-land? [
      set pcolor blue + 3
    ]
  ]
  
  ask cities [
    set label city-name
    set label-color black
  ]
end

to create-sample-agents
  create-agents 50 [
    let land-patches patches with [is-land?]
    if any? land-patches [
      move-to one-of land-patches
    ]
    set color yellow
    set size 0.8
    set shape "circle"
  ]
end

to go
  ask agents [
    move-agent
  ]
  tick
end

to move-agent
  let target-patch one-of neighbors with [is-land?]
  if target-patch != nobody [
    move-to target-patch
  ]
end

to reset-colors
  ask patches [
    if is-land? [
      set pcolor green + 2
    ] [
      set pcolor blue + 3
    ]
  ]
end

to-report total-land-patches
  report count patches with [is-land?]
end

to-report total-agents
  report count agents
end

to-report total-cities
  report count cities
end
```

## Interface Elements to Add

After pasting the code, add these interface elements:

### Buttons:
- **setup** (Action key: S)
- **go** (Action key: G, not forever)
- **go forever** (Action key: F, forever checkbox checked)
- **reset-colors** (Action key: R)

### Monitors:
- **Land Patches**: `total-land-patches`
- **Total Agents**: `total-agents`
- **Total Cities**: `total-cities`

### Text Box:
Add instructions for users:
```
Indian Map Interface

1. Click 'setup' to load the map
2. Click 'go' to start simulation
3. Click on map areas to explore
4. Use 'reset-colors' to restore colors

Yellow dots = agents
Red dots = major cities
```

## Testing the Model

1. **Click "setup"** - Should show Indian map outline
2. **Click "go"** - Should show yellow agents moving
3. **Check for errors** in the command center
4. **Save the model** once it's working

## Common Issues and Solutions

### "Extension not found" Error:
- Make sure you're using NetLogo 6.0 or later
- The GIS extension comes built-in with NetLogo

### "File not found" Error:
- This is normal if you don't have shapefiles yet
- The model will show a basic India outline instead

### Interface Elements Missing:
- You need to manually add buttons and monitors in Interface tab
- Copy the layout from any working NetLogo model

### Still Can't Open Model:
- Try starting with the NetLogo models library
- Open any sample model, replace the code, and save as new file

## Final Notes

Once you get a working model saved by NetLogo itself, it will be in the proper format and will open correctly every time. The key is getting NetLogo to save it in its native format rather than trying to create the XML structure manually.
