"""
India GIS Model - Python Version using Mesa
A complete agent-based model of Indian states with GIS-like visualization
Runs in VS Code with interactive visualization
"""

import mesa
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.patches import Rectangle
import random
from typing import Dict, List, Tuple

class Person(mesa.Agent):
    """A person agent representing population in Indian states"""
    
    def __init__(self, unique_id: int, model, home_state: str):
        super().__init__(unique_id, model)
        self.home_state = home_state
        self.mobility_factor = random.random()
        self.current_state = home_state
        
    def step(self):
        """Agent behavior - move towards cities or randomly"""
        # Find nearby cities
        nearby_cities = [city for city in self.model.cities if city.state == self.current_state]
        
        if nearby_cities and self.mobility_factor > 0.5:
            # Move towards nearest city
            target_city = random.choice(nearby_cities)
            # Simple movement logic
            current_pos = self.pos
            city_pos = target_city.pos
            
            # Move slightly towards city
            new_x = current_pos[0] + 0.1 * (city_pos[0] - current_pos[0])
            new_y = current_pos[1] + 0.1 * (city_pos[1] - current_pos[1])
            
            # Ensure within bounds
            new_x = max(0, min(self.model.grid.width - 1, new_x))
            new_y = max(0, min(self.model.grid.height - 1, new_y))
            
            self.model.grid.move_agent(self, (new_x, new_y))
        else:
            # Random walk (continuous space has no cells, so take a small step)
            x, y = self.pos
            new_x = max(0, min(self.model.grid.width - 1, x + random.uniform(-1, 1)))
            new_y = max(0, min(self.model.grid.height - 1, y + random.uniform(-1, 1)))
            self.model.grid.move_agent(self, (new_x, new_y))

class City(mesa.Agent):
    """A city agent representing major Indian cities"""
    
    def __init__(self, unique_id: int, model, name: str, state: str, population: int, city_type: str):
        super().__init__(unique_id, model)
        self.name = name
        self.state = state
        self.population = population
        self.city_type = city_type  # "metro", "urban", "rural"
        
    def step(self):
        """Cities don't move, but could have growth dynamics"""
        pass

