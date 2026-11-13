extensions [gis]

globals [
  india-map
]

to setup
  clear-all
  set india-map gis:load-dataset "maps/gadm41_IND_1.shp" ; GADM level-1 (state) boundaries
  gis:set-world-envelope-ds gis:envelope-of india-map
  gis:draw india-map 0
end
