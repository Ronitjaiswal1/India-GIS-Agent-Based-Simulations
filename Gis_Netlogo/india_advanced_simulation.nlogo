extensions [gis]

globals [
  india-dataset
  states-dataset
  india-envelope
  total-gdp
  total-pollution
  total-population
  monsoon-intensity
  economic-growth-rate
  climate-change-factor
  display-mode
]

breed [cities city]
breed [people person]
breed [companies company]
breed [highways highway]
breed [railways railway]
breed [airports airport]
directed-link-breed [highway-links highway-link]
directed-link-breed [railway-links railway-link]
breed [government-offices government-office]

patches-own [
  state-name
  is-land?
  patch-gdp
  industrial-level
  agricultural-level
  service-level
  pollution-level
  water-availability
  forest-cover
  road-density
  power-grid-capacity
  internet-coverage
  patch-education
  healthcare-access
  unemployment-rate
  population-density
  temperature
  rainfall
  air-quality
  patch-infrastructure
]

cities-own [
  city-name
  population
  city-type
  gdp-per-capita
  growth-rate
  infrastructure-score
  pollution-index
  employment-rate
  migration-attractiveness
  economic-output
  tax-revenue
]

people-own [
  agent-type
  age
  income
  education-level
  health-status
  job-sector
  mobility-level
  migration-target
  tourist-destinations
  current-destination
]

companies-own [
  company-type
  company-size
  revenue
  employees
  production-capacity
  market-share
]

highways-own [
  highway-capacity
  traffic-flow
  maintenance-level
]

railways-own [
  railway-capacity
  passenger-flow
  freight-flow
]

airports-own [
  airport-capacity
  international?
  passenger-volume
]

government-offices-own [
  office-type
  budget
  efficiency
]

; =============================================================================
; ADVANCED INDIAN GIS SIMULATION MODEL
; Features: Urban dynamics, migration, transportation, economy, environment
; =============================================================================

to setup
  clear-all
  
  ; Initialize global variables
  set total-gdp 0
  set total-pollution 0
  set total-population 0
  set monsoon-intensity 0
  set economic-growth-rate 0.03
  set climate-change-factor 0
  
  ; Load the Indian map data
  load-india-map
  
  ; Initialize patches with various attributes
  initialize-patches
  
  ; Create cities with realistic data
  create-major-cities
  
  ; Create transportation networks
  create-transportation-network
  
  ; Create different types of agents
  create-population-agents
  create-businesses
  create-government-agents
  
  ; Set up the display
  setup-display
  
  ; Initialize economic and environmental systems
  initialize-economy
  initialize-environment
  
  reset-ticks
end

to load-india-map
  ; Load the Indian state boundary shapefile (WGS84).
  ifelse file-exists? "map/india_boundary.shp" [
    gis:load-coordinate-system "map/india_boundary.prj"
    set india-dataset gis:load-dataset "map/india_boundary.shp"
    set india-envelope gis:envelope-of india-dataset
    gis:set-world-envelope india-envelope
    gis:apply-coverage india-dataset "ST_NM" state-name

    ; Patches outside every polygon receive NaN, so test for a string name.
    ask patches [
      set is-land? is-string? state-name
      ifelse is-land?
        [ set pcolor green + 2 ]
        [ set state-name "" set pcolor blue + 3 ]
    ]

    gis:set-drawing-color gray - 2
    gis:draw india-dataset 1
  ] [
    create-basic-india-outline
  ]
end

; Convert latitude / longitude to a NetLogo location. Falls back to the
; given patch coordinates when no shapefile (and so no projection) is loaded.
to-report lat-lon-xy [lat lon fallback-x fallback-y]
  if india-dataset != 0 [
    let xy gis:project-lat-lon lat lon
    if not empty? xy [ report xy ]
  ]
  report list fallback-x fallback-y
end

