; NetLogo Model for Indian Region Simulation
; Simple version without GIS extension dependencies

extensions [
  table      ; Table extension for data structures
]

globals [
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
  
  ; Load Indian data
  load-indian-data
  
  ; Setup world
  setup-world
  
  ; Initialize patches with Indian state data
  setup-indian-states
  
  ; Create cities
  setup-indian-cities
  
  ; Create agents
  setup-agents
  
  ; Set initial display mode
  set display-mode "states"
  
  ; Update display
  update-display
  
  reset-ticks
end

to load-indian-data
  print "Loading Indian data..."
  
  ; Initialize tables
  set states-data-table table:make
  set cities-data-table table:make
  set states-coordinates-table table:make
  
  ; Load data from files or create defaults
  load-states-data
  load-cities-data
  load-coordinates-data
  
  print "Indian data loaded successfully!"
end

to load-states-data
  ; Try to load from file, otherwise use defaults
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
    print "States data loaded from file"
  ] [
    ; Create default states data
    create-default-states-data
    print "Using default states data"
  ]
end

to load-cities-data
  ; Try to load from file, otherwise use defaults
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
    print "Cities data loaded from file"
  ] [
    ; Create default cities data
    create-default-cities-data
    print "Using default cities data"
  ]
end

to load-coordinates-data
  ; Try to load from file, otherwise use defaults
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
    print "Coordinates loaded from file"
  ] [
    ; Create default coordinates
    create-default-coordinates
    print "Using default coordinates"
  ]
end

to create-default-states-data
  ; Indian states with approximate population densities
  let states-info [
    ["Maharashtra" "MH" 19.75 75.71 307713 365]
    ["Karnataka" "KA" 15.32 75.71 191791 319]
    ["Tamil Nadu" "TN" 11.13 78.66 130060 555]
    ["Kerala" "KL" 10.85 76.27 38852 860]
    ["Andhra Pradesh" "AP" 15.91 79.74 160205 308]
    ["Telangana" "TG" 18.11 79.02 114840 312]
    ["Gujarat" "GJ" 23.02 72.57 196244 308]
    ["Rajasthan" "RJ" 27.02 74.22 342239 200]
    ["Madhya Pradesh" "MP" 22.97 78.66 308245 236]
    ["Uttar Pradesh" "UP" 26.85 80.95 240928 828]
    ["West Bengal" "WB" 22.99 87.86 88752 1028]
    ["Odisha" "OR" 20.95 85.10 155707 270]
    ["Bihar" "BR" 25.10 85.31 94163 1106]
    ["Jharkhand" "JH" 23.61 85.28 79716 414]
    ["Chhattisgarh" "CG" 21.28 81.87 135192 189]
    ["Punjab" "PB" 31.15 75.34 50362 551]
    ["Haryana" "HR" 29.06 76.09 44212 573]
    ["Delhi" "DL" 28.70 77.10 1484 11320]
    ["Himachal Pradesh" "HP" 31.10 77.17 55673 123]
    ["Uttarakhand" "UK" 30.07 79.02 53483 189]
    ["Assam" "AS" 26.20 92.94 78438 398]
    ["Goa" "GA" 15.30 74.12 3702 394]
  ]
  
  foreach states-info [ state-info ->
    let state-name item 0 state-info
    let state-code item 1 state-info
    let lat item 2 state-info
    let lon item 3 state-info
    let area item 4 state-info
    let pop-density item 5 state-info
    
    table:put states-data-table state-name (list state-code lat lon area pop-density)
  ]
end

to create-default-cities-data
  ; Major Indian cities with real data
  let cities-info [
    ["Mumbai" "Maharashtra" 19.076 72.877 12442373 "metro"]
    ["Delhi" "Delhi" 28.614 77.209 11007835 "metro"]
    ["Bangalore" "Karnataka" 12.972 77.595 8443675 "metro"]
    ["Hyderabad" "Telangana" 17.385 78.487 6809970 "metro"]
    ["Ahmedabad" "Gujarat" 23.023 72.571 5570585 "metro"]
    ["Chennai" "Tamil Nadu" 13.083 80.271 4681087 "metro"]
    ["Kolkata" "West Bengal" 22.573 88.364 4486679 "metro"]
    ["Surat" "Gujarat" 21.196 72.830 4467797 "urban"]
    ["Pune" "Maharashtra" 18.520 73.857 3124458 "urban"]
    ["Jaipur" "Rajasthan" 26.912 75.787 3046163 "urban"]
    ["Lucknow" "Uttar Pradesh" 26.847 80.946 2817105 "urban"]
    ["Kanpur" "Uttar Pradesh" 26.450 80.332 2767031 "urban"]
    ["Nagpur" "Maharashtra" 21.146 79.088 2405421 "urban"]
    ["Indore" "Madhya Pradesh" 22.720 75.858 1964086 "urban"]
    ["Bhopal" "Madhya Pradesh" 23.260 77.413 1798218 "urban"]
    ["Patna" "Bihar" 25.594 85.138 1684222 "urban"]
    ["Vadodara" "Gujarat" 22.307 73.181 1666703 "urban"]
    ["Ludhiana" "Punjab" 30.901 75.857 1618879 "urban"]
    ["Agra" "Uttar Pradesh" 27.177 78.008 1585704 "urban"]
    ["Nashik" "Maharashtra" 19.998 73.790 1486973 "urban"]
  ]
  
  foreach cities-info [ city-info ->
    let city-name item 0 city-info
    let state-name item 1 city-info
    let lat item 2 city-info
    let lon item 3 city-info
    let population item 4 city-info
    let city-type item 5 city-info
    
    table:put cities-data-table city-name (list state-name lat lon population city-type)
  ]
