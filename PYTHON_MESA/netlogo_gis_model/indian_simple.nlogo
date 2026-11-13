; Simple Indian Region Model for NetLogo
; Basic version that should load in any NetLogo installation

globals [
  display-mode
  selected-state-name
]

patches-own [
  state-name
  population-density
  is-urban
]

breed [people person]
breed [cities city]

people-own [
  home-state
]

cities-own [
  city-name
  city-population
]

to setup
  clear-all
  
  ; Setup the world
  resize-world -50 50 -50 50
  set-patch-size 4
  
  ; Create Indian states
  setup-indian-states
  
  ; Create major cities
  setup-major-cities
  
  ; Create people
  setup-people
  
  ; Set display mode
  set display-mode "states"
  update-display
  
  reset-ticks
end

to setup-indian-states
  ; Define major Indian states with their approximate locations
  let states [
    ["Maharashtra" -20 -5 365]
    ["Karnataka" -15 -25 319]
    ["Tamil Nadu" -5 -35 555]
    ["Kerala" -10 -40 860]
    ["Andhra Pradesh" 0 -20 308]
    ["Gujarat" -35 5 308]
    ["Rajasthan" -15 15 200]
    ["Madhya Pradesh" -5 0 236]
    ["Uttar Pradesh" 10 10 828]
    ["West Bengal" 30 5 1028]
    ["Odisha" 20 -10 270]
    ["Bihar" 25 5 1106]
    ["Punjab" 0 25 551]
    ["Haryana" 5 20 573]
    ["Delhi" 8 22 11320]
    ["Assam" 40 15 398]
  ]
  
  ; Assign states to patches based on proximity
  ask patches [
    let closest-state ""
    let min-distance 1000
    let closest-pop-density 100
    
    foreach states [ state-info ->
      let state-name-temp item 0 state-info
      let state-x item 1 state-info
      let state-y item 2 state-info
      let pop-density item 3 state-info
      
      let dist sqrt ((pxcor - state-x) ^ 2 + (pycor - state-y) ^ 2)
      
      if dist < min-distance [
        set min-distance dist
        set closest-state state-name-temp
        set closest-pop-density pop-density
      ]
    ]
    
    set state-name closest-state
    set population-density closest-pop-density + random 200 - 100
    set is-urban (population-density > 500)
  ]
end

to setup-major-cities
  ; Create major Indian cities
  let major-cities [
    ["Mumbai" -20 -5 12442373]
    ["Delhi" 8 22 11007835]
    ["Bangalore" -15 -25 8443675]
    ["Chennai" -5 -35 4681087]
    ["Kolkata" 30 5 4486679]
    ["Hyderabad" 0 -20 6809970]
    ["Pune" -18 -8 3124458]
    ["Ahmedabad" -35 5 5570585]
    ["Jaipur" -15 15 3046163]
    ["Lucknow" 10 10 2817105]
  ]
  
  foreach major-cities [ city-info ->
    let city-name-temp item 0 city-info
    let city-x item 1 city-info
    let city-y item 2 city-info
    let city-pop item 3 city-info
    
    create-cities 1 [
      setxy city-x city-y
      set city-name city-name-temp
      set city-population city-pop
      
      ; Set appearance based on population
      if city-pop > 5000000 [
        set color red
        set size 3
      ] [
        set color orange
        set size 2
      ]
      
      set shape "circle"
    ]
  ]
end

to setup-people
  create-people 200 [
    setxy random-xcor random-ycor
    set home-state [state-name] of patch-here
    set color blue
    set size 1
    set shape "person"
  ]
end

to go
  if ticks > 1000 [ stop ]
  
  ; Move people
  ask people [
    let nearest-city min-one-of cities [distance myself]
    
    if nearest-city != nobody and random-float 1 > 0.7 [
      face nearest-city
      forward 0.1 + random-float 0.3
    ] [
      rt random 360
      forward random-float 0.5
    ]
  ]
  
  ; Update display
  update-display
  
  ; Check for mouse clicks
  if mouse-down? [
    let clicked-patch patch mouse-xcor mouse-ycor
    if clicked-patch != nobody [
      set selected-state-name [state-name] of clicked-patch
    ]
  ]
  
  tick
end

to update-display
  if display-mode = "states" [
    show-states
  ]
  if display-mode = "population" [
    show-population
  ]
end

to show-states
  ask patches [
    if state-name = "Maharashtra" [ set pcolor red ]
    if state-name = "Karnataka" [ set pcolor green ]
    if state-name = "Tamil Nadu" [ set pcolor blue ]
    if state-name = "Kerala" [ set pcolor yellow ]
    if state-name = "Andhra Pradesh" [ set pcolor orange ]
    if state-name = "Gujarat" [ set pcolor cyan ]
    if state-name = "Rajasthan" [ set pcolor magenta ]
    if state-name = "Madhya Pradesh" [ set pcolor brown ]
    if state-name = "Uttar Pradesh" [ set pcolor gray ]
    if state-name = "West Bengal" [ set pcolor violet ]
    if state-name = "Odisha" [ set pcolor lime ]
    if state-name = "Bihar" [ set pcolor turquoise ]
    if state-name = "Punjab" [ set pcolor pink ]
    if state-name = "Haryana" [ set pcolor 65 ]
    if state-name = "Delhi" [ set pcolor 15 ]
    if state-name = "Assam" [ set pcolor 105 ]
  ]
end

to show-population
  let max-pop max [population-density] of patches
  let min-pop min [population-density] of patches
  
  ask patches [
    let normalized-pop (population-density - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
  ]
end

; Button procedures
to display-states
  set display-mode "states"
  update-display
end

to display-population
  set display-mode "population"
  update-display
end

to analyze-region
  if selected-state-name != 0 [
    let state-patches patches with [state-name = selected-state-name]
    let total-pop sum [population-density] of state-patches
    let urban-count count state-patches with [is-urban]
    let total-patches count state-patches
    
    print (word "=== Analysis for " selected-state-name " ===")
    print (word "Total Population Density: " precision total-pop 0)
    print (word "Urban Patches: " urban-count " out of " total-patches)
    print (word "Urban Percentage: " precision (urban-count / total-patches * 100) 1 "%")
    print (word "People in State: " count people with [home-state = selected-state-name])
  ]
end

to export-data
  let filename "indian_model_export.csv"
  
  if file-exists? filename [
    file-delete filename
  ]
  
  file-open filename
  file-print "x,y,state_name,population_density,is_urban"
  
  ask patches [
    file-print (word pxcor "," pycor "," state-name "," population-density "," is-urban)
  ]
  
  file-close
  
  print (word "Data exported to " filename)
  print (word "Total patches exported: " count patches)
end
