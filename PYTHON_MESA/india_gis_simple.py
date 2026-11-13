"""
Simple India GIS Model - Python Version using Mesa 3.2.0
A working agent-based model that runs in VS Code
"""

import mesa
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import random

class Person(mesa.Agent):
    """A person agent representing population in Indian states"""
    
    def __init__(self, unique_id, model, home_state):
        super().__init__(unique_id, model)
        self.home_state = home_state
        self.mobility_factor = random.random()
        self.current_state = home_state
        
    def step(self):
        """Agent behavior - simple random movement"""
        # Simple random movement
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        if possible_steps:
            new_position = self.random.choice(possible_steps)
            self.model.grid.move_agent(self, new_position)

class IndiaGISModel(mesa.Model):
    """Main model class for India GIS simulation"""
    
    def __init__(self, width=50, height=50, num_people=100):
        super().__init__()
        
        # Model parameters
        self.width = width
        self.height = height
        self.num_people = num_people
        self.running = True
        
        # Create grid
        self.grid = mesa.space.MultiGrid(width, height, torus=False)
        
        # Create scheduler
        self.schedule = mesa.time.RandomActivation(self)
        
        # Initialize state data
        self.states_data = self._create_states_data()
        self.state_boundaries = self._create_state_boundaries()
        
        # Create people
        self._create_people()
        
        # Data collection
        self.datacollector = mesa.datacollection.DataCollector(
            model_reporters={
                "Total People": lambda m: m.schedule.get_agent_count(),
                "Maharashtra People": lambda m: len([a for a in m.schedule.agents if a.current_state == "Maharashtra"]),
                "Karnataka People": lambda m: len([a for a in m.schedule.agents if a.current_state == "Karnataka"]),
            }
        )
        
    def _create_states_data(self):
        """Create Indian states data"""
        return {
            "Maharashtra": {"population": 112374333, "color": "red", "region": (10, 30, 10, 30)},
            "Karnataka": {"population": 61095297, "color": "green", "region": (15, 35, 5, 25)},
            "Tamil Nadu": {"population": 72147030, "color": "blue", "region": (20, 40, 0, 20)},
            "Kerala": {"population": 33406061, "color": "yellow", "region": (18, 30, 0, 15)},
            "Gujarat": {"population": 60439692, "color": "cyan", "region": (5, 25, 20, 40)},
            "Rajasthan": {"population": 68548437, "color": "magenta", "region": (10, 30, 30, 45)},
            "Uttar Pradesh": {"population": 199812341, "color": "gray", "region": (25, 45, 25, 45)},
            "West Bengal": {"population": 91276115, "color": "purple", "region": (35, 50, 20, 40)},
            "Delhi": {"population": 16787941, "color": "orange", "region": (30, 35, 35, 40)},
        }
    
    def _create_state_boundaries(self):
        """Create state boundary mapping"""
        boundaries = {}
        for state, data in self.states_data.items():
            region = data["region"]
            boundaries[state] = {
                "x_min": region[0], "x_max": region[1],
                "y_min": region[2], "y_max": region[3],
                "color": data["color"]
            }
        return boundaries
    
    def _create_people(self):
        """Create people agents"""
        for i in range(self.num_people):
            # Choose random state
            state = random.choice(list(self.states_data.keys()))
            
            # Create person
            person = Person(i, self, state)
            
            # Place in state region
            region = self.states_data[state]["region"]
            x = random.randint(region[0], min(region[1], self.width - 1))
            y = random.randint(region[2], min(region[3], self.height - 1))
            
            self.grid.place_agent(person, (x, y))
            self.schedule.add(person)
    
    def step(self):
        """Advance the model by one step"""
        self.schedule.step()
        self.datacollector.collect(self)
        
    def get_state_at_position(self, x, y):
        """Get state name at position"""
        for state, bounds in self.state_boundaries.items():
            if (bounds["x_min"] <= x <= bounds["x_max"] and 
                bounds["y_min"] <= y <= bounds["y_max"]):
                return state
        return "Unknown"

