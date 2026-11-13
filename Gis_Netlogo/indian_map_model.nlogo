<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE netlogo SYSTEM "http://ccl.northwestern.edu/netlogo/dtd/netlogo_model.dtd">
<netlogo version="6.4.0">
  <world_dimensions>
    <max_pxcor>50</max_pxcor>
    <max_pycor>50</max_pycor>
    <min_pxcor>-50</min_pxcor>
    <min_pycor>-50</min_pycor>
    <patch_size>8</patch_size>
    <wrapping_allowed_in_x>false</wrapping_allowed_in_x>
    <wrapping_allowed_in_y>false</wrapping_allowed_in_y>
  </world_dimensions>
  <extensions>
    <extension>gis</extension>
  </extensions>
  <globals>
    <global>india-dataset</global>
    <global>states-dataset</global>
    <global>india-envelope</global>
    <global>total-gdp</global>
    <global>total-pollution</global>
    <global>total-population</global>
    <global>monsoon-intensity</global>
    <global>economic-growth-rate</global>
    <global>climate-change-factor</global>
    <global>display-mode</global>
  </globals>
  <breeds>
    <breed>
      <name>cities</name>
      <singular>city</singular>
    </breed>
    <breed>
      <name>people</name>
      <singular>person</singular>
    </breed>
    <breed>
      <name>companies</name>
      <singular>company</singular>
    </breed>
    <breed>
      <name>highways</name>
      <singular>highway</singular>
    </breed>
    <breed>
      <name>railways</name>
      <singular>railway</singular>
    </breed>
    <breed>
      <name>airports</name>
      <singular>airport</singular>
    </breed>
    <breed>
      <name>government-offices</name>
      <singular>government-office</singular>
    </breed>
  </breeds>
  <patches_own>
    <patch_own>state-name</patch_own>
    <patch_own>is-land?</patch_own>
    <patch_own>patch-gdp</patch_own>
    <patch_own>industrial-level</patch_own>
    <patch_own>agricultural-level</patch_own>
    <patch_own>service-level</patch_own>
    <patch_own>pollution-level</patch_own>
    <patch_own>water-availability</patch_own>
    <patch_own>forest-cover</patch_own>
    <patch_own>road-density</patch_own>
    <patch_own>power-grid-capacity</patch_own>
    <patch_own>internet-coverage</patch_own>
    <patch_own>education-level</patch_own>
    <patch_own>healthcare-access</patch_own>
    <patch_own>unemployment-rate</patch_own>
    <patch_own>population-density</patch_own>
    <patch_own>temperature</patch_own>
    <patch_own>rainfall</patch_own>
    <patch_own>air-quality</patch_own>
    <patch_own>infrastructure-score</patch_own>
  </patches_own>
  <turtles_own>
  </turtles_own>
  <cities_own>
    <turtle_own>city-name</turtle_own>
    <turtle_own>population</turtle_own>
    <turtle_own>city-type</turtle_own>
    <turtle_own>gdp-per-capita</turtle_own>
    <turtle_own>growth-rate</turtle_own>
    <turtle_own>infrastructure-score</turtle_own>
    <turtle_own>pollution-index</turtle_own>
    <turtle_own>employment-rate</turtle_own>
    <turtle_own>migration-attractiveness</turtle_own>
    <turtle_own>economic-output</turtle_own>
    <turtle_own>tax-revenue</turtle_own>
  </cities_own>
  <people_own>
    <turtle_own>agent-type</turtle_own>
    <turtle_own>age</turtle_own>
    <turtle_own>income</turtle_own>
    <turtle_own>education-level</turtle_own>
    <turtle_own>health-status</turtle_own>
    <turtle_own>job-sector</turtle_own>
    <turtle_own>mobility-level</turtle_own>
    <turtle_own>migration-target</turtle_own>
    <turtle_own>tourist-destinations</turtle_own>
    <turtle_own>current-destination</turtle_own>
  </people_own>
  <companies_own>
    <turtle_own>company-type</turtle_own>
    <turtle_own>company-size</turtle_own>
    <turtle_own>revenue</turtle_own>
    <turtle_own>employees</turtle_own>
    <turtle_own>production-capacity</turtle_own>
    <turtle_own>market-share</turtle_own>
  </companies_own>
  <highways_own>
    <turtle_own>highway-capacity</turtle_own>
    <turtle_own>traffic-flow</turtle_own>
    <turtle_own>maintenance-level</turtle_own>
  </highways_own>
  <railways_own>
    <turtle_own>railway-capacity</turtle_own>
    <turtle_own>passenger-flow</turtle_own>
    <turtle_own>freight-flow</turtle_own>
  </railways_own>
  <airports_own>
    <turtle_own>airport-capacity</turtle_own>
    <turtle_own>international?</turtle_own>
    <turtle_own>passenger-volume</turtle_own>
  </airports_own>
  <government-offices_own>
    <turtle_own>office-type</turtle_own>
    <turtle_own>budget</turtle_own>
    <turtle_own>efficiency</turtle_own>
  </government-offices_own>
  <code><![CDATA[
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
  ; Load the Indian boundary shapefile
  if file-exists? "data/india_boundary.shp" [
    set india-dataset gis:load-dataset "data/india_boundary.shp"
    gis:set-world-envelope (gis:envelope-of india-dataset)
    gis:apply-coverage india-dataset "st_nm" state-name
    
    ; Mark land patches and initialize properly
    ask patches [
      set is-land? (state-name != 0 and state-name != "")
      if is-land? [
        set pcolor green + 2
      ]
    ]
    
    ; Draw boundaries
    gis:set-drawing-color black
    gis:draw india-dataset 2
  ]
  
  ; Load states dataset if available
  if file-exists? "data/india_states.shp" [
    set states-dataset gis:load-dataset "data/india_states.shp"
    gis:set-drawing-color white
    gis:draw states-dataset 1
  ]
  
  ; If shapefiles don't exist, create a basic map representation
  if not file-exists? "data/india_boundary.shp" [
    create-basic-india-outline
  ]
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
      set education-level random-float 0.7
      set healthcare-access random-float 0.6
      set unemployment-rate random-float 0.15
      
      ; Population density (people per patch)
      set population-density random-exponential 500
      
      ; Set initial color based on development level
      update-patch-color
    ]
  ]