to create-basic-india-outline
  print "Shapefile not found. Creating basic India outline..."
  
  ; Initialize all patches first
  ask patches [
    set is-land? false
    set state-name ""
    set pcolor blue + 3
  ]
  
  ; Create a rough outline of India using patches
  ask patches [
    let x pxcor
    let y pycor
    
    ; Very basic India-like shape
    if (x >= -15 and x <= 15 and y >= -20 and y <= 20) [
      if (y > -15 and y < 15) [
        ; Main peninsular part
        if (x >= -10 and x <= 10) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
      
      ; Northern part (broader)
      if (y >= 0 and y <= 15) [
        if (x >= -12 and x <= 12) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
      
      ; Southern tip (narrower)
      if (y >= -20 and y <= -10) [
        if (x >= -5 and x <= 5) [
          set pcolor green + 2
          set is-land? true
          set state-name "India"
        ]
      ]
    ]
  ]
end

to initialize-patches
  ask patches [
    if is-land? [
      ; Economic attributes
      set patch-gdp random-float 1000 + 100
      set industrial-level random-float 0.5
      set agricultural-level random-float 0.8
      set service-level random-float 0.6
      
      ; Environmental attributes  
      set pollution-level random-float 0.3
      set water-availability random-float 1.0
      set forest-cover random-float 0.4
      
      ; Infrastructure
      set road-density random-float 0.7
      set power-grid-capacity random-float 0.8
      set internet-coverage random-float 0.6
      
      ; Social indicators
      set patch-education random-float 0.7
      set healthcare-access random-float 0.6
      set unemployment-rate random-float 0.15
      
      ; Population density (people per patch)
      set population-density random-exponential 500
      set patch-infrastructure (road-density + power-grid-capacity + internet-coverage) / 3
      
      ; Set initial color based on development level
      update-patch-color
    ]
  ]
end

to create-major-cities
  ; Create major Indian cities with realistic attributes
  ; name, population, fallback x, fallback y, type, GDP per capita, latitude, longitude
  let city-data [
    ["New Delhi" 32000000 0 8 "capital" 85000 28.61 77.21]
    ["Mumbai" 25000000 -8 2 "financial" 78000 19.08 72.88]
    ["Kolkata" 15000000 8 5 "industrial" 45000 22.57 88.36]
    ["Chennai" 12000000 5 -10 "automotive" 52000 13.08 80.27]
    ["Bangalore" 14000000 2 -8 "tech" 68000 12.97 77.59]
    ["Hyderabad" 10000000 3 -5 "pharma" 48000 17.39 78.49]
    ["Ahmedabad" 8000000 -12 8 "textile" 42000 23.02 72.57]
    ["Pune" 7000000 -6 1 "it" 55000 18.52 73.86]
    ["Surat" 6000000 -10 5 "diamond" 38000 21.17 72.83]
    ["Jaipur" 4000000 -5 12 "tourism" 35000 26.91 75.79]
  ]

  foreach city-data [ city-info ->
    create-cities 1 [
      set city-name item 0 city-info
      set population item 1 city-info
      let xy lat-lon-xy (item 6 city-info) (item 7 city-info) (item 2 city-info) (item 3 city-info)
      setxy item 0 xy item 1 xy
      set city-type item 4 city-info
      set gdp-per-capita item 5 city-info
      
      ; City attributes
      set growth-rate 0.02 + random-float 0.03
      set infrastructure-score 0.5 + random-float 0.4
      set pollution-index random-float 0.8
      set employment-rate 0.7 + random-float 0.2
      set migration-attractiveness 0.5 + random-float 0.4
      
      ; Visual properties
      set color red
      set size 1.5 + 0.8 * ln (max list 1 (population / 1000000))
      set shape "circle"
      set label city-name
      set label-color black
      
      ; Create city influence on surrounding patches
      ask patches in-radius (size + 2) [
        if is-land? [
          set patch-gdp patch-gdp + 200
          set industrial-level industrial-level + 0.1
          set service-level service-level + 0.2
          set road-density road-density + 0.2
          set internet-coverage internet-coverage + 0.3
          set pollution-level pollution-level + 0.1
        ]
      ]
    ]
  ]
end

to create-transportation-network
  ; Create highways connecting major cities
  create-highways 20 [
    set color gray
    set size 0.5
    set shape "line"
    
    ; Place on major routes
    move-to one-of cities
    set highway-capacity 1000 + random 2000
    set traffic-flow 0
    set maintenance-level 0.7 + random-float 0.3
    
    ; Create highway links between cities
    create-highway-links-to n-of (1 + random 3) other cities [
      set color gray - 1
      set thickness 0.1
    ]
  ]
  
  ; Create railways
  create-railways 15 [
    set color brown
    set size 0.4
    set shape "line"
    move-to one-of cities
    set railway-capacity 500 + random 1000
    set passenger-flow 0
    set freight-flow 0
    
    create-railway-links-to n-of (1 + random 2) other cities [
      set color brown - 1
      set thickness 0.05
    ]
  ]
  
  ; Create airports
  create-airports 8 [
    set color sky
    set size 1.5
    set shape "airplane"
    move-to one-of cities with [population > 5000000]
    set airport-capacity 100 + random 200
    set international? (random-float 1 < 0.4)
    set passenger-volume 0
  ]
end

to create-population-agents
  ; Create different types of population agents
  create-urban-population (count cities * 50)
  create-rural-population 200
  create-migrants 100
  create-tourists 50
end

to create-urban-population [num]
  create-people num [
    set agent-type "urban"
    move-to one-of cities
    set age 18 + random 60
    set income 15000 + random 50000
    set education-level 0.4 + random-float 0.5
    set health-status 0.6 + random-float 0.3
    set job-sector one-of ["service" "manufacturing" "tech" "government"]
    set mobility-level 0.5 + random-float 0.4
    
    set color yellow
    set size 0.6
    set shape "person"
    
    ; Set movement pattern based on job
    if job-sector = "tech" [
      set color cyan
      set income income + 20000
    ]
    if job-sector = "manufacturing" [
      set color orange
    ]
  ]
end

to create-rural-population [num]
  create-people num [
    set agent-type "rural"
    move-to one-of patches with [is-land? and agricultural-level > 0.5]
    set age 25 + random 50
    set income 5000 + random 15000
    set education-level 0.2 + random-float 0.4
    set health-status 0.5 + random-float 0.3
    set job-sector one-of ["agriculture" "fishing" "forestry" "mining"]
    set mobility-level 0.2 + random-float 0.3
    
    set color green
    set size 0.5
    set shape "person"
  ]
end

to create-migrants [num]
  create-people num [
    set agent-type "migrant"
    move-to one-of patches with [is-land?]
    set age 20 + random 40
    set income 3000 + random 12000
    set education-level 0.3 + random-float 0.4
    set health-status 0.4 + random-float 0.3
    set job-sector one-of ["construction" "domestic" "street-vendor" "transport"]
    set mobility-level 0.8 + random-float 0.2
    
    set color magenta
    set size 0.4
    set shape "person"
    
    ; Set migration goal (move toward cities)
    set migration-target one-of cities with [migration-attractiveness > 0.6]
  ]
end

to create-tourists [num]
  create-people num [
    set agent-type "tourist"
    move-to one-of cities with [city-type = "tourism"]
    set age 25 + random 40
    set income 30000 + random 70000
    set mobility-level 0.9 + random-float 0.1
    
    set color pink
    set size 0.5
    set shape "person"
    
    set tourist-destinations n-of (2 + random 4) cities
    set current-destination one-of tourist-destinations
  ]
end

to create-businesses
  ; Create different types of businesses
  create-companies 50 [
    set company-type one-of ["manufacturing" "services" "agriculture" "tech" "retail"]
    set company-size 10 + random 1000
    set revenue 100000 + random 10000000
    set employees company-size
    
    ; Locate based on company type
    if company-type = "tech" [
      move-to one-of cities with [city-type = "tech"]
      set color blue
    ]
    if company-type = "manufacturing" [
      move-to one-of patches with [industrial-level > 0.4]
      set color gray
    ]
    if company-type = "agriculture" [
      move-to one-of patches with [agricultural-level > 0.6]
      set color green
    ]
    if company-type = "services" [
      move-to one-of cities with [population > 8000000]
      set color cyan
    ]
    if company-type = "retail" [
      move-to one-of cities
      set color orange
    ]
    
    set size 0.8
    set shape "house"
  ]
end

to create-government-agents
  ; Create government offices and services
  create-government-offices 28 [ ; One per state
    move-to one-of cities
    set office-type one-of ["state" "district" "municipal" "central"]
    set budget 1000000 + random 50000000
    set efficiency 0.4 + random-float 0.4
    
    set color red
    set size 1.2
    set shape "house"
  ]
end

to setup-display
  ; Set up the display with different view modes
  display-economic-view
end

to initialize-economy
  ; Set up economic systems
  ask cities [
    set economic-output population * gdp-per-capita
    set tax-revenue economic-output * 0.15
  ]
  
  ask companies [
    set production-capacity revenue / 100000
    set market-share random-float 0.1
  ]
  
  ; Calculate total GDP
  set total-gdp sum [economic-output] of cities + sum [revenue] of companies
end

to initialize-environment
  ; Set up environmental systems
  ask patches [
    if is-land? [
      set temperature 20 + random 15 ; Celsius
      set rainfall 500 + random 1500 ; mm per year
      set air-quality 0.3 + random-float 0.5
    ]
  ]
  
  ; Set initial monsoon pattern
  set monsoon-intensity 0.5 + random-float 0.3
end

; =============================================================================
; MAIN SIMULATION LOOP
; =============================================================================

to go
  ; Update environmental factors
  update-environment
  
  ; Update economic activities
  update-economy
  
  ; Population dynamics
  update-population
  
  ; Transportation and logistics
  update-transportation
  
  ; Migration patterns
  handle-migration
  
  ; Government policies
  implement-policies
  
  ; Update displays
  update-displays
  
  ; Seasonal events
  handle-seasonal-events
  
  ; Random events
  handle-random-events
  
  tick
end

to update-environment
  ; Climate change effects
  set climate-change-factor climate-change-factor + 0.001
  
  ; Monsoon cycle (yearly pattern)
  set monsoon-intensity 0.3 + 0.7 * sin(ticks * 360 / 365)
  
  ; Update patch environment
  ask patches [
    if is-land? [
      ; Pollution spreads from industrial areas
      let nearby-pollution sum [pollution-level] of neighbors
      set pollution-level (pollution-level + nearby-pollution * 0.01)
      
      ; Rain affects pollution and agriculture
      if monsoon-intensity > 0.6 [
        set pollution-level pollution-level * 0.95
        set agricultural-level agricultural-level * 1.02
        set water-availability water-availability + 0.1
      ]
      
      ; Drought effects
      if monsoon-intensity < 0.3 [
        set agricultural-level agricultural-level * 0.98
        set water-availability water-availability - 0.05
      ]
      
      ; Climate change effects
      set temperature temperature + climate-change-factor
      if temperature > 40 [
        set agricultural-level agricultural-level * 0.95
        set pollution-level pollution-level * 1.05
      ]
    ]
  ]
  
  ; Update total pollution
  set total-pollution sum [pollution-level] of patches with [is-land?]
end

to update-economy
  ; Update city economies
  ask cities [
    ; Economic growth
    ; One tick is one month: apply a twelfth of the annual growth rate.
    set economic-output economic-output * (1 + growth-rate / 12)
    
    ; Factors affecting growth
    let environmental-factor 1 - (pollution-index * 0.2)
    let infrastructure-factor infrastructure-score
    let education-factor ifelse-value any? people-here [mean [education-level] of people-here] [0.5]
    
    ; Annual growth derives from the national base rate each tick (it is not
    ; compounded), scaled by local environment, infrastructure and education.
    set growth-rate economic-growth-rate * environmental-factor * (0.5 + infrastructure-factor) * (0.5 + education-factor)
    
    ; Update GDP per capita
    set gdp-per-capita economic-output / population
    
    ; Employment effects
    ; Employment relaxes towards an equilibrium that rises with growth.
    let target-employment 0.93 + 2 * (growth-rate - 0.03)
    set employment-rate employment-rate + 0.05 * (target-employment - employment-rate)
    if employment-rate > 0.95 [ set employment-rate 0.95 ]
    if employment-rate < 0.1 [ set employment-rate 0.1 ]
  ]
  
  ; Update company performance
  ask companies [
    let local-market-conditions 1
    if any? cities-here [
      set local-market-conditions [gdp-per-capita] of one-of cities-here / 50000
    ]
    
    set revenue revenue * (1 + economic-growth-rate * local-market-conditions)
    set employees employees * (1 + economic-growth-rate * 0.5)
  ]
  
  ; Update patch economies
  ask patches [
    if is-land? [
      ; Industrial growth
      if industrial-level > 0.3 [
        set patch-gdp patch-gdp * 1.02
        set pollution-level pollution-level + 0.001
      ]
      
      ; Agricultural output
      if agricultural-level > 0.5 [
        let weather-factor monsoon-intensity
        set patch-gdp patch-gdp * (1 + weather-factor * 0.01)
      ]
      
      ; Service sector growth in urban areas
      if service-level > 0.5 [
        set patch-gdp patch-gdp * 1.015
      ]
    ]
  ]
  
  ; Update total GDP
  set total-gdp sum [economic-output] of cities + sum [revenue] of companies + sum [patch-gdp] of patches with [is-land?]
end

to update-population
  ; Update city populations
  ask cities [
    ; Natural population growth
    ; Monthly natural growth (half the annual economic growth rate).
    set population population * (1 + growth-rate * 0.5 / 12)
    
    ; Migration effects
    let migration-factor migration-attractiveness * employment-rate
    set population population * (1 + migration-factor * 0.0001)
    
    ; Update city size based on population
    set size 1.5 + 0.8 * ln (max list 1 (population / 1000000))
  ]
  
  ; Update people agents
  ask people [
    ; Age and career progression
    set age age + 0.01
    
    ; Income changes based on economic conditions
    if agent-type = "urban" [
      let city-growth 0
      if any? cities-here [
        set city-growth [growth-rate] of one-of cities-here
      ]
      set income income * (1 + city-growth * 0.5)
    ]
    
    ; Health and education updates
    set health-status health-status + (random-float 0.02 - 0.01)
    if health-status > 1 [ set health-status 1 ]
    if health-status < 0 [ set health-status 0 ]
    
    ; Job changes
    if random-float 1 < 0.001 [
      set job-sector one-of ["service" "manufacturing" "tech" "government" "agriculture"]
    ]
  ]
  
  ; Update total population
  set total-population sum [population] of cities + count people
end

to update-transportation
  ; Update highways
  ask highways [
    ; Traffic flow based on economic activity
    let nearby-economic-activity sum [patch-gdp] of patches in-radius 5
    set traffic-flow nearby-economic-activity / 10000
    
    ; Maintenance needs
    set maintenance-level maintenance-level - 0.001
    if maintenance-level < 0.3 [
      set highway-capacity highway-capacity * 0.98
    ]
    
    ; Congestion effects
    if traffic-flow > highway-capacity [
      set color red
    ]
  ]
  
  ; Update railways
  ask railways [
    let connected-cities count my-railway-links
    set passenger-flow connected-cities * 100
    set freight-flow sum [industrial-level] of patches in-radius 10 * 50
  ]
  
  ; Update airports
  ask airports [
    if any? cities-here [
      let city-pop [population] of one-of cities-here
      set passenger-volume city-pop / 10000
      
      if international? [
        set passenger-volume passenger-volume * 1.5
      ]
    ]
  ]
end

to handle-migration
  ask people with [agent-type = "migrant"] [
    ; Move toward migration target
    if migration-target != nobody [
      face migration-target
      forward mobility-level * 0.1
      
      ; Check if reached target
      if distance migration-target < 2 [
        set agent-type "urban"
        set color yellow
        set migration-target nobody
      ]
    ]
  ]
  
  ; Rural to urban migration
  ask people with [agent-type = "rural"] [
    if random-float 1 < 0.001 [
      ; Decide to migrate based on economic opportunities
      let nearest-city min-one-of cities [distance myself]
      if nearest-city != nobody [
        let city-opportunities [employment-rate] of nearest-city
        let rural-opportunities agricultural-level
        
        if city-opportunities > rural-opportunities + 0.2 [
          set agent-type "migrant"
          set migration-target nearest-city
          set color magenta
        ]
      ]
    ]
  ]
end

to implement-policies
  ; Government interventions
  ask government-offices [
    ; Infrastructure investment
    if random-float 1 < 0.01 [
      ask patches in-radius 5 [
        if is-land? [
          set road-density road-density + 0.05
          set power-grid-capacity power-grid-capacity + 0.03
        ]
      ]
    ]
    
    ; Education and healthcare programs
    if random-float 1 < 0.005 [
      ask patches in-radius 8 [
        if is-land? [
          set patch-education patch-education + 0.02
          set healthcare-access healthcare-access + 0.02
        ]
      ]
    ]
    
    ; Environmental regulations
    if total-pollution > 1000 [
      ask patches with [pollution-level > 0.5] [
        set pollution-level pollution-level * 0.95
        set industrial-level industrial-level * 0.98
      ]
    ]
  ]
end

to update-displays
  if display-mode = "economic" [ display-economic-view ]
  if display-mode = "environmental" [ display-environmental-view ]
  if display-mode = "population" [ display-population-view ]
  if display-mode = "transportation" [ display-transportation-view ]
  if display-mode = "development" [ display-development-view ]
end

to handle-seasonal-events
  ; Festival seasons (increase tourism and economic activity)
  if ticks mod 100 = 0 [
    ask cities with [city-type = "tourism"] [
      set economic-output economic-output * 1.1
    ]
  ]
  
  ; Harvest seasons
  if ticks mod 120 = 0 [
    ask patches with [agricultural-level > 0.5] [
      set patch-gdp patch-gdp * 1.15
    ]
  ]
  
  ; Monsoon season effects
  if monsoon-intensity > 0.8 [
    ; Flooding in low-lying areas
    ask patches with [pycor < -5 and is-land?] [
      if random-float 1 < 0.001 [
        set pcolor red
        set patch-gdp patch-gdp * 0.9
      ]
    ]
  ]
end

to handle-random-events
  ; Natural disasters
  if random-float 1 < 0.0001 [
    let disaster-center one-of patches with [is-land?]
    ask disaster-center [
      ask patches in-radius 5 [
        set patch-gdp patch-gdp * 0.7
        set pollution-level pollution-level * 1.2
        set pcolor red
      ]
    ]
    print "Natural disaster occurred!"
  ]
  
  ; Economic booms
  if random-float 1 < 0.0005 [
    let boom-city one-of cities
    ask boom-city [
      set economic-output economic-output * 1.2
      set employment-rate employment-rate + 0.1
      print (word city-name " experiences economic boom!")
    ]
  ]
  
  ; Technology innovations
  if random-float 1 < 0.0003 [
    ask cities with [city-type = "tech"] [
      set gdp-per-capita gdp-per-capita * 1.15
      ask patches in-radius 3 [
        if is-land? [
          set internet-coverage internet-coverage + 0.1
          set service-level service-level + 0.05
        ]
      ]
    ]
    print "Technology innovation spreads!"
  ]
end

; =============================================================================
; DISPLAY FUNCTIONS
; =============================================================================

to display-economic-view
  set display-mode "economic"
  ; Scale to the current range so colours stay meaningful as GDP grows
  ; (dark green = highest output).
  let land patches with [is-land?]
  ; Log scale, because output is heavily skewed across patches.
  let hi ln (1 + max [patch-gdp] of land)
  let lo ln (1 + min [patch-gdp] of land)
  ask land [ set pcolor scale-color green (ln (1 + patch-gdp)) (hi + 0.1 * (hi - lo)) (lo - 0.3 * (hi - lo)) ]
end

to display-environmental-view
  set display-mode "environmental"
  ask patches [
    if is-land? [
      let pollution-color scale-color red pollution-level 0 1
      set pcolor pollution-color
    ]
  ]
end

to display-population-view
  set display-mode "population"
  ask patches [
    if is-land? [
      let pop-color scale-color yellow population-density 0 2000
      set pcolor pop-color
    ]
  ]
end

to display-transportation-view
  set display-mode "transportation"
  ask patches [
    if is-land? [
      let transport-color scale-color blue road-density 0 1
      set pcolor transport-color
    ]
  ]
end

to display-development-view
  set display-mode "development"
  ask patches [
    if is-land? [
      let dev-index (patch-education + healthcare-access + patch-infrastructure) / 3
      let dev-color scale-color violet dev-index 0 1
      set pcolor dev-color
    ]
  ]
end

to update-patch-color
  if display-mode = "economic" [
    let gdp-level patch-gdp / 2000
    if gdp-level > 1 [ set gdp-level 1 ]
    set pcolor scale-color green gdp-level 0 1
  ]
end

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

to reset-colors
  set display-mode "default"
  ask patches [
    ifelse is-land? [
      set pcolor green + 2
    ] [
      set pcolor blue + 3
    ]
  ]
end

to-report get-state-info [patch-x patch-y]
  let target-patch patch patch-x patch-y
  if target-patch != nobody [
    report [state-name] of target-patch
  ]
  report "Unknown"
end

to-report total-land-patches
  report count patches with [is-land?]
end

to-report total-agents
  report count people
end

to-report total-cities
  report count cities
end

to-report total-companies
  report count companies
end

to-report average-pollution
  if any? patches with [is-land?] [
    report mean [pollution-level] of patches with [is-land?]
  ]
  report 0
end

to-report average-development
  if any? patches with [is-land?] [
    report mean [(patch-education + healthcare-access) / 2] of patches with [is-land?]
  ]
  report 0
end

to-report unemployment-rate-national
  if any? cities [
    report mean [1 - employment-rate] of cities
  ]
  report 0
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
826
626
-1
-1
6.0
1
10
1
1
1
0
0
0
1
-50
50
-50
50
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
95
200
125
economic view
display-economic-view
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
129
200
159
environment view
display-environmental-view
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
163
200
193
population view
display-population-view
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
197
200
227
transport view
display-transportation-view
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
231
200
261
development view
display-development-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
271
102
316
Land patches
total-land-patches
0
1
11

MONITOR
108
271
200
316
Agents
total-agents
0
1
11

MONITOR
10
321
102
366
Cities
total-cities
0
1
11

MONITOR
108
321
200
366
Companies
total-companies
0
1
11

MONITOR
10
371
102
416
Total GDP
total-gdp
0
1
11

MONITOR
108
371
200
416
Avg pollution
average-pollution
3
1
11

MONITOR
10
421
102
466
Avg development
average-development
3
1
11

MONITOR
108
421
200
466
Unemployment
unemployment-rate-national
3
1
11

PLOT
835
10
1135
210
Economy
ticks
GDP
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total GDP" 1.0 0 -10899396 true "" "plot total-gdp"

PLOT
835
220
1135
420
Environment and jobs
ticks
index
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"pollution" 1.0 0 -2674135 true "" "plot average-pollution"
"development" 1.0 0 -13345367 true "" "plot average-development"
"unemployment" 1.0 0 -955883 true "" "plot unemployment-rate-national"
@#$#@#$#@
## WHAT IS IT?

An advanced agent-based simulation of India built on real state boundaries. Cities, people, companies, transport links and government offices interact with an economic, environmental and social layer stored on every map patch.

## HOW IT WORKS

- State boundaries are loaded from `map/india_boundary.shp`; each land patch carries economic (GDP, industry, agriculture, services), environmental (pollution, water, forest, temperature, rainfall, air quality), infrastructure and social (education, healthcare, unemployment) indicators.
- Ten major cities are placed at their real latitude and longitude with population, GDP per capita, growth, infrastructure, pollution and employment attributes.
- Urban, rural, migrant and tourist agents move, work and migrate towards attractive cities; companies produce and employ; highways, railways and airports carry flows.
- Each tick updates the environment (monsoon, pollution, climate factor), the economy, population, transport, migration and government policy, plus seasonal and random events.

## HOW TO USE IT

Press SETUP, then GO. Use the view buttons to recolour the map by economic output, pollution, population density, transport infrastructure or overall development. Watch the plots for national GDP, pollution, development and unemployment.

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
