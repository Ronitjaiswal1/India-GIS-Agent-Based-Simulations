; Ultra Simple India Model for NetLogo 6.4
; Most basic version guaranteed to work

globals [
  selected-state-name
]

patches-own [
  state-name
  population
]

breed [people person]

to setup
  clear-all
  
  ; Create 5 main states
  ask patches with [pxcor >= -20 and pxcor <= 0 and pycor >= -10 and pycor <= 10] [
    set state-name "Maharashtra"
    set population 365
    set pcolor red
  ]
  
  ask patches with [pxcor >= 0 and pxcor <= 20 and pycor >= -10 and pycor <= 10] [
    set state-name "Karnataka"
    set population 319
    set pcolor green
  ]
  
  ask patches with [pxcor >= -10 and pxcor <= 10 and pycor >= 10 and pycor <= 30] [
    set state-name "Delhi"
    set population 11320
    set pcolor orange
  ]
  
  ask patches with [pxcor >= -10 and pxcor <= 10 and pycor >= -30 and pycor <= -10] [
    set state-name "Tamil Nadu"
    set population 555
    set pcolor blue
  ]
  
  ask patches with [pxcor >= 10 and pxcor <= 30 and pycor >= -10 and pycor <= 10] [
    set state-name "West Bengal"
    set population 1028
    set pcolor violet
  ]
  
  ; Set default for other patches
  ask patches with [state-name = 0] [
    set state-name "Other"
    set population 100
    set pcolor gray
  ]
  
  ; Create people
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
    right random 360
    forward random-float 0.5
  ]
  tick
end

to show-states
  ask patches [
    if state-name = "Maharashtra" [ set pcolor red ]
    if state-name = "Karnataka" [ set pcolor green ]
    if state-name = "Delhi" [ set pcolor orange ]
    if state-name = "Tamil Nadu" [ set pcolor blue ]
    if state-name = "West Bengal" [ set pcolor violet ]
    if state-name = "Other" [ set pcolor gray ]
  ]
end

to show-population
  let max-pop max [population] of patches
  let min-pop min [population] of patches
  
  ask patches [
    let norm-pop (population - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red norm-pop 0 1
  ]
end

to analyze
  if mouse-down? [
    let target patch mouse-xcor mouse-ycor
    if target != nobody [
      set selected-state-name [state-name] of target
      let state-patches patches with [state-name = selected-state-name]
      let total-pop sum [population] of state-patches
      let patch-count count state-patches
      
      print (word "State: " selected-state-name)
      print (word "Population: " total-pop)
      print (word "Patches: " patch-count)
      print "---"
    ]
  ]
end
