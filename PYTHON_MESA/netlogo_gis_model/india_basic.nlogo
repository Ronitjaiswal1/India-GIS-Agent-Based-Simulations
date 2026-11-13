globals [
  display-mode
  selected-state
]

patches-own [
  state-name
  pop-density
  is-urban
]

breed [people person]
breed [cities city]

people-own [
  home-state
]

cities-own [
  city-name
  city-pop
]

to setup
  clear-all
  create-indian-map
  create-cities
  create-people
  set display-mode "states"
  color-by-states
  reset-ticks
end

to create-indian-map
  ask patches [
    let x pxcor
    let y pycor
    
    if x < -30 and y > -10 and y < 20 [
      set state-name "Gujarat"
      set pop-density 308
    ]
    if x > -30 and x < -10 and y > -10 and y < 20 [
      set state-name "Rajasthan"
      set pop-density 200
    ]
    if x > -10 and x < 10 and y > 0 and y < 30 [
      set state-name "Uttar Pradesh"
      set pop-density 828
    ]
    if x > 10 and x < 40 and y > -10 and y < 20 [
      set state-name "West Bengal"
      set pop-density 1028
    ]
    if x > -30 and x < -10 and y > -30 and y < -10 [
      set state-name "Maharashtra"
      set pop-density 365
    ]
    if x > -20 and x < 0 and y > -40 and y < -20 [
      set state-name "Karnataka"
      set pop-density 319
    ]
    if x > -10 and x < 10 and y > -50 and y < -30 [
      set state-name "Tamil Nadu"
      set pop-density 555
    ]
    if x > -20 and x < -5 and y > -50 and y < -35 [
      set state-name "Kerala"
      set pop-density 860
    ]
    if x > 0 and x < 20 and y > -30 and y < -10 [
      set state-name "Andhra Pradesh"
      set pop-density 308
    ]
    if x > 10 and x < 30 and y > -20 and y < 0 [
      set state-name "Odisha"
      set pop-density 270
    ]
    if x > 20 and x < 40 and y > -10 and y < 10 [
      set state-name "Bihar"
      set pop-density 1106
    ]
    if x > -10 and x < 10 and y > -20 and y < 0 [
      set state-name "Madhya Pradesh"
      set pop-density 236
    ]
    if x > -10 and x < 10 and y > 20 and y < 40 [
      set state-name "Punjab"
      set pop-density 551
    ]
    if x > 5 and x < 15 and y > 15 and y < 25 [
      set state-name "Delhi"
      set pop-density 11320
    ]
    
    if state-name = 0 [
      set state-name "Other"
      set pop-density 150
    ]
    
    set is-urban (pop-density > 500)
  ]
end

to create-cities
  create-cities 1 [
    setxy -25 -15
    set city-name "Mumbai"
    set city-pop 12442373
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy 8 22
    set city-name "Delhi"
    set city-pop 11007835
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy -15 -30
    set city-name "Bangalore"
    set city-pop 8443675
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy -5 -35
    set city-name "Chennai"
    set city-pop 4681087
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy 30 10
    set city-name "Kolkata"
    set city-pop 4486679
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy 5 -20
    set city-name "Hyderabad"
    set city-pop 6809970
    set color red
    set size 3
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy -35 10
    set city-name "Ahmedabad"
    set city-pop 5570585
    set color orange
    set size 2
    set shape "circle"
  ]
  
  create-cities 1 [
    setxy -22 -10
    set city-name "Pune"
    set city-pop 3124458
    set color orange
    set size 2
    set shape "circle"
  ]
end

to create-people
  create-people 100 [
    setxy random-xcor random-ycor
    set home-state [state-name] of patch-here
    set color blue
    set size 1
    set shape "person"
  ]
end

to go
  ask people [
    let nearest-city min-one-of cities [distance myself]
    if nearest-city != nobody [
      if random-float 1 < 0.3 [
        face nearest-city
        forward 0.2
      ]
    ]
    if random-float 1 < 0.7 [
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

to color-by-states
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
    if state-name = "Delhi" [ set pcolor 15 ]
    if state-name = "Other" [ set pcolor 5 ]
  ]
end

to color-by-population
  let max-pop max [pop-density] of patches
  let min-pop min [pop-density] of patches
  
  ask patches [
    let normalized-pop (pop-density - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
  ]
end

to show-states
  set display-mode "states"
  color-by-states
end

to show-population
  set display-mode "population"
  color-by-population
end

to analyze-state
  if selected-state != 0 [
    let state-patches patches with [state-name = selected-state]
    let total-pop sum [pop-density] of state-patches
    let urban-patches count state-patches with [is-urban]
    let total-patches count state-patches
    let people-in-state count people with [home-state = selected-state]
    
    print (word "=== " selected-state " ===")
    print (word "Population Density: " total-pop)
    print (word "Urban Patches: " urban-patches "/" total-patches)
    print (word "People: " people-in-state)
  ]
end

to export-model-data
  let filename "indian_model_data.csv"
  
  file-open filename
  file-print "x,y,state,population,urban"
  
  ask patches [
    file-print (word pxcor "," pycor "," state-name "," pop-density "," is-urban)
  ]
  
  file-close
  print (word "Exported to " filename)
end
