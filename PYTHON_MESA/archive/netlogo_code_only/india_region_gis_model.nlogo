; NetLogo GIS Model for Indian Region
; This model demonstrates basic GIS integration with NetLogo using Indian geographical data

extensions [
  gis        ; GIS extension for loading shapefiles and raster data
  table      ; Table extension for data structures
]

__includes ["gis_data/netlogo_data_loader.nls"]

globals [
  ; GIS datasets
  india-states-dataset      ; Shapefile of Indian states
  population-dataset        ; Population density raster
  elevation-dataset         ; Elevation raster
  
  ; Model parameters
  world-envelope           ; Bounding box for the world
  current-state           ; Currently selected state
  
  ; Visualization settings
  display-mode            ; "states", "population", "elevation"
  
  ; Statistics
  total-population
  average-elevation
  selected-state-name
]

patches-own [
  state-name               ; Name of the state this patch belongs to
  population-density       ; Population density value
  elevation-value          ; Elevation value
  is-urban                 ; Boolean: is this patch urban?
  distance-to-coast        ; Distance to nearest coast
]

breed [agents person]
breed [cities city]

agents-own [
  home-state
  current-location
  mobility-factor
]

cities-own [
  city-name
  city-population
  city-type               ; "metro", "urban", "rural"
]

to setup
  clear-all
  
  ; Load real Indian GIS data
  load-indian-gis-data
  
  ; Setup world envelope
  setup-world-envelope
  
  ; Initialize patches with real GIS data
  setup-real-indian-states
  
  ; Create cities from real data
  setup-real-indian-cities
  
  ; Create agents
  setup-agents
  
  ; Set initial display mode
  set display-mode "states"
  
  ; Update display
  update-display
  
  reset-ticks
end

to load-gis-data
  ; Load Indian states shapefile
  ; Note: You need to download actual shapefiles and place them in gis_data folder
  ; For demonstration, we'll create mock data
  
  ; Uncomment and modify these lines when you have actual GIS data:
  ; set india-states-dataset gis:load-dataset "gis_data/indian_states.shp"
  ; set population-dataset gis:load-dataset "gis_data/population_density.asc"
  ; set elevation-dataset gis:load-dataset "gis_data/elevation.asc"
  
  ; For now, we'll work with mock data
  print "Loading GIS data..."
  print "Note: To use real GIS data, download Indian state shapefiles and place in gis_data folder"
end

to setup-world-envelope
  ; Set world envelope to cover major Indian regions
  ; Approximate bounds for India: 6.5°N to 37°N, 68°E to 97.5°E
  
  ; For NetLogo world coordinates, we'll use a simplified projection
  ; You can modify these coordinates based on your specific region of interest
  let min-x -50
  let max-x 50
  let min-y -50
  let max-y 50
  
  ; Resize world to match GIS data
  resize-world min-x max-x min-y max-y
  
  ; Set patch size for better visualization
  set-patch-size 4
end

to setup-patches
  ; Initialize patches with mock Indian geographical data
  ; In a real implementation, you would use GIS data
  
  ask patches [
    ; Assign random state names (replace with actual GIS data)
    set state-name one-of ["Maharashtra" "Karnataka" "Tamil Nadu" "Kerala" "Andhra Pradesh" 
                          "Telangana" "Gujarat" "Rajasthan" "Madhya Pradesh" "Uttar Pradesh"
                          "West Bengal" "Odisha" "Bihar" "Jharkhand" "Chhattisgarh"]
    
    ; Set population density (mock data - replace with raster data)
    set population-density random-float 1000 + 50
    
    ; Set elevation (mock data - replace with DEM data)
    set elevation-value random-float 3000 + 100
    
    ; Determine if urban based on population density
    set is-urban (population-density > 500)
    
    ; Calculate distance to coast (simplified)
    set distance-to-coast distance patch 0 max-pycor + distance patch 0 min-pycor
    set distance-to-coast distance-to-coast + distance patch min-pxcor 0 + distance patch max-pxcor 0
    set distance-to-coast distance-to-coast / 4
  ]
end

to setup-cities
  ; Create major Indian cities
  let major-cities table:make
  
  ; Add major cities with approximate coordinates (simplified for demo)
  table:put major-cities "Mumbai" (list -20 0 12500000 "metro")
  table:put major-cities "Delhi" (list 10 20 11000000 "metro")
  table:put major-cities "Bangalore" (list -10 -20 8400000 "metro")
  table:put major-cities "Chennai" (list 0 -30 7000000 "metro")
  table:put major-cities "Kolkata" (list 25 15 4500000 "metro")
  table:put major-cities "Hyderabad" (list 5 -10 6800000 "metro")
  table:put major-cities "Pune" (list -15 -5 3100000 "urban")
  table:put major-cities "Ahmedabad" (list -25 10 5500000 "urban")
  
  ; Create city agents
  let city-names table:keys major-cities
  foreach city-names [ city-name ->
    let city-data table:get major-cities city-name
    let x-coord item 0 city-data
    let y-coord item 1 city-data
    let population item 2 city-data
    let type item 3 city-data
    
    ; Create city only if coordinates are within world bounds
    if x-coord >= min-pxcor and x-coord <= max-pxcor and 
       y-coord >= min-pycor and y-coord <= max-pycor [
      create-cities 1 [
        setxy x-coord y-coord
        set city-name city-name
        set city-population population
        set city-type type
        set color red
        set size 2
        set shape "circle"
      ]
    ]
  ]
