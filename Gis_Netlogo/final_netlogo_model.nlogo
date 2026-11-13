;; =============================================================================
;; India GIS map with major cities and inter-city travellers
;; Author: Ronit Jaiswal
;;
;; Loads the state boundaries of India from a shapefile, colours each state,
;; places major cities at their real latitude / longitude, and simulates
;; travellers moving over land between cities, counting completed trips.
;; =============================================================================

extensions [gis]

globals [
  india-dataset
  state-names        ;; sorted list of state names found in the dataset
  trips-completed
]

breed [cities city]
breed [travellers traveller]

patches-own [
  state-name
  is-land?
]

cities-own [
  city-name
  population
  arrivals
]

travellers-own [
  destination
]

to setup
  clear-all
  gis:load-coordinate-system "map/india_boundary.prj"
  load-india-map
  create-major-cities
  create-travellers-on-land
  set trips-completed 0
  reset-ticks
end

to load-india-map
  set india-dataset gis:load-dataset "map/india_boundary.shp"
  gis:set-world-envelope (gis:envelope-of india-dataset)

  ;; Patches outside every polygon receive NaN, so test for a string name.
  gis:apply-coverage india-dataset "ST_NM" state-name
  ask patches [
    set is-land? is-string? state-name
    if not is-land? [ set state-name "" ]
  ]
  set state-names sort remove-duplicates [state-name] of patches with [is-land?]
  color-states

  gis:set-drawing-color gray - 3
  gis:draw india-dataset 1
end

to color-states
  let palette [17 27 37 47 57 67 77 87 97 107 117 127 137]
  ask patches [
    ifelse is-land?
      [ set pcolor item ((position state-name state-names) mod length palette) palette ]
      [ set pcolor 102 ]   ;; sea / outside India
  ]
end

to create-major-cities
  ;; name, latitude, longitude, metro population (millions)
  let city-data [
    ["Delhi" 28.61 77.21 32.9]
    ["Mumbai" 19.08 72.88 21.3]
    ["Kolkata" 22.57 88.36 15.3]
    ["Chennai" 13.08 80.27 11.8]
    ["Bengaluru" 12.97 77.59 13.6]
    ["Hyderabad" 17.39 78.49 10.8]
    ["Ahmedabad" 23.02 72.57 8.6]
    ["Pune" 18.52 73.86 7.2]
    ["Jaipur" 26.91 75.79 4.2]
    ["Lucknow" 26.85 80.95 3.9]
    ["Guwahati" 26.14 91.74 1.2]
    ["Thiruvananthapuram" 8.52 76.94 1.1]
  ]
  foreach city-data [ c ->
    let xy gis:project-lat-lon (item 1 c) (item 2 c)
    if not empty? xy [
      create-cities 1 [
        setxy (item 0 xy) (item 1 xy)
        set city-name item 0 c
        set population item 3 c
        set arrivals 0
        set shape "circle"
        set color red
        set size 1.5 + 1.2 * ln (1 + population)
        set label city-name
        set label-color black
      ]
    ]
  ]
end

to create-travellers-on-land
  let land patches with [is-land?]
  if not any? land [ stop ]
  create-travellers num-travellers [
    move-to one-of land
    set shape "circle"
    set size 1.2
    set color yellow
    pick-destination
  ]
end

;; Larger cities attract proportionally more travellers.
to pick-destination
  let total sum [population] of cities
  let r random-float total
  let chosen nobody
  ask cities [
    if chosen = nobody [
      set r r - population
      if r <= 0 [ set chosen self ]
    ]
  ]
  set destination ifelse-value chosen = nobody [one-of cities] [chosen]
end

to go
  if not any? cities [ stop ]
  ask travellers [ move-traveller ]
  tick
end

to move-traveller
  if destination = nobody [ pick-destination ]
  ifelse distance destination < 1.5 [
    ask destination [ set arrivals arrivals + 1 ]
    set trips-completed trips-completed + 1
    pick-destination
  ] [
    ;; Step to the land neighbour closest to the destination.
    let target min-one-of (neighbors with [is-land?]) [distance [destination] of myself]
    ifelse target != nobody
      [ move-to target ]
      [ face destination fd 1 ]
  ]
end

;; Forever button: click a state to highlight it and print its name.
to inspect-state
  if mouse-down? [
    let p patch mouse-xcor mouse-ycor
    if p != nobody and [is-land?] of p [
      let s [state-name] of p
      color-states
      ask patches with [state-name = s] [ set pcolor yellow ]
      print (word "State: " s ", patches: " count patches with [state-name = s])
      wait 0.2
    ]
  ]
end

to reset-colors
  color-states
end

to-report total-land-patches
  report count patches with [is-land?]
end

to-report busiest-city
  if not any? cities [ report "none" ]
  report [city-name] of max-one-of cities [arrivals]
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
733
533
-1
-1
3.2
1
10
1
1
1
0
0
0
1
-80
80
-80
80
1
1
1
ticks
30.0

BUTTON
10
10
100
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
10
200
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
48
100
81
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
48
200
81
reset colors
reset-colors
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
86
200
119
click a state to inspect
inspect-state
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
10
126
200
159
num-travellers
num-travellers
0
500
100
10
1
NIL
HORIZONTAL

MONITOR
10
170
200
215
Land patches
total-land-patches
0
1
11

MONITOR
10
220
200
265
States / UTs
length state-names
0
1
11

MONITOR
10
270
200
315
Cities
count cities
0
1
11

MONITOR
10
320
200
365
Trips completed
trips-completed
0
1
11

MONITOR
10
370
200
415
Busiest destination
busiest-city
0
1
11
@#$#@#$#@
## WHAT IS IT?

A map of India built from a state boundary shapefile with the NetLogo GIS extension. Each state and union territory is coloured separately, twelve major cities are placed at their real latitude and longitude, and travellers move over land between cities.

## HOW IT WORKS

- `gis:apply-coverage` copies each state's name (`ST_NM`) onto the patches it covers; patches outside India stay sea-blue.
- Cities are positioned with `gis:project-lat-lon` and sized by metro population.
- Each traveller picks a destination city with probability proportional to its population, walks over land patches towards it, and picks a new destination on arrival.

## HOW TO USE IT

Press SETUP, then GO. Turn on CLICK A STATE TO INSPECT and click on the map to highlight a state and print its name. RESET COLORS restores the state colours.

## CREDITS AND REFERENCES

Model by Ronit Jaiswal. Built with NetLogo (Wilensky, U. 1999, Center for Connected Learning and Computer-Based Modeling, Northwestern University).
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
