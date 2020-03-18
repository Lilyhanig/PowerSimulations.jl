# # How to Make a fuel plot

# See [How to set up plots](set_up_plots.md) to get started

# ### Define a system and solve for results

# use the [Power Simulations package](http://github.com/nrel/PowerSimulations.jl.git)

# to set a [Power Systems](http://github.com/nrel/PowerSystems.jl.git) system and solve a problem.

using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# ### Make fuel plots of the results
#PG.fuel_plot(results, system)

# or set up a dictionary of the desired sorting method or use PG.make_fuel_dictionary()
PG.fuel_plot(results, generators)

# ### Save the fuel plots to a folder

file_path = "Users/Documents"
#PG.fuel_plot(results, system; save = file_path)

# ### Show reserves in the fuel plots

#PG.fuel_plot(results, system; reserves = true)

# ### Set different colors for the plots

colors = [:pink :green :blue :magenta :black]
#PG.fuel_plot(results, system; seriescolor = colors)
