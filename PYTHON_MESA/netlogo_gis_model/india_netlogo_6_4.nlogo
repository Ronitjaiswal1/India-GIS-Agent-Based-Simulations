; NetLogo 6.4 Compatible India GIS Model
; Created for NetLogo 6.4 with proper syntax and extensions

extensions [table]

globals [
  ; Model parameters
  selected-state-name
  display-mode
  total-population
  
  ; Data storage
  states-data
  cities-data
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
  mobility-factor
]

cities-own [
  city-name
  city-population
  city-type
]

to setup
  clear-all
  
  ; Initialize data
  initialize-data
  
  ; Setup world
  setup-world
  
  ; Create states
  create-indian-states
  
  ; Create cities
  create-indian-cities
  
  ; Create people
  create-people-agents
  
  ; Set initial display
  set display-mode "states"
  show-states
  
  reset-ticks
end

to initialize-data
  ; Initialize tables for NetLogo 6.4
  set states-data table:make
  set cities-data table:make
  
  ; Add state data (name, population-density, color)
  table:put states-data "Maharashtra" (list 365 red)
  table:put states-data "Karnataka" (list 319 green)
  table:put states-data "Tamil Nadu" (list 555 blue)
  table:put states-data "Kerala" (list 860 yellow)
  table:put states-data "Gujarat" (list 308 cyan)
  table:put states-data "Rajasthan" (list 200 magenta)
  table:put states-data "Uttar Pradesh" (list 828 gray)
  table:put states-data "West Bengal" (list 1028 violet)
  table:put states-data "Delhi" (list 11320 orange)
  table:put states-data "Andhra Pradesh" (list 308 pink)
  table:put states-data "Telangana" (list 312 brown)
  table:put states-data "Madhya Pradesh" (list 236 lime)
  table:put states-data "Odisha" (list 270 turquoise)
  table:put states-data "Bihar" (list 1106 15)
  table:put states-data "Jharkhand" (list 414 25)
  table:put states-data "Chhattisgarh" (list 189 35)
  table:put states-data "Punjab" (list 551 45)
  table:put states-data "Haryana" (list 573 55)
  table:put states-data "Himachal Pradesh" (list 123 65)
  table:put states-data "Uttarakhand" (list 189 75)
  
  ; Add city data (name, state, x, y, population, type)
  table:put cities-data "Mumbai" (list "Maharashtra" -20 5 12442373 "metro")
  table:put cities-data "Delhi" (list "Delhi" 15 25 11007835 "metro")
  table:put cities-data "Bangalore" (list "Karnataka" -10 -15 8443675 "metro")
  table:put cities-data "Chennai" (list "Tamil Nadu" 10 -25 4681087 "metro")
  table:put cities-data "Kolkata" (list "West Bengal" 25 15 4486679 "metro")
  table:put cities-data "Hyderabad" (list "Telangana" 5 -5 6993262 "metro")
  table:put cities-data "Pune" (list "Maharashtra" -15 0 3124458 "urban")
  table:put cities-data "Ahmedabad" (list "Gujarat" -25 10 5570585 "metro")
  table:put cities-data "Jaipur" (list "Rajasthan" -5 20 3046163 "urban")
  table:put cities-data "Lucknow" (list "Uttar Pradesh" 10 15 2817105 "urban")
end

to setup-world
  ; NetLogo 6.4 compatible world setup
  resize-world -40 40 -40 40
  set-patch-size 6
end

to create-indian-states
  ; Create state regions using patch neighborhoods
  
  ; Maharashtra (Mumbai region)
  ask patches with [pxcor >= -30 and pxcor <= -10 and pycor >= -5 and pycor <= 15] [
    set state-name "Maharashtra"
    set population-density 365
    set is-urban (population-density > 400)
  ]
  
  ; Karnataka (Bangalore region)
  ask patches with [pxcor >= -20 and pxcor <= 0 and pycor >= -25 and pycor <= -5] [
    set state-name "Karnataka"
    set population-density 319
    set is-urban (population-density > 400)
  ]
  
  ; Tamil Nadu (Chennai region)
  ask patches with [pxcor >= 0 and pxcor <= 20 and pycor >= -35 and pycor <= -15] [
    set state-name "Tamil Nadu"
    set population-density 555
    set is-urban (population-density > 400)
  ]
  
  ; Kerala
  ask patches with [pxcor >= -15 and pxcor <= -5 and pycor >= -40 and pycor <= -25] [
    set state-name "Kerala"
    set population-density 860
    set is-urban (population-density > 400)
  ]
  
  ; Gujarat
  ask patches with [pxcor >= -35 and pxcor <= -15 and pycor >= 5 and pycor <= 25] [
    set state-name "Gujarat"
    set population-density 308
    set is-urban (population-density > 400)
  ]
  
  ; Rajasthan
  ask patches with [pxcor >= -15 and pxcor <= 5 and pycor >= 15 and pycor <= 35] [
    set state-name "Rajasthan"
    set population-density 200
    set is-urban (population-density > 400)
  ]
  
  ; Uttar Pradesh
  ask patches with [pxcor >= 5 and pxcor <= 25 and pycor >= 10 and pycor <= 30] [
    set state-name "Uttar Pradesh"
    set population-density 828
    set is-urban (population-density > 400)
  ]
  
  ; West Bengal (Kolkata region)
  ask patches with [pxcor >= 20 and pxcor <= 35 and pycor >= 5 and pycor <= 25] [
    set state-name "West Bengal"
    set population-density 1028
    set is-urban (population-density > 400)
  ]
  
  ; Delhi
  ask patches with [pxcor >= 10 and pxcor <= 20 and pycor >= 20 and pycor <= 30] [
    set state-name "Delhi"
    set population-density 11320
    set is-urban (population-density > 400)
  ]
  
  ; Andhra Pradesh
  ask patches with [pxcor >= 5 and pxcor <= 15 and pycor >= -15 and pycor <= 5] [
    set state-name "Andhra Pradesh"
    set population-density 308
    set is-urban (population-density > 400)
  ]
  
  ; Telangana
  ask patches with [pxcor >= -5 and pxcor <= 10 and pycor >= -10 and pycor <= 10] [
    set state-name "Telangana"
    set population-density 312
    set is-urban (population-density > 400)
  ]
  
  ; Madhya Pradesh
  ask patches with [pxcor >= -10 and pxcor <= 10 and pycor >= 0 and pycor <= 15] [
    set state-name "Madhya Pradesh"
    set population-density 236
    set is-urban (population-density > 400)
  ]
  
  ; Set default for unassigned patches
  ask patches with [state-name = 0] [
    set state-name "Other"
    set population-density 100
    set is-urban false
  ]