class IndiaGISModel(mesa.Model):
    """Main model class for India GIS simulation"""
    
    def __init__(self, width: int = 80, height: int = 60, num_people: int = 200):
        super().__init__()
        
        # Model parameters
        self.width = width
        self.height = height
        self.num_people = num_people
        
        # Create grid
        self.grid = mesa.space.ContinuousSpace(width, height, torus=False)
        
        # Create scheduler
        self.schedule = mesa.time.RandomActivation(self)
        
        # Initialize data
        self.states_data = self._create_states_data()
        self.cities_data = self._create_cities_data()
        self.state_boundaries = self._create_state_boundaries()
        
        # Storage for agents
        self.people = []
        self.cities = []
        
        # Create agents
        self._create_cities()
        self._create_people()
        
        # Statistics
        self.total_population = 0
        self.selected_state = None
        self.display_mode = "states"  # "states", "population", "elevation"
        
        # Data collection
        self.datacollector = mesa.datacollection.DataCollector(
            model_reporters={
                "Total Population": lambda m: sum(state['population'] for state in m.states_data.values()),
                "Urban Population": lambda m: len([p for p in m.people if p.current_state in ['Maharashtra', 'Delhi', 'Karnataka']]),
                "Rural Population": lambda m: len([p for p in m.people if p.current_state not in ['Maharashtra', 'Delhi', 'Karnataka']]),
            }
        )
        
    def _create_states_data(self) -> Dict:
        """Create comprehensive Indian states data"""
        return {
            "Maharashtra": {
                "code": "MH",
                "population": 112374333,
                "area": 307713,
                "density": 365,
                "capital": "Mumbai",
                "color": "red",
                "bounds": (10, 30, 15, 35)  # x_min, x_max, y_min, y_max
            },
            "Karnataka": {
                "code": "KA",
                "population": 61095297,
                "area": 191791,
                "density": 319,
                "capital": "Bangalore",
                "color": "green",
                "bounds": (20, 40, 10, 30)
            },
            "Tamil Nadu": {
                "code": "TN",
                "population": 72147030,
                "area": 130060,
                "density": 555,
                "capital": "Chennai",
                "color": "blue",
                "bounds": (30, 50, 5, 25)
            },
            "Kerala": {
                "code": "KL",
                "population": 33406061,
                "area": 38852,
                "density": 860,
                "capital": "Thiruvananthapuram",
                "color": "yellow",
                "bounds": (25, 35, 0, 15)
            },
            "Gujarat": {
                "code": "GJ",
                "population": 60439692,
                "area": 196244,
                "density": 308,
                "capital": "Gandhinagar",
                "color": "cyan",
                "bounds": (5, 25, 25, 45)
            },
            "Rajasthan": {
                "code": "RJ",
                "population": 68548437,
                "area": 342239,
                "density": 200,
                "capital": "Jaipur",
                "color": "magenta",
                "bounds": (15, 35, 35, 55)
            },
            "Uttar Pradesh": {
                "code": "UP",
                "population": 199812341,
                "area": 240928,
                "density": 828,
                "capital": "Lucknow",
                "color": "gray",
                "bounds": (35, 55, 30, 50)
            },
            "West Bengal": {
                "code": "WB",
                "population": 91276115,
                "area": 88752,
                "density": 1028,
                "capital": "Kolkata",
                "color": "purple",
                "bounds": (50, 70, 25, 45)
            },
            "Delhi": {
                "code": "DL",
                "population": 16787941,
                "area": 1484,
                "density": 11320,
                "capital": "New Delhi",
                "color": "orange",
                "bounds": (40, 50, 40, 50)
            }
        }
    
    def _create_cities_data(self) -> List[Dict]:
        """Create major Indian cities data"""
        return [
            {"name": "Mumbai", "state": "Maharashtra", "population": 12442373, "type": "metro", "pos": (20, 25)},
            {"name": "Delhi", "state": "Delhi", "population": 11007835, "type": "metro", "pos": (45, 45)},
            {"name": "Bangalore", "state": "Karnataka", "population": 8443675, "type": "metro", "pos": (30, 20)},
            {"name": "Chennai", "state": "Tamil Nadu", "population": 4681087, "type": "metro", "pos": (40, 15)},
            {"name": "Kolkata", "state": "West Bengal", "population": 4486679, "type": "metro", "pos": (60, 35)},
            {"name": "Hyderabad", "state": "Telangana", "population": 6993262, "type": "metro", "pos": (35, 25)},
            {"name": "Pune", "state": "Maharashtra", "population": 3124458, "type": "urban", "pos": (25, 30)},
            {"name": "Ahmedabad", "state": "Gujarat", "population": 5570585, "type": "metro", "pos": (15, 35)},
            {"name": "Jaipur", "state": "Rajasthan", "population": 3046163, "type": "urban", "pos": (25, 45)},
            {"name": "Lucknow", "state": "Uttar Pradesh", "population": 2817105, "type": "urban", "pos": (45, 40)}
        ]
    
    def _create_state_boundaries(self) -> Dict:
        """Create state boundary definitions for visualization"""
        boundaries = {}
        for state, data in self.states_data.items():
            bounds = data["bounds"]
            boundaries[state] = {
                "x_min": bounds[0],
                "x_max": bounds[1], 
                "y_min": bounds[2],
                "y_max": bounds[3],
                "color": data["color"]
            }
        return boundaries
    
    def _create_cities(self):
        """Create city agents"""
        for i, city_data in enumerate(self.cities_data):
            city = City(
                unique_id=i + 10000,  # Offset to avoid conflicts
                model=self,
                name=city_data["name"],
                state=city_data["state"],
                population=city_data["population"],
                city_type=city_data["type"]
            )
            
            # Place city at specified position
            pos = city_data["pos"]
            self.grid.place_agent(city, pos)
            self.cities.append(city)
            self.schedule.add(city)
    
    def _create_people(self):
        """Create people agents"""
        for i in range(self.num_people):
            # Choose random state weighted by population
            state_weights = [data["population"] for data in self.states_data.values()]
            state_names = list(self.states_data.keys())
            home_state = random.choices(state_names, weights=state_weights)[0]
            
            person = Person(unique_id=i, model=self, home_state=home_state)
            
            # Place person in their home state
            state_bounds = self.states_data[home_state]["bounds"]
            x = random.uniform(state_bounds[0], state_bounds[1])
            y = random.uniform(state_bounds[2], state_bounds[3])
            
            self.grid.place_agent(person, (x, y))
            self.people.append(person)
            self.schedule.add(person)
    
    def step(self):
        """Advance the model by one step"""
        self.schedule.step()
        self.datacollector.collect(self)
        
        # Update statistics
        self.total_population = sum(state['population'] for state in self.states_data.values())
    
    def get_state_at_position(self, x: float, y: float) -> str:
        """Get the state name at a given position"""
        for state, bounds in self.state_boundaries.items():
            if (bounds["x_min"] <= x <= bounds["x_max"] and 
                bounds["y_min"] <= y <= bounds["y_max"]):
                return state
        return "Unknown"
    
    def analyze_state(self, state_name: str) -> Dict:
        """Analyze a specific state"""
        if state_name not in self.states_data:
            return {"error": "State not found"}
        
        state_data = self.states_data[state_name]
        people_in_state = [p for p in self.people if p.current_state == state_name]
        cities_in_state = [c for c in self.cities if c.state == state_name]
        
        return {
            "name": state_name,
            "population": state_data["population"],
            "density": state_data["density"],
            "area": state_data["area"],
            "capital": state_data["capital"],
            "people_agents": len(people_in_state),
            "cities": len(cities_in_state),
            "city_names": [c.name for c in cities_in_state],
            "urbanization_rate": len(cities_in_state) / max(1, len(people_in_state)) * 100
        }

