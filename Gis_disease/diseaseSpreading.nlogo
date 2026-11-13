;; =============================================================================
;; SEIR epidemic on the street network of Old Delhi (Subzi Mandi area)
;; Author: Ronit Jaiswal
;;
;; One tick = 10 minutes. 144 ticks = 1 day.
;; Residents commute between homes and workplaces along OpenStreetMap roads.
;; Disease states: susceptible -> exposed -> infected -> recovered (SEIR).
;; =============================================================================

extensions [gis]

globals [
  building-dataset
  road-dataset
  hospital-dataset
  hospital-patches
  peak-infected
  peak-day
  total-infections
  isolated-count
]

breed [people person]

people-own [
  status            ;; "susceptible", "exposed", "infected" or "recovered"
  home-patch
  workplace
  current-goal
  leave-hour        ;; hour of day this person leaves for work
  return-hour       ;; hour of day this person heads home
  ticks-in-state
  state-duration    ;; ticks this person will spend in the current state
  masked?
  isolated?
  stuck-ticks
]

patches-own [
  land-use          ;; OSM "building" tag of the building covering the patch
  is-road?
  is-hospital?
]

;; -----------------------------------------------------------------------------
;; SETUP
;; -----------------------------------------------------------------------------

to setup
  clear-all
  setup-map
  setup-people
  set peak-infected count people with [status = "infected"]
  set peak-day 0
  set total-infections initial-infected
  reset-ticks
end

to setup-map
  set building-dataset gis:load-dataset "map/delhi_buildings.shp"
  set road-dataset gis:load-dataset "map/delhi_roads.shp"
  set hospital-dataset gis:load-dataset "map/delhi_hospitals.shp"
  gis:set-world-envelope (gis:envelope-union-of
    (gis:envelope-of building-dataset) (gis:envelope-of hospital-dataset))

  ask patches [
    set land-use ""
    set is-road? false
    set is-hospital? false
    set pcolor 1
  ]

  ;; Land use from the OSM building tag (string; NaN where no building).
  gis:apply-coverage building-dataset "BUILDING" land-use
  ask patches [
    if not is-string? land-use [ set land-use "" ]
    set pcolor land-use-color land-use
  ]

  ;; Roads: every patch touched by a road centreline.
  ask patches gis:intersecting road-dataset [
    set is-road? true
    if land-use = "" [ set pcolor 3 ]
  ]
  gis:set-drawing-color 4
  gis:draw road-dataset 0.5

  ;; Hospital.
  ask patches gis:intersecting hospital-dataset [
    set is-hospital? true
    set pcolor red - 1
  ]
  set hospital-patches patches with [is-hospital?]
  gis:set-drawing-color red
  gis:draw hospital-dataset 1.5
end

to-report residential? [lu]
  report member? lu ["yes" "residential" "apartments" "house"]
end

to-report land-use-color [lu]
  if residential? lu [ report 33 ]
  if member? lu ["commercial" "retail" "market" "office" "construction"] [ report 23 ]
  if member? lu ["school" "college" "public" "train_station"] [ report 63 ]
  if member? lu ["mosque" "temple"] [ report 113 ]
  if lu != "" [ report 5 ]
  report 1
end

to setup-people
  let homes patches with [residential? land-use]
  let workplaces patches with [land-use != "" and not residential? land-use]
  ;; Most OSM buildings here are untagged ("yes"); if too few tagged
  ;; workplaces exist, any building patch can also be a workplace.
  if count workplaces < 20 [ set workplaces patches with [land-use != ""] ]
  if not any? homes [
    user-message "No residential building patches found in map/delhi_buildings.shp."
    stop
  ]

  create-people population [
    set home-patch one-of homes
    set workplace one-of workplaces
    move-to home-patch
    set current-goal home-patch
    set leave-hour 7 + random 3
    set return-hour 16 + random 4
    set masked? random-float 100 < mask-usage
    set isolated? false
    set stuck-ticks 0
    set shape "circle"
    set size 1.6
    set-status "susceptible"
  ]
  ask n-of (min list initial-infected population) people [ set-status "infected" ]
