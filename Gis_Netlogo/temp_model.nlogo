; This is a temporary script to create the model properly
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
  load-india-map
  setup-display
  create-sample-agents
  reset-ticks
end

to load-india-map
  if file-exists? "data/india_boundary.shp" [
    set india-dataset gis:load-dataset "data/india_boundary.shp"
    gis:set-world-envelope (gis:envelope-of india-dataset)
    gis:apply-coverage india-dataset "NAME" state-name
    ask patches [
      set is-land? (state-name != 0 and state-name != "")
      if is-land? [ set pcolor green + 2 ]
    ]
    gis:set-drawing-color black
    gis:draw india-dataset 2
  ]
  
  if file-exists? "data/india_states.shp" [
    set states-dataset gis:load-dataset "data/india_states.shp"
    gis:set-drawing-color white
    gis:draw states-dataset 1
  ]
  
  if not file-exists? "data/india_boundary.shp" [
    create-basic-india-outline
  ]
end

to create-basic-india-outline
  print "Creating basic India outline..."
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
  create-cities 1 [ set city-name "New Delhi" set population 30000000 setxy 0 8 set color red set size 3 set shape "circle" ]
  create-cities 1 [ set city-name "Mumbai" set population 20000000 setxy -8 2 set color red set size 3 set shape "circle" ]
  create-cities 1 [ set city-name "Kolkata" set population 14000000 setxy 8 5 set color red set size 3 set shape "circle" ]
  create-cities 1 [ set city-name "Chennai" set population 10000000 setxy 5 -10 set color red set size 3 set shape "circle" ]
  create-cities 1 [ set city-name "Bangalore" set population 12000000 setxy 2 -8 set color red set size 3 set shape "circle" ]
end

to setup-display
  ask patches [ if not is-land? [ set pcolor blue + 3 ] ]
  ask cities [ set label city-name set label-color black ]
end

to create-sample-agents
  create-agents 50 [
    let land-patches patches with [is-land?]
    if any? land-patches [ move-to one-of land-patches ]
    set color yellow
    set size 0.8
    set shape "circle"
  ]
end

to go
  ask agents [ move-agent ]
  tick
end

to move-agent
  let target-patch one-of neighbors with [is-land?]
  if target-patch != nobody [ move-to target-patch ]
end

to reset-colors
  ask patches [
    if is-land? [ set pcolor green + 2 ] 
    [ set pcolor blue + 3 ]
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