end

to create-indian-cities
  ; Create cities from data table
  let city-names table:keys cities-data
  
  foreach city-names [ city-name ->
    let city-info table:get cities-data city-name
    let city-state item 0 city-info
    let city-x item 1 city-info
    let city-y item 2 city-info
    let city-pop item 3 city-info
    let city-type item 4 city-info
    
    ; Create city agent
    create-cities 1 [
      setxy city-x city-y
      set city-name city-name
      set city-population city-pop
      set city-type city-type
      
      ; Set appearance based on type
      if city-type = "metro" [
        set color red
        set size 4
      ] [
        set color orange
        set size 3
      ]
      
      set shape "circle"
      set label city-name
    ]
  ]
end

to create-people-agents
  ; Create people agents
  create-people 150 [
    ; Place randomly on inhabited patches
    let inhabited-patches patches with [state-name != "Other"]
    if any? inhabited-patches [
      move-to one-of inhabited-patches
    ]
    
    ; Set properties
    set home-state [state-name] of patch-here
    set mobility-factor random-float 1.0
    
    ; Set appearance
    set color blue
    set size 1.5
    set shape "person"
  ]
end

to go
  ; Main simulation loop
  if ticks >= 500 [ stop ]
  
  ; Move people
  move-people
  
  ; Update statistics
  update-statistics
  
  tick
end

to move-people
  ask people [
    ; Simple movement towards cities
    let nearby-city min-one-of cities [distance myself]
    
    if nearby-city != nobody and mobility-factor > 0.3 [
      ; Move towards nearest city
      face nearby-city
      forward 0.2 + random-float 0.3
    ] [
      ; Random movement
      right random 60 - 30
      forward random-float 0.5
    ]
  ]
end

to update-statistics
  ; Update global statistics
  set total-population sum [population-density] of patches
  
  ; Handle mouse clicks for state selection
  if mouse-down? [
    let clicked-patch patch mouse-xcor mouse-ycor
    if clicked-patch != nobody [
      set selected-state-name [state-name] of clicked-patch
    ]
  ]
end

; Display control buttons
to show-states
  set display-mode "states"
  
  ; Color patches by state
  let state-names table:keys states-data
  foreach state-names [ state-name ->
    let state-info table:get states-data state-name
    let state-color item 1 state-info
    
    ask patches with [state-name = state-name] [
      set pcolor state-color
    ]
  ]
  
  ; Handle "Other" patches
  ask patches with [state-name = "Other"] [
    set pcolor gray
  ]
end

to show-population
  set display-mode "population"
  
  ; Color patches by population density
  let max-pop max [population-density] of patches
  let min-pop min [population-density] of patches
  
  ask patches [
    let normalized-pop (population-density - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
  ]
end

to analyze
  ; Analyze selected state
  if selected-state-name != 0 and selected-state-name != "Other" [
    let state-patches patches with [state-name = selected-state-name]
    let state-population sum [population-density] of state-patches
    let patch-count count state-patches
    let urban-count count state-patches with [is-urban]
    let people-count count people-on state-patches
    
    ; Display results
    clear-output
    output-print (word "=== ANALYSIS: " selected-state-name " ===")
    output-print (word "Total Population Density: " precision state-population 0)
    output-print (word "Number of Patches: " patch-count)
    output-print (word "Urban Patches: " urban-count)
    output-print (word "People Currently Here: " people-count)
    output-print (word "Urbanization Rate: " precision (urban-count / patch-count * 100) 1 "%")
    
    ; Highlight selected state
    ask state-patches [
      set pcolor pcolor + 2
    ]
  ] [
    output-print "Click on a state patch first, then click Analyze!"
  ]
end

to reset-view
  ; Reset to default state view
  show-states
  clear-output
  set selected-state-name 0
end

; Utility reporters
to-report get-state-info [state-name]
  if table:has-key? states-data state-name [
    report table:get states-data state-name
  ]
  report (list 0 gray)
end

to-report get-city-info [city-name]
  if table:has-key? cities-data city-name [
    report table:get cities-data city-name
  ]
  report nobody
end

to-report count-people-in-state [state-name]
  let state-patches patches with [state-name = state-name]
  report count people-on state-patches
end

to-report get-urbanization-rate [state-name]
  let state-patches patches with [state-name = state-name]
  let total-patches count state-patches
  let urban-patches count state-patches with [is-urban]
  
  if total-patches > 0 [
    report (urban-patches / total-patches) * 100
  ]
  report 0
end
