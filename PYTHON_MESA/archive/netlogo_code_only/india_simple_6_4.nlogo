; Simple India Model for NetLogo 6.4
; Basic version with minimal dependencies

extensions [table]

globals [
  selected-state
  display-mode
]

patches-own [
  state-name
  population
  is-city
]

breed [people person]

people-own [
  home-state
]

to setup
  clear-all
  
  ; Create Indian states
  create-states
  
  ; Create people
  create-people 100 [
    setxy random-xcor random-ycor
    set color blue
    set size 1
    set shape "person"
    set home-state [state-name] of patch-here
  ]
  
  ; Set initial display
  set display-mode "states"
  color-by-states
  
  reset-ticks
end

to create-states
  ; Maharashtra (red)
  ask patches with [pxcor >= -30 and pxcor <= -10 and pycor >= -5 and pycor <= 15] [
    set state-name "Maharashtra"
    set population 365
    set is-city false
  ]
  
  ; Karnataka (green)
  ask patches with [pxcor >= -20 and pxcor <= 0 and pycor >= -25 and pycor <= -5] [
    set state-name "Karnataka"
    set population 319
    set is-city false
  ]
  
  ; Tamil Nadu (blue)
  ask patches with [pxcor >= 0 and pxcor <= 20 and pycor >= -35 and pycor <= -15] [
    set state-name "Tamil Nadu"
    set population 555
    set is-city false
  ]
  
  ; Kerala (yellow)
  ask patches with [pxcor >= -15 and pxcor <= -5 and pycor >= -40 and pycor <= -25] [
    set state-name "Kerala"
    set population 860
    set is-city false
  ]
  
  ; Gujarat (cyan)
  ask patches with [pxcor >= -35 and pxcor <= -15 and pycor >= 5 and pycor <= 25] [
    set state-name "Gujarat"
    set population 308
    set is-city false
  ]
  
  ; Rajasthan (magenta)
  ask patches with [pxcor >= -15 and pxcor <= 5 and pycor >= 15 and pycor <= 35] [
    set state-name "Rajasthan"
    set population 200
    set is-city false
  ]
  
  ; Uttar Pradesh (gray)
  ask patches with [pxcor >= 5 and pxcor <= 25 and pycor >= 10 and pycor <= 30] [
    set state-name "Uttar Pradesh"
    set population 828
    set is-city false
  ]
  
  ; West Bengal (violet)
  ask patches with [pxcor >= 20 and pxcor <= 35 and pycor >= 5 and pycor <= 25] [
    set state-name "West Bengal"
    set population 1028
    set is-city false
  ]
  
  ; Delhi (orange)
  ask patches with [pxcor >= 10 and pxcor <= 20 and pycor >= 20 and pycor <= 30] [
    set state-name "Delhi"
    set population 11320
    set is-city false
  ]
  
  ; Mark major cities
  ask patch -20 5 [ set is-city true ]  ; Mumbai
  ask patch 15 25 [ set is-city true ]  ; Delhi
  ask patch -10 -15 [ set is-city true ] ; Bangalore
  ask patch 10 -25 [ set is-city true ]  ; Chennai
  ask patch 25 15 [ set is-city true ]   ; Kolkata
  
  ; Set default for unassigned patches
  ask patches with [state-name = 0] [
    set state-name "Other"
    set population 50
    set is-city false
  ]
end

to go
  ; Move people randomly
  ask people [
    right random 60 - 30
    forward random-float 0.5
  ]
  
  tick
end

to color-by-states
  set display-mode "states"
  
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
    if state-name = "Other" [ set pcolor black ]
    
    ; Mark cities
    if is-city [ set pcolor red set plabel "●" ]
  ]
end

to color-by-population
  set display-mode "population"
  
  let max-pop max [population] of patches
  let min-pop min [population] of patches
  
  ask patches [
    let normalized-pop (population - min-pop) / (max-pop - min-pop)
    set pcolor scale-color red normalized-pop 0 1
    
    ; Mark cities
    if is-city [ set plabel "●" ]
  ]
end

to analyze-state
  if mouse-down? [
    let clicked-patch patch mouse-xcor mouse-ycor
    if clicked-patch != nobody [
      set selected-state [state-name] of clicked-patch
      
      let state-patches patches with [state-name = selected-state]
      let total-pop sum [population] of state-patches
      let patch-count count state-patches
      let city-count count state-patches with [is-city]
      let people-count count people-on state-patches
      
      print (word "State: " selected-state)
      print (word "Population: " total-pop)
      print (word "Patches: " patch-count)
      print (word "Cities: " city-count)
      print (word "People: " people-count)
      print "---"
    ]
  ]
end