def visualize_model(model):
    """Create visualization of the model"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
    
    # Plot 1: State map with agents
    ax1.set_xlim(0, model.width)
    ax1.set_ylim(0, model.height)
    
    # Draw state boundaries
    for state, bounds in model.state_boundaries.items():
        from matplotlib.patches import Rectangle
        rect = Rectangle(
            (bounds["x_min"], bounds["y_min"]),
            bounds["x_max"] - bounds["x_min"],
            bounds["y_max"] - bounds["y_min"],
            facecolor=bounds["color"],
            alpha=0.3,
            edgecolor='black'
        )
        ax1.add_patch(rect)
        
        # Add state label
        center_x = (bounds["x_min"] + bounds["x_max"]) / 2
        center_y = (bounds["y_min"] + bounds["y_max"]) / 2
        ax1.text(center_x, center_y, state, ha='center', va='center', fontsize=8)
    
    # Plot agents
    for agent in model.schedule.agents:
        x, y = agent.pos
        ax1.scatter(x, y, c='blue', s=20, alpha=0.7)
    
    ax1.set_title('🇮🇳 India GIS Model - Agent Distribution')
    ax1.set_xlabel('X Coordinate')
    ax1.set_ylabel('Y Coordinate')
    
    # Plot 2: Population statistics
    if model.datacollector.get_model_vars_dataframe().empty:
        ax2.text(0.5, 0.5, 'No data collected yet\\nRun simulation first', 
                ha='center', va='center', transform=ax2.transAxes)
    else:
        data = model.datacollector.get_model_vars_dataframe()
        data.plot(ax=ax2)
        ax2.set_title('📊 Population Over Time')
        ax2.set_xlabel('Step')
        ax2.set_ylabel('Number of People')
    
    plt.tight_layout()
    return fig

def run_simulation(steps=20):
    """Run the simulation"""
    print("🇮🇳 Starting India GIS Simulation...")
    
    # Create model
    model = IndiaGISModel(width=50, height=50, num_people=100)
    
    print(f"✅ Created model with {model.num_people} people")
    print(f"📊 States included: {', '.join(model.states_data.keys())}")
    
    # Run simulation
    for i in range(steps):
        model.step()
        if i % 5 == 0:
            print(f"📈 Step {i+1}/{steps} completed")
    
    print(f"🎉 Simulation completed! Total steps: {steps}")
    return model

def analyze_results(model):
    """Analyze and display simulation results"""
    print("\\n" + "="*50)
    print("📊 SIMULATION ANALYSIS")
    print("="*50)
    
    # Agent statistics
    total_agents = model.schedule.get_agent_count()
    print(f"👥 Total People: {total_agents}")
    
    # State distribution
    state_counts = {}
    for agent in model.schedule.agents:
        state = agent.current_state
        state_counts[state] = state_counts.get(state, 0) + 1
    
    print("\\n🏛️ PEOPLE BY STATE:")
    print("-" * 40)
    for state, count in state_counts.items():
        percentage = (count / total_agents) * 100
        print(f"{state}: {count} people ({percentage:.1f}%)")
    
    # Data collection results
    data = model.datacollector.get_model_vars_dataframe()
    if not data.empty:
        print("\\n📈 SIMULATION TRENDS:")
        print("-" * 40)
        print(data.describe())

def main():
    """Main execution function"""
    print("🚀 India GIS Model - Python Version (Mesa 3.2.0)")
    print("=" * 60)
    
    # Run simulation
    model = run_simulation(steps=20)
    
    # Analyze results
    analyze_results(model)
    
    # Create visualizations
    print("\\n🎨 Creating visualizations...")
    fig = visualize_model(model)
    
    # Save plots
    fig.savefig('india_gis_simulation.png', dpi=300, bbox_inches='tight')
    print("💾 Visualization saved as: india_gis_simulation.png")
    
    # Show plots
    plt.show()
    
    # Export data
    print("\\n📁 Exporting data...")
    data = model.datacollector.get_model_vars_dataframe()
    data.to_csv('simulation_data.csv', index=False)
    print("💾 Data exported to: simulation_data.csv")
    
    # Agent data
    agent_data = []
    for agent in model.schedule.agents:
        agent_data.append({
            'agent_id': agent.unique_id,
            'x': agent.pos[0],
            'y': agent.pos[1],
            'home_state': agent.home_state,
            'current_state': agent.current_state,
            'mobility_factor': agent.mobility_factor
        })
    
    df_agents = pd.DataFrame(agent_data)
    df_agents.to_csv('agent_data.csv', index=False)
    print("💾 Agent data exported to: agent_data.csv")
    
    print("\\n🎉 Simulation completed successfully!")
    print("📊 Check the generated PNG file and CSV data files")
    
    return model

if __name__ == "__main__":
    model = main()