end

to setup-agents
  ; Create agents representing people
  create-agents 200 [
    ; Place agents randomly
    setxy random-xcor random-ycor
    
    ; Set agent properties
    set home-state [state-name] of patch-here
    set current-location patch-here
    set mobility-factor random-float 1.0
    
    ; Set appearance
    set color blue
    set size 1
    set shape "person"
  ]
end

to go
  ; Main simulation loop
  if ticks > 1000 [ stop ]
  
  ; Move agents
  move-agents
  
  ; Update statistics
  update-statistics
  
  ; Update display
  update-display
  
  tick
end

to move-agents
  ask agents [
    ; Simple movement model
    ; Agents move towards cities with some randomness
    
    let target-city min-one-of cities [distance myself]
    
    if target-city != nobody and mobility-factor > 0.5 [
      ; Move towards nearest city
      face target-city
      forward 0.1 + random-float 0.2
    ] [
      ; Random movement
      rt random 360
      forward random-float 0.5
    ]
    
    ; Update current location
    set current-location patch-here
  ]
end

to update-statistics
  ; Calculate total population
  set total-population sum [population-density] of patches
  
  ; Calculate average elevation
  set average-elevation mean [elevation-value] of patches
  
  ; Find selected state (if any)
  if mouse-down? [
    let target-patch patch mouse-xcor mouse-ycor
    if target-patch != nobody [
      set selected-state-name [state-name] of target-patch
    ]
  ]
end

to update-display
  ; Update patch colors based on display mode
  if display-mode = "states" [
    color-patches-by-state
  ]
  if display-mode = "population" [
    color-patches-by-population
  ]
  if display-mode = "elevation" [
    color-patches-by-elevation
  ]
end

to color-patches-by-state
  ; Color patches by state
  let state-colors table:make
  table:put state-colors "Maharashtra" red
  table:put state-colors "Karnataka" green
  table:put state-colors "Tamil Nadu" blue
  table:put state-colors "Kerala" yellow
  table:put state-colors "Andhra Pradesh" orange
  table:put state-colors "Telangana" pink
  table:put state-colors "Gujarat" cyan
  table:put state-colors "Rajasthan" magenta
  table:put state-colors "Madhya Pradesh" brown
  table:put state-colors "Uttar Pradesh" gray
  table:put state-colors "West Bengal" violet
  table:put state-colors "Odisha" lime
  table:put state-colors "Bihar" turquoise
  table:put state-colors "Jharkhand" 135
  table:put state-colors "Chhattisgarh" 125
  
  ask patches [
    let state-color table:get state-colors state-name
    if state-color != 0 [
      set pcolor state-color
    ]
  ]
end

to color-patches-by-population
  ; Color patches by population density
  let max-pop max [population-density] of patches
  let min-pop min [population-density] of patches
  
  ask patches [
    let normalized-pop (population-density - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
  ]
end

to color-patches-by-elevation
  ; Color patches by elevation
  let max-elev max [elevation-value] of patches
  let min-elev min [elevation-value] of patches
  
  ask patches [
    let normalized-elev (elevation-value - min-elev) / (max-elev - min-elev)
    set pcolor scale-color green normalized-elev 0 1
  ]
end

; Button procedures
to set-display-states
  set display-mode "states"
  update-display
end

to set-display-population
  set display-mode "population"
  update-display
end

to set-display-elevation
  set display-mode "elevation"
  update-display
end

to analyze-region
  ; Analyze selected region
  if selected-state-name != 0 [
    let state-patches patches with [state-name = selected-state-name]
    let state-population sum [population-density] of state-patches
    let state-avg-elevation mean [elevation-value] of state-patches
    let urban-patches count state-patches with [is-urban]
    
    print (word "Analysis for " selected-state-name ":")
    print (word "  Total Population: " precision state-population 0)
    print (word "  Average Elevation: " precision state-avg-elevation 2 " meters")
    print (word "  Urban Patches: " urban-patches)
    print (word "  Total Patches: " count state-patches)
  ]
end

to export-data
  ; Export model data to CSV
  let filename "india_gis_model_data.csv"
  
  ; Export patch data
  file-open filename
  file-print "x,y,state,population_density,elevation,is_urban,distance_to_coast"
  
  ask patches [
    file-print (word pxcor "," pycor "," state-name "," population-density "," 
                elevation-value "," is-urban "," distance-to-coast)
  ]
  
  file-close
  print (word "Data exported to " filename)
end

; Reporter procedures
to-report get-state-population [state]
  let state-patches patches with [state-name = state]
  report sum [population-density] of state-patches
end

to-report get-urban-ratio [state]
  let state-patches patches with [state-name = state]
  let urban-count count state-patches with [is-urban]
  let total-count count state-patches
  report urban-count / total-count
end

to-report get-coastal-patches
  report patches with [distance-to-coast < 5]
end
