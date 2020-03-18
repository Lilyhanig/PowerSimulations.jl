using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# # How to plot multiple results in subplots for comparisons

# See [How to set up plots](set_up_plots.md) to get started

# ### Run the simulation and get various results

results_one = results
results_two = results

# ### Plot the results as an array

PG.stack_plot([results_one, results_two])

# or

PG.fuel_plot([results_one, results_two], generators)