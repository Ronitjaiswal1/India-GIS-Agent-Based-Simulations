; Basic Indian States Model
; Simple NetLogo model showing Indian states

globals [
  selected-state
]

patches-own [
  state-name
  population
]

breed [people person]

to setup
  clear-all
  
  ; Create Indian states
  ask patches [
    let x pxcor
    let y pycor
    
    ; Maharashtra (Mumbai area)
    if x > -30 and x < -10 and y > -20 and y < 0 [
      set state-name "Maharashtra"
      set population 365
      set pcolor red
    ]
    
    ; Karnataka (Bangalore area)
    if x > -20 and x < 0 and y > -40 and y < -20 [
      set state-name "Karnataka"
      set population 319
      set pcolor green
    ]
    
    ; Tamil Nadu (Chennai area)
    if x > -10 and x < 10 and y > -50 and y < -30 [
      set state-name "Tamil Nadu"
      set population 555
      set pcolor blue
    ]
    
    ; Kerala
    if x > -20 and x < -5 and y > -50 and y < -35 [
      set state-name "Kerala"
      set population 860
      set pcolor yellow
    ]
    
    ; Gujarat
    if x > -40 and x < -25 and y > 0 and y < 20 [
      set state-name "Gujarat"
      set population 308
      set pcolor cyan
    ]
    
    ; Rajasthan
    if x > -25 and x < -5 and y > 10 and y < 30 [
      set state-name "Rajasthan"
      set population 200
      set pcolor magenta
    ]
    
    ; Uttar Pradesh
    if x > -5 and x < 15 and y > 5 and y < 25 [
      set state-name "Uttar Pradesh"
      set population 828
      set pcolor gray
    ]
    
    ; West Bengal (Kolkata area)
    if x > 15 and x < 35 and y > -5 and y < 15 [
      set state-name "West Bengal"
      set population 1028
      set pcolor violet
    ]
    
    ; Delhi
    if x > 5 and x < 15 and y > 15 and y < 25 [
      set state-name "Delhi"
      set population 11320
      set pcolor orange
    ]
    
    ; Default for other areas
    if state-name = 0 [
      set state-name "Other"
      set population 100
      set pcolor gray - 2
    ]
  ]
  
  ; Create major cities
  ask patch -25 -10 [
    sprout 1 [
      set breed people
      set color red
      set size 3
      set shape "circle"
    ]
  ]
  
  ask patch 10 20 [
    sprout 1 [
      set breed people
      set color red
      set size 3
      set shape "circle"
    ]
  ]
  
  ask patch -10 -30 [
    sprout 1 [
      set breed people
      set color red
      set size 3
      set shape "circle"
    ]
  ]
  
  ask patch 0 -40 [
    sprout 1 [
      set breed people
      set color red
      set size 3
      set shape "circle"
    ]
  ]
  
  ask patch 25 5 [
    sprout 1 [
      set breed people
      set color red
      set size 3
      set shape "circle"
    ]
  ]
  
  ; Create moving people
  create-people 50 [
    setxy random-xcor random-ycor
    set color blue
    set size 1
    set shape "person"
  ]
  
  reset-ticks
end

to go
  ask people [
    if shape = "person" [
      right random 360
      forward 0.5
    ]
  ]
  
  if mouse-down? [
    let clicked-patch patch mouse-xcor mouse-ycor
    if clicked-patch != nobody [
      set selected-state [state-name] of clicked-patch
    ]
  ]
  
  tick
end

to show-population
  let max-pop max [population] of patches
  let min-pop min [population] of patches
  
  ask patches [
    let normalized (population - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized 0 1
  ]
end

to show-states
  ask patches [
    if state-name = "Maharashtra" [ set pcolor red ]
    if state-name = "Karnataka" [ set pcolor green ]
    if state-name = "Tamil Nadu" [ set pcolor blue ]
    if state-name = "Kerala" [ set pcolor yellow ]
    if state-name = "Gujarat" [ set pcolor cyan ]
    if state-name = "Rajasthan" [ set pcolor magenta ]
    if state-name = "Uttar Pradesh" [ set pcolor gray ]
    if state-name = "West Bengal" [ set pcolor violet ]
    if state-name = "Delhi" [ set pcolor orange ]
    if state-name = "Other" [ set pcolor gray - 2 ]
  ]
end

to analyze
  if selected-state != 0 [
    let state-patches patches with [state-name = selected-state]
    let total-pop sum [population] of state-patches
    let patch-count count state-patches
    
    print (word "State: " selected-state)
    print (word "Population: " total-pop)
    print (word "Patches: " patch-count)
  ]
end