end

;; -----------------------------------------------------------------------------
;; MAIN LOOP
;; -----------------------------------------------------------------------------

to go
  if not any? people with [status = "exposed" or status = "infected"] [ stop ]
  if ticks >= max-days * 144 [ stop ]

  let hour floor ((ticks mod 144) / 6)
  ask people with [not isolated?] [
    if hour = leave-hour [ set current-goal workplace ]
    if hour = return-hour [ set current-goal home-patch ]
    repeat walk-speed [ move-step ]
  ]
  transmit
  progress-disease

  let n-infected count people with [status = "infected"]
  if n-infected > peak-infected [
    set peak-infected n-infected
    set peak-day ticks / 144
  ]
  set isolated-count count people with [isolated?]
  tick
end

;; Greedy walk along road patches toward the current goal. Steps off-road
;; only to enter the destination building, or to cut across when stuck in
;; a gap of the road network.
to move-step
  if patch-here = current-goal [ stop ]
  let goal current-goal
  let options neighbors with [is-road? or self = goal]
  let here-dist distance goal
  let better options with [distance goal < here-dist]
  ifelse any? better [
    move-to min-one-of better [distance goal]
    set stuck-ticks 0
  ] [
    set stuck-ticks stuck-ticks + 1
    ifelse any? options and stuck-ticks < 4
      [ move-to one-of options ]
      [ face goal fd 1 ]
  ]
end

;; Infectious, non-isolated people expose susceptible people sharing their patch.
to transmit
  ask people with [status = "infected" and not isolated?] [
    let source-factor ifelse-value masked? [0.5] [1.0]
    ask other people-here with [status = "susceptible"] [
      let p transmission-chance / 100 * source-factor
      if masked? [ set p p * 0.7 ]
      if random-float 1 < p [
        set-status "exposed"
        set total-infections total-infections + 1
      ]
    ]
  ]
end

to progress-disease
  ask people [
    set ticks-in-state ticks-in-state + 1
    if status = "exposed" and ticks-in-state >= state-duration [ set-status "infected" ]
    if status = "infected" [
      ;; Symptomatic people isolate in hospital one day after symptoms start.
      if hospital-isolation? and not isolated? and ticks-in-state >= 144
         and any? hospital-patches [
        set isolated? true
        move-to one-of hospital-patches
      ]
      if ticks-in-state >= state-duration [
        set-status "recovered"
        if isolated? [
          set isolated? false
          move-to home-patch
          set current-goal home-patch
        ]
      ]
    ]
  ]
end

to set-status [s]
  set status s
  set ticks-in-state 0
  if s = "susceptible" [ set color white      set state-duration 0 ]
  if s = "exposed"     [ set color yellow     set state-duration round (144 * incubation-days * (0.5 + random-float 1)) ]
  if s = "infected"    [ set color red        set state-duration round (144 * recovery-days * (0.5 + random-float 1)) ]
  if s = "recovered"   [ set color cyan       set state-duration 0 ]
end

;; -----------------------------------------------------------------------------
;; REPORTERS
;; -----------------------------------------------------------------------------

to-report day
  report ticks / 144
end

to-report attack-rate
  report 100 * (count people with [status != "susceptible"]) / count people
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
823
543
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-60
60
-52
52
1
1
1
ticks
30.0

BUTTON
10
10
70
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
75
10
135
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
140
10
200
43
step
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

SLIDER
10
50
200
83
population
population
50
1000
300
10
1
NIL
HORIZONTAL

SLIDER
10
88
200
121
initial-infected
initial-infected
1
30
3
1
1
NIL
HORIZONTAL

SLIDER
10
126
200
159
transmission-chance
transmission-chance
0
30
5
0.5
1
%
HORIZONTAL

SLIDER
10
164
200
197
incubation-days
incubation-days
1
10
3
0.5
1
days
HORIZONTAL

SLIDER
10
202
200
235
recovery-days
recovery-days
2
21
7
1
1
days
HORIZONTAL