end

to create-major-cities
  ; Create major Indian cities with realistic attributes
  let city-data [
    ["New Delhi" 32000000 0 8 "capital" 85000]
    ["Mumbai" 25000000 -8 2 "financial" 78000]
    ["Kolkata" 15000000 8 5 "industrial" 45000]
    ["Chennai" 12000000 5 -10 "automotive" 52000]
    ["Bangalore" 14000000 2 -8 "tech" 68000]
    ["Hyderabad" 10000000 3 -5 "pharma" 48000]
    ["Ahmedabad" 8000000 -12 8 "textile" 42000]
    ["Pune" 7000000 -6 1 "it" 55000]
    ["Surat" 6000000 -10 5 "diamond" 38000]
    ["Jaipur" 4000000 -5 12 "tourism" 35000]
  ]
  
  foreach city-data [ city-info ->
    create-cities 1 [
      set city-name item 0 city-info
      set population item 1 city-info
      setxy item 2 city-info item 3 city-info
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
      set size 2 + (population / 10000000)
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
    set economic-output economic-output * (1 + growth-rate)
    
    ; Factors affecting growth
    let environmental-factor 1 - (pollution-index * 0.2)
    let infrastructure-factor infrastructure-score
    let education-factor mean [education-level] of people-here
    
    set growth-rate growth-rate * environmental-factor * infrastructure-factor * education-factor
    
    ; Update GDP per capita
    set gdp-per-capita economic-output / population
    
    ; Employment effects
    set employment-rate employment-rate + (growth-rate - 0.02) * 0.5
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
    set population population * (1 + growth-rate * 0.5)
    
    ; Migration effects
    let migration-factor migration-attractiveness * employment-rate
    set population population * (1 + migration-factor * 0.001)
    
    ; Update city size based on population
    set size 2 + (population / 10000000)
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
          set education-level education-level + 0.02
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
  ask patches [
    if is-land? [
      let gdp-level patch-gdp / 2000
      if gdp-level > 1 [ set gdp-level 1 ]
      set pcolor scale-color green gdp-level 0 1
    ]
  ]
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
      let dev-index (education-level + healthcare-access + infrastructure-score) / 3
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
  ask patches [
    if is-land? [
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
    report mean [(education-level + healthcare-access) / 2] of patches with [is-land?]
  ]
  report 0
end

to-report unemployment-rate-national
  if any? cities [
    report mean [1 - employment-rate] of cities
  ]
  report 0
end
]]></code>
  <interface>
    <button>
      <left>29</left>
      <top>10</top>
      <right>94</right>
      <bottom>43</bottom>
      <label>setup</label>
      <action_key>S</action_key>
      <go>false</go>
    </button>
    <button>
      <left>107</left>
      <top>10</top>
      <right>172</right>
      <bottom>43</bottom>
      <label>go</label>
      <action_key>G</action_key>
      <go>true</go>
    </button>
    <button>
      <left>185</left>
      <top>10</top>
      <right>290</right>
      <bottom>43</bottom>
      <label>go forever</label>
      <action_key>F</action_key>
      <go>true</go>
      <forever>true</forever>
    </button>
    <button>
      <left>29</left>
      <top>55</top>
      <right>134</right>
      <bottom>88</bottom>
      <label>reset-colors</label>
      <action_key>R</action_key>
      <go>false</go>
    </button>
    <monitor>
      <left>29</left>
      <top>100</top>
      <right>149</right>
      <bottom>145</bottom>
      <label>Land Patches</label>
      <value>total-land-patches</value>
      <precision>0</precision>
    </monitor>
    <monitor>
      <left>165</left>
      <top>100</top>
      <right>285</right>
      <bottom>145</bottom>
      <label>Total Agents</label>
      <value>total-agents</value>
      <precision>0</precision>
    </monitor>
    <monitor>
      <left>29</left>
      <top>155</top>
      <right>149</right>
      <bottom>200</bottom>
      <label>Total Cities</label>
      <value>total-cities</value>
      <precision>0</precision>
    </monitor>
    <textbox>
      <left>29</left>
      <top>220</top>
      <right>341</right>
      <bottom>290</bottom>
      <text>Indian Map Interface

1. Click 'setup' to load the map
2. Click 'go' to start simulation
3. Click on map areas to explore
4. Use 'reset-colors' to restore colors

Yellow dots = agents
Red dots = major cities</text>
    </textbox>
  </interface>
  <plots>
  </plots>
  <turtle_shapes>
    <turtle_shape>
      <name>default</name>
      <rotatable>true</rotatable>
      <element>
        <type>polygon</type>
        <color>141</color>
        <filled>true</filled>
        <points>150,5 40,250 150,205 260,250</points>
      </element>
    </turtle_shape>
    <turtle_shape>
      <name>circle</name>
      <rotatable>false</rotatable>
      <element>
        <type>circle</type>
        <color>7</color>
        <filled>true</filled>
        <cx>150</cx>
        <cy>150</cy>
        <radius>135</radius>
      </element>
    </turtle_shape>
  </turtle_shapes>
  <link_shapes>
    <link_shape>
      <name>default</name>
      <curviness>0.0</curviness>
      <element>
        <type>line</type>
        <xylist>0 0 0 1</xylist>
      </element>
    </link_shape>
  </link_shapes>
</netlogo>
