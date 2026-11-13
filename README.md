# India GIS Agent-Based Simulations

A collection of agent-based models built on real geographic data for India, developed during my internship at the Indian Institute of Space Science and Technology (IIST). The work combines GIS shapefiles with NetLogo and Python (Mesa) to simulate how people, cities, economies and diseases behave across real map geography, from the national scale down to individual buildings and roads in Delhi.

**Author:** Ronit Jaiswal

---

## Projects at a glance

| Folder | What it is | Scale | Tools |
| --- | --- | --- | --- |
| [`Gis_Netlogo`](Gis_Netlogo/) | Advanced India simulation: cities, migration, economy, environment, transport and policy | National | NetLogo 6.4, GIS extension |
| [`Gis_disease`](Gis_disease/) | Disease spread among commuters moving along real Delhi roads between homes and workplaces | City (Delhi) | NetLogo, GIS extension, OpenStreetMap data |
| [`PYTHON_MESA`](PYTHON_MESA/) | Python re-implementation of the India model, GIS data processing pipeline, and NetLogo control from Python | National | Python, Mesa, pandas, Matplotlib, pyNetLogo |
| [`GISnetlogo3`](GISnetlogo3/) | Minimal reference model for loading and drawing GADM administrative boundaries in NetLogo | National | NetLogo, GIS extension |

---

## 1. Gis_Netlogo: Advanced Indian GIS Simulation

A NetLogo model of India that loads state and national boundary shapefiles and overlays a multi-agent socio-economic simulation on top of them.

**Agents (breeds):** cities, people, companies, highways, railways, airports, government offices.

**What it simulates**

- **Urban systems:** major Indian cities with population, GDP per capita, growth rate, infrastructure, pollution and employment attributes.
- **Population dynamics:** urban, rural, migrant and tourist agents with age, income, education, health and job sector; rural-to-urban and inter-city migration driven by city attractiveness.
- **Economy:** industrial, agricultural and service sectors; companies with revenue, employees and production capacity; city and national GDP tracking.
- **Environment:** temperature, rainfall, monsoon cycles, pollution from industry and traffic, water availability, forest cover and a climate change factor.
- **Transport:** highway, railway and airport networks with capacity and flow.
- **Policy and events:** infrastructure investment, social programmes, pollution regulation, festivals, natural disasters and economic shocks.

**Display modes:** economic, environmental, population, transportation and development views, each recolouring the map by the relevant patch indicator.

**Model files**

| File | Description |
| --- | --- |
| `indian_map_model.nlogo` | Full advanced model (NetLogo 6.4 XML format) |
| `final_netlogo_model.nlogo` | Stable version: map loading, major cities and moving agents |
| `indian_map_simple.nlogo` | Lightweight version for quick testing |
| `run_model.bat` | Opens the model in NetLogo on Windows |
| `download_data.ps1`, `download_data_alternative.bat` | Scripts to download boundary data |

**Data:** `map/` (India boundary and state layers), `indianDistrictShapefile/` (district boundaries), `data/` (Natural Earth countries and states), `delhi_map/` (Delhi buildings, roads and hospitals).

More detail: [`Gis_Netlogo/README.md`](Gis_Netlogo/README.md) and [`Gis_Netlogo/README_ADVANCED.md`](Gis_Netlogo/README_ADVANCED.md).

---

## 2. Gis_disease: Disease Spread on the Delhi Road Network

An epidemic model in which 200 residents commute daily between home and work over the actual street network of a part of Delhi.

**How it works**

1. Building footprints, roads and hospitals are loaded from shapefiles. Each patch takes the land-use type of the building beneath it (house, apartment, commercial, office, hospital and others) and is coloured accordingly.
2. Patches that intersect the road layer are marked as roads.
3. Each person is given a home (house or apartment) and a workplace (commercial or office).
4. Each tick is one hour. At 08:00 people head to work and at 17:00 they head home, moving along road patches toward their goal.
5. One person starts infected. Healthy people sharing a patch with an infected person become infected with a 25 percent probability per tick.
6. A live plot tracks healthy, infected and recovered counts.

**Run:** open `Gis_disease/diseaseSpreading.nlogo` in NetLogo, click `setup`, then `go`.

---

## 3. PYTHON_MESA: Python and Mesa Implementation

The same India simulation rebuilt in Python, plus tooling that connects Python and NetLogo.

| File | Description |
| --- | --- |
| `india_gis_model.py` | Mesa-based model with `Person` and `City` agents, state regions, data collection and Matplotlib visualisation |
| `india_final_working.py`, `india_working_model.py`, `india_gis_simple.py` | Dependency-light versions using NumPy, pandas and Matplotlib only |
| `netlogo_in_vscode.ipynb` | Notebook that drives NetLogo models from Python through pyNetLogo |
| `netlogo_gis_model/india_gis_processor.py` | Downloads Natural Earth data, extracts Indian states and converts them to NetLogo coordinates |
| `netlogo_gis_model/simple_data_generator.py` | Generates state, city, economic and migration CSV data and NetLogo include files |
| `netlogo_gis_model/*.nlogo` | NetLogo models that read the generated CSV data |
| `tests/satyam.py` | Prototype air-quality (AQI) heatmap of Indian cities using Folium |

**Run:**

```bash
cd PYTHON_MESA
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
python india_gis_model.py
```

---

## 4. GISnetlogo3: GADM Boundary Loader

A minimal model showing the core GIS workflow in NetLogo: load a shapefile, fit the world envelope to it, and draw it. It uses GADM 4.1 administrative boundaries for India at state, district and sub-district level (`maps/gadm41_IND_1` to `gadm41_IND_3`). It is a useful starting template for any new map-based model.

**Run:** open `GISnetlogo3/india-gis_1.nlogo` in NetLogo and click `setup`.

---

## Requirements

- [NetLogo 6.4](https://ccl.northwestern.edu/netlogo/) or newer (the GIS extension ships with NetLogo)
- Python 3.10 or newer for the `PYTHON_MESA` project

## Repository structure

```
.
|-- Gis_Netlogo/          Advanced national-scale NetLogo model and data
|-- Gis_disease/          Delhi disease-spread model and OSM-derived layers
|-- PYTHON_MESA/          Python / Mesa models, data tools and notebook
|-- GISnetlogo3/          Minimal GADM boundary loader
`-- README.md
```

## Key concepts demonstrated

- Agent-based modelling of social, economic and epidemiological systems
- Loading, projecting and rasterising vector GIS data (shapefiles) inside a simulation
- Mapping polygon attributes onto simulation patches (`gis:apply-coverage`)
- Network-constrained agent movement along real road geometry
- Porting a model between NetLogo and Python (Mesa) and controlling NetLogo from Python

## Data sources and credits

- Natural Earth: public domain country and state boundaries
- GADM 4.1: administrative boundaries of India (free for academic and non-commercial use)
- OpenStreetMap contributors: Delhi buildings, roads and hospitals (ODbL)
- NetLogo: Wilensky, U. (1999). NetLogo. Center for Connected Learning and Computer-Based Modeling, Northwestern University.
- Mesa: agent-based modelling framework for Python

## Author

**Ronit Jaiswal**
GitHub: [Ronitjaiswal1](https://github.com/Ronitjaiswal1)

## License

Code is released under the MIT License (see `LICENSE`). Third-party map data remains under the terms of its original source listed above.