end

to create-default-coordinates
  ; NetLogo coordinates for Indian states
  let coords-info [
    ["Maharashtra" -20 -5]
    ["Karnataka" -15 -25]
    ["Tamil Nadu" -5 -35]
    ["Kerala" -10 -40]
    ["Andhra Pradesh" 0 -20]
    ["Telangana" -5 -15]
    ["Gujarat" -35 5]
    ["Rajasthan" -15 15]
    ["Madhya Pradesh" -5 0]
    ["Uttar Pradesh" 10 10]
    ["West Bengal" 30 5]
    ["Odisha" 20 -10]
    ["Bihar" 25 5]
    ["Jharkhand" 20 0]
    ["Chhattisgarh" 10 -5]
    ["Punjab" 0 25]
    ["Haryana" 5 20]
    ["Delhi" 8 22]
    ["Himachal Pradesh" 5 30]
    ["Uttarakhand" 10 25]
    ["Assam" 40 15]
    ["Goa" -25 -30]
  ]
  
  foreach coords-info [ coord-info ->
    let state-name item 0 coord-info
    let x item 1 coord-info
    let y item 2 coord-info
    
    table:put states-coordinates-table state-name (list x y)
  ]
end

to setup-world
  ; Set up the NetLogo world
  resize-world -50 50 -50 50
  set-patch-size 4
end

to setup-indian-states
  ; Initialize patches with Indian state data
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
    
    ; Set patch properties
    if closest-state != "" [
      set state-name closest-state
      set population-density get-state-population-density closest-state
      set is-urban (population-density > 500)
      set elevation-value random-float 3000 + 100
      set distance-to-coast abs pxcor + abs pycor
    ]
  ]
end

to setup-indian-cities
  ; Create cities from data
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
          
          ; Set appearance
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
  ; Create agents (people)
  create-agents 200 [
    setxy random-xcor random-ycor
    set home-state [state-name] of patch-here
    set current-location patch-here
    set mobility-factor random-float 1.0
    set color blue
    set size 1
    set shape "person"
  ]
end

to go
  ; Main simulation loop
  if ticks > 1000 [ stop ]
  
  move-agents
  update-statistics
  update-display
  
  tick
end

to move-agents
  ask agents [
    let target-city min-one-of cities [distance myself]
    
    if target-city != nobody and mobility-factor > 0.5 [
      face target-city
      forward 0.1 + random-float 0.2
    ] [
      rt random 360
      forward random-float 0.5
    ]
    
    set current-location patch-here
  ]
end

to update-statistics
  set total-population sum [population-density] of patches
  set average-elevation mean [elevation-value] of patches
  
  if mouse-down? [
    let target-patch patch mouse-xcor mouse-ycor
    if target-patch != nobody [
      set selected-state-name [state-name] of target-patch
    ]
  ]
end

to update-display
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
  table:put state-colors "Himachal Pradesh" 85
  table:put state-colors "Uttarakhand" 95
  table:put state-colors "Assam" 105
  table:put state-colors "Goa" 25
  
  ask patches [
    if table:has-key? state-colors state-name [
      set pcolor table:get state-colors state-name
    ] [
      set pcolor gray
    ]
  ]
end

to color-patches-by-population
  let max-pop max [population-density] of patches
  let min-pop min [population-density] of patches
  
  ask patches [
    let normalized-pop (population-density - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
  ]
end

to color-patches-by-elevation
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
  let filename "india_model_data.csv"
  
  file-open filename
  file-print "x,y,state,population_density,elevation,is_urban"
  
  ask patches [
    file-print (word pxcor "," pycor "," state-name "," population-density "," 
                elevation-value "," is-urban)
  ]
  
  file-close
  print (word "Data exported to " filename)
end

; Utility functions
to-report get-state-population-density [state-name]
  if states-data-table != 0 and table:has-key? states-data-table state-name [
    let state-data table:get states-data-table state-name
    report item 4 state-data
  ]
  report 100
end

to-report get-state-coordinates [state-name]
  if states-coordinates-table != 0 and table:has-key? states-coordinates-table state-name [
    report table:get states-coordinates-table state-name
  ]
  report (list 0 0)
end

to-report get-city-data [city-name]
  if cities-data-table != 0 and table:has-key? cities-data-table city-name [
    report table:get cities-data-table city-name
  ]
  report nobody
end

to-report convert-latlon-to-netlogo [lat lon]
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