SLIDER
10
240
200
273
mask-usage
mask-usage
0
100
0
5
1
%
HORIZONTAL

SLIDER
10
278
200
311
walk-speed
walk-speed
1
20
8
1
1
NIL
HORIZONTAL

SLIDER
10
316
200
349
max-days
max-days
5
120
60
5
1
days
HORIZONTAL

SWITCH
10
354
200
387
hospital-isolation?
hospital-isolation?
1
1
-1000

MONITOR
835
10
935
55
Day
day
1
1
11

MONITOR
940
10
1040
55
Susceptible
count people with [status = "susceptible"]
0
1
11

MONITOR
835
60
935
105
Exposed
count people with [status = "exposed"]
0
1
11

MONITOR
940
60
1040
105
Infected
count people with [status = "infected"]
0
1
11

MONITOR
835
110
935
155
Recovered
count people with [status = "recovered"]
0
1
11

MONITOR
940
110
1040
155
In hospital
isolated-count
0
1
11

MONITOR
835
160
935
205
Peak infected
peak-infected
0
1
11

MONITOR
940
160
1040
205
Peak day
peak-day
1
1
11

MONITOR
835
210
935
255
Attack rate %
attack-rate
1
1
11

MONITOR
940
210
1040
255
Total infections
total-infections
0
1
11

PLOT
835
265
1185
543
SEIR epidemic curve
days
people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -7500403 true "" "plotxy day count people with [status = \"susceptible\"]"
"exposed" 1.0 0 -1184463 true "" "plotxy day count people with [status = \"exposed\"]"
"infected" 1.0 0 -2674135 true "" "plotxy day count people with [status = \"infected\"]"
"recovered" 1.0 0 -11221820 true "" "plotxy day count people with [status = \"recovered\"]"
@#$#@#$#@
## WHAT IS IT?

An SEIR (susceptible, exposed, infected, recovered) epidemic model set in the Subzi Mandi area of Old Delhi. Building footprints and the street network come from OpenStreetMap. Residents live in residential buildings, commute along real streets to workplaces, schools and markets each day, and return home in the evening. Infection spreads through close contact on the same patch: on the street, at work and inside shared homes.

## HOW IT WORKS

- One tick is 10 minutes; 144 ticks make one day.
- Each person has a home, a workplace, a departure hour (07:00 to 09:00) and a return hour (16:00 to 19:00).
- People walk along road patches towards their current goal using a greedy route, stepping off-road only to enter their destination or to cross gaps in the road network.
- An infected person exposes each susceptible person on the same patch with probability TRANSMISSION-CHANCE per tick. Masks halve the chance of passing on infection and reduce the chance of catching it by 30 percent.
- Exposed people become infectious after an incubation period, and infected people recover (with immunity) after a recovery period. Both periods vary randomly between 50 and 150 percent of the slider value.
- With HOSPITAL-ISOLATION? on, infected people are isolated in the Northern Railway Hospital one day after symptoms start and stop transmitting.

## HOW TO USE IT

Set the sliders, press SETUP to load the map and residents, then GO. The simulation stops when no exposed or infected people remain, or after MAX-DAYS.

## THINGS TO NOTICE

- Household clusters: several people share each home patch, so infection jumps between commuters and their families overnight.
- The epidemic curve peaks and declines as susceptible people run out.

## THINGS TO TRY

- Compare the peak and the attack rate with HOSPITAL-ISOLATION? off and on.
- Increase MASK-USAGE in steps of 25 percent and watch the peak flatten and shift later.
- Change POPULATION to see how density changes transmission.

## EXTENDING THE MODEL

- Age groups with different severity, hospital capacity limits and deaths.
- Vaccination campaigns and lockdowns triggered by case counts.
- Shortest-path routing on the road graph instead of greedy movement.

## CREDITS AND REFERENCES

Model by Ronit Jaiswal.

Map data (buildings, roads, hospital) from OpenStreetMap contributors, available under the Open Database License (ODbL).

Wilensky, U. (1999). NetLogo. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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
