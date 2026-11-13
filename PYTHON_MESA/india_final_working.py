"""
WORKING India GIS Model - Python Version
Simple agent-based model that definitely works in VS Code
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import random

class Person:
    """A person agent representing population in Indian states"""
    
    def __init__(self, unique_id, model, home_state):
        self.unique_id = unique_id
        self.model = model
        self.home_state = home_state
        self.mobility_factor = random.random()
        self.current_state = home_state
        self.pos = (0, 0)
        
    def step(self):
        """Agent behavior - simple random movement"""
        x, y = self.pos
        
        # Random movement
        dx = random.randint(-1, 1)
        dy = random.randint(-1, 1)
        
        new_x = max(0, min(self.model.width - 1, x + dx))
        new_y = max(0, min(self.model.height - 1, y + dy))
        
        # Update position
        self.pos = (new_x, new_y)
        
        # Update current state based on new position
        self.current_state = self.model.get_state_at_position(new_x, new_y)

class IndiaGISModel:
    """Main model class for India GIS simulation"""
    
    def __init__(self, width=50, height=50, num_people=100):
        # Model parameters
        self.width = width
        self.height = height
        self.num_people = num_people
        
        # Initialize state data
        self.states_data = self._create_states_data()
        self.state_boundaries = self._create_state_boundaries()
        
        # Create people
        self.people_agents = []
        self._create_people()
        
        # Step counter
        self.step_count = 0
        
        # Data storage
        self.data_history = []
        
    def _create_states_data(self):
        """Create Indian states data"""
        return {
            "Maharashtra": {"population": 112374333, "color": "red", "region": (5, 20, 10, 25)},
            "Karnataka": {"population": 61095297, "color": "green", "region": (10, 25, 5, 20)},
            "Tamil Nadu": {"population": 72147030, "color": "blue", "region": (15, 30, 0, 15)},
            "Kerala": {"population": 33406061, "color": "yellow", "region": (12, 22, 0, 10)},
            "Gujarat": {"population": 60439692, "color": "cyan", "region": (0, 15, 20, 35)},
            "Rajasthan": {"population": 68548437, "color": "magenta", "region": (5, 20, 25, 40)},
            "Uttar Pradesh": {"population": 199812341, "color": "gray", "region": (20, 35, 25, 40)},
            "West Bengal": {"population": 91276115, "color": "purple", "region": (30, 45, 20, 35)},
            "Delhi": {"population": 16787941, "color": "orange", "region": (25, 30, 35, 40)},
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
            # Choose random state weighted by population
            states = list(self.states_data.keys())
            weights = [self.states_data[state]["population"] for state in states]
            state = random.choices(states, weights=weights)[0]
            
            # Create person
            person = Person(i, self, state)
            
            # Place in state region
            region = self.states_data[state]["region"]
            x = random.randint(region[0], min(region[1], self.width - 1))
            y = random.randint(region[2], min(region[3], self.height - 1))
            
            person.pos = (x, y)
            self.people_agents.append(person)
    
    def step(self):
        """Advance the model by one step"""
        # Move all agents
        for agent in self.people_agents:
            agent.step()
        
        # Collect data
        self._collect_data()
        
        self.step_count += 1
        
    def _collect_data(self):
        """Collect simulation data"""
        # Count people by state
        state_counts = {}
        for agent in self.people_agents:
            state = agent.current_state
            state_counts[state] = state_counts.get(state, 0) + 1
        
        # Store data
        data_point = {
            "step": self.step_count,
            "total_people": len(self.people_agents),
            **state_counts
        }
        self.data_history.append(data_point)
        
    def get_state_at_position(self, x, y):
        """Get state name at position"""
        for state, bounds in self.state_boundaries.items():
            if (bounds["x_min"] <= x <= bounds["x_max"] and 
                bounds["y_min"] <= y <= bounds["y_max"]):
                return state
        return "Unknown"
    
    def get_data_frame(self):
        """Get simulation data as DataFrame"""
        return pd.DataFrame(self.data_history)

def visualize_model(model):
    """Create visualization of the model"""
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    fig.suptitle('India GIS Model - Agent-Based Simulation', fontsize=16, fontweight='bold')
    
    # Plot 1: Current state map with agents
    ax1 = axes[0, 0]
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
            edgecolor='black',
            linewidth=1
        )
        ax1.add_patch(rect)
        
        # Add state label
        center_x = (bounds["x_min"] + bounds["x_max"]) / 2
        center_y = (bounds["y_min"] + bounds["y_max"]) / 2
        ax1.text(center_x, center_y, state, ha='center', va='center', fontsize=6, fontweight='bold')
    
    # Plot agents
    for agent in model.people_agents:
        x, y = agent.pos
        ax1.scatter(x, y, c='blue', s=20, alpha=0.8, edgecolors='white', linewidth=0.5)
    
    ax1.set_title('People Distribution Across Indian States')
    ax1.set_xlabel('X Coordinate')
    ax1.set_ylabel('Y Coordinate')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Population by state (current)
    ax2 = axes[0, 1]
    state_counts = {}
    for agent in model.people_agents:
        state = agent.current_state
        state_counts[state] = state_counts.get(state, 0) + 1
    
    if state_counts:
        # Sort by population
        sorted_states = sorted(state_counts.items(), key=lambda x: x[1], reverse=True)
        states = [item[0] for item in sorted_states]
        counts = [item[1] for item in sorted_states]
        colors = [model.state_boundaries.get(state, {"color": "lightgray"})["color"] for state in states]
        
        bars = ax2.bar(range(len(states)), counts, color=colors, alpha=0.7, edgecolor='black')
        ax2.set_xticks(range(len(states)))
        ax2.set_xticklabels(states, rotation=45, ha='right')
        ax2.set_title('Current Population by State')
        ax2.set_ylabel('Number of People')
        
        # Add value labels on bars
        for bar, count in zip(bars, counts):
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                    f'{count}', ha='center', va='bottom', fontsize=8)
    
    # Plot 3: Population changes over time
    ax3 = axes[1, 0]
    if model.data_history:
        df = model.get_data_frame()
        
        # Plot major states over time
        major_states = ['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Uttar Pradesh', 'West Bengal']
        for state in major_states:
            if state in df.columns:
                values = df[state].fillna(0)
                ax3.plot(df['step'], values, label=state, linewidth=2, marker='o', markersize=4)
        
        ax3.set_title('Population Movement Over Time')
        ax3.set_xlabel('Simulation Step')
        ax3.set_ylabel('Number of People')
        ax3.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
        ax3.grid(True, alpha=0.3)
    else:
        ax3.text(0.5, 0.5, 'No data available\\nRun simulation first', 
                ha='center', va='center', transform=ax3.transAxes, fontsize=12)
        ax3.set_title('Population Movement Over Time')
    
    # Plot 4: Mobility analysis
    ax4 = axes[1, 1]
    mobility_data = [agent.mobility_factor for agent in model.people_agents]
    
    # Create histogram
    ax4.hist(mobility_data, bins=20, alpha=0.7, color='skyblue', edgecolor='black')
    ax4.axvline(np.mean(mobility_data), color='red', linestyle='--', linewidth=2, 
               label=f'Mean: {np.mean(mobility_data):.2f}')
    ax4.set_title('Mobility Factor Distribution')
    ax4.set_xlabel('Mobility Factor')
    ax4.set_ylabel('Number of People')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig

def run_simulation(steps=30):
    """Run the simulation"""
    print("Starting India GIS Simulation...")
    
    # Create model
    model = IndiaGISModel(width=50, height=50, num_people=150)
    
    print(f"Created model with {model.num_people} people")
    print(f"States included: {len(model.states_data)} states")
    print(f"Grid size: {model.width} x {model.height}")
    
    # Initial state distribution
    initial_counts = {}
    for agent in model.people_agents:
        state = agent.current_state
        initial_counts[state] = initial_counts.get(state, 0) + 1
    
    print(f"\\n Initial distribution:")
    for state, count in sorted(initial_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"{state}: {count} people")
    
    # Run simulation
    print(f"\\n Running simulation for {steps} steps...")
    for i in range(steps):
        model.step()
        if i % 10 == 0:
            print(f"Step {i+1}/{steps} completed")
    
    print(f"Simulation completed! Total steps: {steps}")
    return model

def analyze_results(model):
    """Analyze and display simulation results"""
    print("\\n" + "="*60)
    print("SIMULATION ANALYSIS")
    print("="*60)
    
    # Agent statistics
    total_agents = len(model.people_agents)
    print(f"Total People: {total_agents}")
    print(f"Simulation Steps: {model.step_count}")
    
    # Final state distribution
    final_counts = {}
    for agent in model.people_agents:
        state = agent.current_state
        final_counts[state] = final_counts.get(state, 0) + 1
    
    print("\\n FINAL POPULATION BY STATE:")
    print("-" * 50)
    for state, count in sorted(final_counts.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / total_agents) * 100
        print(f"{state:15}: {count:3d} people ({percentage:5.1f}%)")
    
    # Mobility analysis
    mobility_data = [agent.mobility_factor for agent in model.people_agents]
    high_mobility = sum(1 for x in mobility_data if x > 0.7)
    low_mobility = sum(1 for x in mobility_data if x < 0.3)
    
    print(f"\\n MOBILITY ANALYSIS:")
    print("-" * 50)
    print(f"High mobility (>0.7): {high_mobility} people ({high_mobility/total_agents*100:.1f}%)")
    print(f"Low mobility (<0.3): {low_mobility} people ({low_mobility/total_agents*100:.1f}%)")
    print(f"Average mobility: {np.mean(mobility_data):.2f}")
    
    # Movement analysis
    if model.data_history:
        df = model.get_data_frame()
        print(f"\\n DATA COLLECTION:")
        print("-" * 50)
        print(f"Data points collected: {len(df)}")
        
        # Show population changes
        if len(df) > 1:
            first_step = df.iloc[0]
            last_step = df.iloc[-1]
            
            print(f"\\n POPULATION CHANGES:")
            print("-" * 50)
            for state in model.states_data.keys():
                if state in first_step and state in last_step:
                    initial = first_step[state] if pd.notna(first_step[state]) else 0
                    final = last_step[state] if pd.notna(last_step[state]) else 0
                    change = final - initial
                    if change != 0:
                        print(f"{state}: {int(change):+d} people")

def main():
    """Main execution function"""
    print("India GIS Model - Python Version (WORKING!)")
    print("=" * 60)
    
    # Run simulation
    model = run_simulation(steps=40)
    
    # Analyze results
    analyze_results(model)
    
    # Create visualizations
    print("\\n Creating visualizations...")
    fig = visualize_model(model)
    
    # Save plots
    fig.savefig('india_gis_simulation.png', dpi=300, bbox_inches='tight')
    print("Visualization saved as: india_gis_simulation.png")
    
    # Show plots
    plt.show()
    
    # Export data
    print("\\n Exporting data...")
    
    # Simulation data
    df = model.get_data_frame()
    df.to_csv('simulation_data.csv', index=False)
    print("Simulation data exported to: simulation_data.csv")
    
    # Agent data
    agent_data = []
    for agent in model.people_agents:
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
    print("Agent data exported to: agent_data.csv")
    
    print("\\n SUCCESS! Simulation completed successfully!")
    print("Files created:")
    print("india_gis_simulation.png - Beautiful visualization")
    print("simulation_data.csv - Time series data")
    print("agent_data.csv - Individual agent information")
    
    print("\\n This demonstrates NetLogo-style modeling in Python!")
    print("Advantages:")
    print("• No NetLogo installation needed")
    print("• Runs directly in VS Code")
    print("• Full Python data science capabilities")
    print("• Better visualizations and analysis")
    print("• Easy to extend and modify")
    print("• Can integrate with other Python libraries")
    
    return model

if __name__ == "__main__":
    model = main()
