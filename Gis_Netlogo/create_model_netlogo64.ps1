# PowerShell Script to Create NetLogo Model Properly for NetLogo 6.4
# This script creates a NetLogo model that's compatible with NetLogo 6.4

Write-Host "Creating NetLogo 6.4 Compatible Model..." -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Check if NetLogo is installed
$netlogoInstalled = $false
$netlogoPaths = @(
    "C:\Program Files\NetLogo 6.4.0\NetLogo.exe",
    "C:\Program Files (x86)\NetLogo 6.4.0\NetLogo.exe",
    "C:\Program Files\NetLogo 6.3.0\NetLogo.exe",
    "C:\Program Files (x86)\NetLogo 6.3.0\NetLogo.exe",
    "C:\Program Files\NetLogo 6.2.2\NetLogo.exe",
    "C:\Program Files (x86)\NetLogo 6.2.2\NetLogo.exe"
)

$netlogoPath = $null
foreach ($path in $netlogoPaths) {
    if (Test-Path $path) {
        $netlogoPath = $path
        $netlogoInstalled = $true
        Write-Host "Found NetLogo at: $path" -ForegroundColor Green
        break
    }
}

if (-not $netlogoInstalled) {
    Write-Host "NetLogo not found in standard locations." -ForegroundColor Yellow
    Write-Host "Please install NetLogo 6.4 from: https://ccl.northwestern.edu/netlogo/" -ForegroundColor Yellow
    Write-Host "Or manually open NetLogo and create a new model with the following code:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Try opening indian_map_simple.nlogo instead" -ForegroundColor Cyan
    exit
}

# Create a temporary NetLogo script to generate the proper model format
$tempScript = @"
; This is a temporary script to create the model properly
extensions [gis]

globals [
  india-dataset
  states-dataset
]

breed [cities city]
breed [walkers walker]

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
  create-walkers 50 [
    let land-patches patches with [is-land?]
    if any? land-patches [ move-to one-of land-patches ]
    set color yellow
    set size 0.8
    set shape "circle"
  ]
end

to go
  ask walkers [ move-agent ]
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
  report count walkers
end

to-report total-cities
  report count cities
end
"@

# Write the script to a temporary file
$tempScript | Out-File -FilePath "temp_model.nlogo" -Encoding UTF8

Write-Host "Temporary model file created. Now starting NetLogo..." -ForegroundColor Cyan

# Try to open NetLogo with the model
try {
    Start-Process -FilePath $netlogoPath -ArgumentList "temp_model.nlogo" -Wait:$false
    Write-Host "NetLogo started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT STEPS TO COMPLETE SETUP:" -ForegroundColor Yellow
    Write-Host "1. NetLogo should now be open with the model loaded" -ForegroundColor White
    Write-Host "2. Go to File → Save As... and save it as 'indian_map_model.nlogo'" -ForegroundColor White
    Write-Host "3. This will create a proper NetLogo 6.4 format file" -ForegroundColor White
    Write-Host "4. Close NetLogo" -ForegroundColor White
    Write-Host "5. Delete the temporary file: temp_model.nlogo" -ForegroundColor White
    Write-Host ""
    Write-Host "After saving, you can open indian_map_model.nlogo normally!" -ForegroundColor Green
} catch {
    Write-Host "Failed to start NetLogo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please manually open NetLogo and load temp_model.nlogo" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Alternative: Use indian_map_simple.nlogo" -ForegroundColor Cyan
Write-Host "This file should work directly with NetLogo 6.4" -ForegroundColor Cyan
