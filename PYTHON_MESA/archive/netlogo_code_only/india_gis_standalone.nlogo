; NetLogo GIS Model for Indian Region - Standalone Version
; This model demonstrates basic GIS integration with NetLogo using Indian geographical data

extensions [
  gis        ; GIS extension for loading shapefiles and raster data
  table      ; Table extension for data structures
]

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
  
  ; Data tables for loaded data
  states-data-table
  cities-data-table
  states-coordinates-table
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

; Data loading procedures
to load-indian-gis-data
  print "Loading Indian GIS data..."
  
  ; Initialize tables
  set states-data-table table:make
  set cities-data-table table:make
  set states-coordinates-table table:make
  
  ; Load states data
  load-states-data
  
  ; Load cities data
  load-cities-data
  
  ; Load coordinate mappings
  load-coordinates-data
  
  print "Indian GIS data loaded successfully!"
end

to load-states-data
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
  ] [
    print "Warning: States data file not found. Using default data."
    create-default-states-data
  ]
end

to load-cities-data
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
  ] [
    print "Warning: Cities data file not found. Using default data."
    create-default-cities-data
  ]
end

to load-coordinates-data
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
  ] [
    print "Warning: Coordinate data file not found. Using default coordinates."
    create-default-coordinates
  ]
end

to create-default-states-data
  ; Create basic default data if files are missing
  let default-states ["Maharashtra" "Karnataka" "Tamil Nadu" "Kerala" "Gujarat" 
                     "Rajasthan" "Uttar Pradesh" "West Bengal" "Andhra Pradesh" "Madhya Pradesh"]
  
  foreach default-states [ state ->
    let pop-density 200 + random 800
    table:put states-data-table state (list "XX" 20 75 100000 pop-density)
  ]
end

to create-default-cities-data
  ; Create basic default cities if files are missing
  let default-cities [["Mumbai" "Maharashtra" 19.076 72.877 12442373 "metro"]
                     ["Delhi" "Delhi" 28.614 77.209 11007835 "metro"]
                     ["Bangalore" "Karnataka" 12.972 77.595 8443675 "metro"]
                     ["Chennai" "Tamil Nadu" 13.083 80.271 4681087 "metro"]
                     ["Kolkata" "West Bengal" 22.573 88.364 4486679 "metro"]]
  
  foreach default-cities [ city-data ->
    let city-name item 0 city-data
    let state-name item 1 city-data
    let lat item 2 city-data
    let lon item 3 city-data
    let population item 4 city-data
    let city-type item 5 city-data
    
    table:put cities-data-table city-name (list state-name lat lon population city-type)
  ]
end

to create-default-coordinates
  ; Create basic coordinate mappings if files are missing
  let default-coords [["Maharashtra" -20 0] ["Karnataka" -10 -20] ["Tamil Nadu" 0 -30]
                     ["Kerala" -5 -35] ["Gujarat" -30 10] ["Rajasthan" -10 20]
                     ["Uttar Pradesh" 10 20] ["West Bengal" 30 10] ["Andhra Pradesh" 5 -25]
                     ["Madhya Pradesh" 0 5]]
  
  foreach default-coords [ coord-data ->
    let state-name item 0 coord-data
    let x item 1 coord-data
    let y item 2 coord-data
    
    table:put states-coordinates-table state-name (list x y)
  ]
end

to setup-world-envelope
  ; Set world envelope to cover major Indian regions
  let min-x -50
  let max-x 50
  let min-y -50
  let max-y 50
  
  ; Resize world to match GIS data
  resize-world min-x max-x min-y max-y
  
  ; Set patch size for better visualization
  set-patch-size 4
end

to setup-real-indian-states
  ; Initialize patches with real Indian state data
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
      set elevation-value random-float 3000 + 100
      set distance-to-coast distance patch 0 max-pycor + distance patch 0 min-pycor
      set distance-to-coast distance-to-coast + distance patch min-pxcor 0 + distance patch max-pxcor 0
      set distance-to-coast distance-to-coast / 4
    ]
  ]
end

to setup-real-indian-cities
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
  table:put state-colors "Punjab" 45
  table:put state-colors "Haryana" 65
  table:put state-colors "Delhi" 15
  table:put state-colors "Goa" 25
  table:put state-colors "Assam" 85
  
  ask patches [
    if table:has-key? state-colors state-name [
      let state-color table:get state-colors state-name
      set pcolor state-color
    ] [
      set pcolor gray
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
