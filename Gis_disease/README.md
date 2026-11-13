# Disease Spread on the Delhi Road Network

A NetLogo agent-based model of infection spreading among commuters who travel between home and work along the real streets of a part of Delhi.

**Author:** Ronit Jaiswal

## Data

The `map/` folder holds three layers derived from OpenStreetMap:

| Layer | Use in the model |
| --- | --- |
| `delhi_buildings.shp` | Land use of each patch (house, apartment, commercial, office, hospital and others) |
| `delhi_roads.shp` | Marks road patches that agents travel on |
| `delhi_hospitals.shp` | Drawn on the map for reference |

## How it works

1. Building land use is applied to patches and coloured by type; road patches are flagged.
2. 200 people are created, each with a home (house or apartment) and a workplace (commercial or office).
3. One tick is one hour. At 08:00 people travel to work and at 17:00 they travel home, moving along road patches toward their goal.
4. One person starts infected. A healthy person on the same patch as an infected person becomes infected with a 25 percent chance per tick.
5. Agent colour shows status: green for healthy, red for infected, blue for recovered. A plot tracks the counts over time.

## Running

1. Install [NetLogo 6.4](https://ccl.northwestern.edu/netlogo/) or newer.
2. Open `diseaseSpreading.nlogo`.
3. Click `setup` to load the map and people, then `go` to run.

## Author

**Ronit Jaiswal**
