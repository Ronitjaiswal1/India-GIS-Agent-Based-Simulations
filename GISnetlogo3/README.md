# GADM Boundary Loader for NetLogo

A minimal NetLogo model that loads and draws the administrative boundaries of India. It shows the core GIS workflow in NetLogo and serves as a starting template for map-based models.

**Author:** Ronit Jaiswal

## What it does

1. Loads `maps/gadm41_IND_1.shp` (state-level boundaries from GADM 4.1).
2. Fits the NetLogo world to the dataset's envelope.
3. Draws the boundaries on the view.

## Data

`maps/` contains GADM 4.1 boundaries for India:

| File | Level |
| --- | --- |
| `gadm41_IND_1` | States and union territories |
| `gadm41_IND_2` | Districts |
| `gadm41_IND_3` | Sub-districts |

To draw a different level, change the path in the `setup` procedure, for example to `maps/gadm41_IND_2.shp`.

## Running

1. Install [NetLogo 6.4](https://ccl.northwestern.edu/netlogo/) or newer (the GIS extension is included).
2. Open `india-gis_1.nlogo` (`india-gis.nlogo` contains the same code without the interface).
3. Click `setup`.

## Author

**Ronit Jaiswal**
