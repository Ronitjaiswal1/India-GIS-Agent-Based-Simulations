;; =============================================================================
;; GADM boundary loader for India
;; Author: Ronit Jaiswal
;;
;; Minimal template for map-based NetLogo models: load an administrative
;; boundary shapefile, fit the world to it, colour each region and draw
;; its boundaries.
;; =============================================================================

extensions [gis]

globals [
  india-map
  region-names
]

patches-own [
  region-name
]

to setup
  clear-all
  let level 1
  if boundary-level = "Districts (level 2)" [ set level 2 ]
  if boundary-level = "Sub-districts (level 3)" [ set level 3 ]
  let base (word "maps/gadm41_IND_" level)

  gis:load-coordinate-system (word base ".prj")
  set india-map gis:load-dataset (word base ".shp")
  gis:set-world-envelope gis:envelope-of india-map

  ;; Colour regions by the state name (NAME_1), present at every level.
  gis:apply-coverage india-map "NAME_1" region-name
  ask patches [ if not is-string? region-name [ set region-name "" ] ]
  set region-names sort remove-duplicates [region-name] of patches with [region-name != ""]
  let palette [16 26 36 46 56 66 76 86 96 106 116 126 136]
  ask patches [
    ifelse region-name = ""
      [ set pcolor 102 ]
      [ set pcolor item ((position region-name region-names) mod length palette) palette ]
  ]

  gis:set-drawing-color white
  gis:draw india-map 0.5
  reset-ticks
end

;; Forever button: click on the map to print the state under the mouse.
to identify
  if mouse-down? [
    let p patch mouse-xcor mouse-ycor
    if p != nobody and [region-name] of p != "" [
      print [region-name] of p
      wait 0.3
    ]
  ]
end