def create_visualization(model: IndiaGISModel, display_mode: str = "states") -> plt.Figure:
    """Create matplotlib visualization of the model"""
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Draw state boundaries
    for state, bounds in model.state_boundaries.items():
        if display_mode == "states":
            color = bounds["color"]
            alpha = 0.6
        elif display_mode == "population":
            density = model.states_data[state]["density"]
            color = plt.cm.Reds(density / 12000)  # Normalize by max density
            alpha = 0.8
        else:  # elevation mode
            color = plt.cm.Greens(random.random())  # Random elevation
            alpha = 0.7
        
        rect = Rectangle(
            (bounds["x_min"], bounds["y_min"]),
            bounds["x_max"] - bounds["x_min"],
            bounds["y_max"] - bounds["y_min"],
            facecolor=color,
            alpha=alpha,
            edgecolor='black',
            linewidth=1
        )
        ax.add_patch(rect)
        
        # Add state label
        center_x = (bounds["x_min"] + bounds["x_max"]) / 2
        center_y = (bounds["y_min"] + bounds["y_max"]) / 2
        ax.text(center_x, center_y, state, ha='center', va='center', 
                fontsize=8, weight='bold', color='white')
    
    # Draw cities
    for city in model.cities:
        x, y = city.pos
        size = 100 if city.city_type == "metro" else 50
        color = "red" if city.city_type == "metro" else "orange"
        ax.scatter(x, y, s=size, c=color, marker='o', edgecolors='black', linewidth=1)
        ax.text(x, y+2, city.name, ha='center', va='bottom', fontsize=6, weight='bold')
    
    # Draw people
    for person in model.people:
        x, y = person.pos
        ax.scatter(x, y, s=10, c='blue', marker='.', alpha=0.7)
    
    # Formatting
    ax.set_xlim(0, model.width)
    ax.set_ylim(0, model.height)
    ax.set_aspect('equal')
    ax.set_title(f'India GIS Model - {display_mode.title()} View', fontsize=14, weight='bold')
    ax.set_xlabel('X Coordinate')
    ax.set_ylabel('Y Coordinate')
    
    # Add legend
    legend_elements = [
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='red', markersize=10, label='Metro Cities'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='orange', markersize=8, label='Urban Cities'),
        plt.Line2D([0], [0], marker='.', color='w', markerfacecolor='blue', markersize=8, label='People')
    ]
    ax.legend(handles=legend_elements, loc='upper right')
    
    plt.tight_layout()
    return fig

def run_simulation(steps: int = 10) -> IndiaGISModel:
    """Run the simulation for specified steps"""
    print("Starting India GIS Simulation...")
    
    # Create model
    model = IndiaGISModel(width=80, height=60, num_people=200)
    
    print(f"Created model with {len(model.people)} people and {len(model.cities)} cities")
    print(f"States included: {', '.join(model.states_data.keys())}")
    
    # Run simulation
    for i in range(steps):
        model.step()
        if i % 5 == 0:
            print(f"Step {i+1}/{steps} completed")
    
    print(f"Simulation completed! Total steps: {steps}")
    return model

def analyze_results(model: IndiaGISModel):
    """Analyze and display simulation results"""
    print("\n" + "="*50)
    print("SIMULATION ANALYSIS")
    print("="*50)
    
    # Overall statistics
    print(f"Total Cities: {len(model.cities)}")
    print(f"Total People Agents: {len(model.people)}")
    print(f"Total States: {len(model.states_data)}")
    
    # State analysis
    print("\n  STATE ANALYSIS:")
    print("-" * 40)
    
    for state_name in model.states_data.keys():
        analysis = model.analyze_state(state_name)
        print(f"{state_name}:")
        print(f"Population: {analysis['population']:,}")
        print(f"Density: {analysis['density']} per km²")
        print(f"Cities: {', '.join(analysis['city_names'])}")
        print(f"Agent Count: {analysis['people_agents']}")
        print()
    
    # Data collection results
    data = model.datacollector.get_model_vars_dataframe()
    if not data.empty:
        print("SIMULATION TRENDS:")
        print("-" * 40)
        print(data.describe())

def main():
    """Main execution function"""
    print("India GIS Model - Python Version")
    print("=" * 50)
    
    # Run simulation
    model = run_simulation(steps=20)
    
    # Analyze results
    analyze_results(model)
    
    # Create visualizations
    print("\n Creating visualizations...")
    
    # States view
    fig1 = create_visualization(model, "states")
    fig1.savefig('india_states_view.png', dpi=300, bbox_inches='tight')
    print("Saved: india_states_view.png")
    
    # Population view
    fig2 = create_visualization(model, "population")
    fig2.savefig('india_population_view.png', dpi=300, bbox_inches='tight')
    print("Saved: india_population_view.png")
    
    # Show plots
    plt.show()
    
    # Export data
    print("\n Exporting data...")
    
    # Model data
    model_data = []
    for person in model.people:
        model_data.append({
            'agent_id': person.unique_id,
            'x': person.pos[0],
            'y': person.pos[1],
            'home_state': person.home_state,
            'current_state': person.current_state,
            'mobility_factor': person.mobility_factor
        })
    
    df = pd.DataFrame(model_data)
    df.to_csv('india_model_data.csv', index=False)
    print("Saved: india_model_data.csv")
    
    print("\n Simulation completed successfully!")
    print("Check the generated PNG files and CSV data")
    
    return model

if __name__ == "__main__":
    model = main()
