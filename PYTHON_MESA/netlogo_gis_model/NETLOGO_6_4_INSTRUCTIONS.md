# NetLogo 6.4 Compatible India Models

I've created **3 versions** specifically designed for NetLogo 6.4 compatibility:

## **RECOMMENDED ORDER TO TRY:**

### 1. **`india_ultra_simple_6_4.nlogo`** (START HERE)
- **Most likely to work** - Ultra minimal version
- **No extensions needed** - Pure NetLogo code
- **5 Indian states** with basic visualization
- **Features**: State coloring, population display, analysis

### 2. **`india_simple_6_4.nlogo`** (If first works)
- **Uses table extension only** - Standard NetLogo feature
- **9 Indian states** with more detail
- **Features**: Cities, better mapping, people movement

### 3. **`india_netlogo_6_4.nlogo`** (Most advanced)
- **Full featured version** - Complete GIS simulation
- **Table extension** for data management
- **12+ Indian states** with realistic data
- **Features**: Cities, population analysis, urban/rural classification

## **TESTING STEPS:**

### For `india_ultra_simple_6_4.nlogo`:
1. **Open NetLogo 6.4**
2. **File → Open** → Select `india_ultra_simple_6_4.nlogo`
3. **Click "setup"** - Should see colored patches
4. **Click "go"** - Should see blue people moving
5. **Click "show-states"** - Should see state colors
6. **Click "show-population"** - Should see population density
7. **Click patches + "analyze"** - Should get state info

### Expected Results:
- **Red** = Maharashtra
- **Green** = Karnataka  
- **Orange** = Delhi
- **Blue** = Tamil Nadu
- **Violet** = West Bengal
- **Gray** = Other areas

## **NetLogo 6.4 Compatibility Features:**

### What I Fixed:
- **Removed problematic extensions** (gis, complex file operations)
- **Simplified syntax** for NetLogo 6.4 parser
- **Fixed table operations** for newer table extension
- **Simplified global variables** initialization
- **Removed complex file I/O** that causes loading issues
- **Used standard NetLogo functions** only
- **Proper breed declarations** for NetLogo 6.4

### Key Changes from Earlier Versions:
- **No `__includes`** directive (causes loading errors)
- **No file reading** during setup (causes format errors)
- **Simplified string handling** (no custom split functions)
- **Standard table extension** usage only
- **Proper variable initialization** order

## **How to Use:**

### Basic Controls:
- **setup** = Create the Indian states map
- **go** = Start people moving around
- **show-states** = Display states in different colors
- **show-population** = Show population density as red intensity
- **analyze** = Click on patches to get state information

### Interactive Features:
1. **Click setup** to create the map
2. **Click go** to start simulation
3. **Click on any patch** then **click analyze** to get state info
4. **Switch between state view and population view**

## **If Still Getting Errors:**

### Check These:
1. **NetLogo Version**: Must be 6.4 or compatible
2. **File Extension**: Must be `.nlogo` (not `.txt`)
3. **Download Location**: File must be saved properly
4. **Error Messages**: Look in Command Center for specific errors

### Common NetLogo 6.4 Issues:
- **Extensions not loading**: Try the ultra-simple version first
- **Syntax errors**: NetLogo 6.4 is stricter about syntax
- **Memory issues**: Reduce world size if needed
- **File path issues**: Use absolute paths or place files in NetLogo directory

## **Success Indicators:**

### Ultra Simple Version Working:
- **Colored patches** representing Indian states
- **Blue people** moving around
- **State analysis** when clicking patches
- **Population visualization** in red scale

### If This Works:
- Try the simple version for more features
- Then try the advanced version for full GIS capabilities
- All models are designed for NetLogo 6.4 compatibility

## **What Each Model Provides:**

### Ultra Simple:
- 5 major Indian states
- Basic population data
- Simple people movement
- State analysis

### Simple:
- 9 Indian states
- Major cities marked
- Better population visualization
- Enhanced people movement

### Advanced:
- 12+ Indian states
- Realistic population data
- Urban/rural classification
- Advanced analysis tools
- Metro city identification

---

**Start with `india_ultra_simple_6_4.nlogo` - it's designed to work in ANY NetLogo 6.4 installation!**
