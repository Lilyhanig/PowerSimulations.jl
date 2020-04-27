# # Getting Started with Power Simulations

# This is the Power Simulations package for SIIP.

# Start by creating a system using [Power Systems](http://github.com/nrel/PowerSystems.jl.git)

# See [How to set up a simulation](2.0_set_up_simulation.md) to set up and run the simulation
include("../set_up_simulation.jl");
# ```julia
# simulation_output = PSI.execute!(simulation)
# ```
# ## Load results from the simulation
# ### Load all of the results for a stage in the simulation
results = load_simulation_results(simulation_output, "UC")

# ### Load a specific subset of results for a stage
# select the specific steps and variables that are desired for the results

steps = ["step-1", "step-2", "step-3"]
variables = [Symbol("P__PowerSystems.ThermalStandard")]
results = load_simulation_results(simulation_output, "UC", steps, variables)

# ### If you no longer have the simulation object in memory
# Find the folder path to the dated folder that contains the raw results.
# For example, `file_path = "Downloads/simulations/2020-01-01T12:01:00"`

path = dirname("$(simulation_output.results_folder)");
# To load all of the results for a stage in the simulation
results = PSI.load_simulation_results(path, "UC")

# To load the results for a specific subset of steps and variables for a stage

steps = ["step-1", "step-2", "step-3"]
variables = [Symbol("P__PowerSystems.ThermalStandard")]
results = PSI.load_simulation_results(path, "UC", steps, variables)

# ### Plotting
# Documentation for plotting can be found at [Plots](3.0_set_up_plots.md)
# The plotting package for SIIP can be found at [Power Graphics](http://github.com/nrel-siip/PowerGraphics.jl.git)
