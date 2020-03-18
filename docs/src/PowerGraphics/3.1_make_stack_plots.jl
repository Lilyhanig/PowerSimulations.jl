# # How to Make a stack plot

# See [How to set up plots](set_up_plots.md) to get started

using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# ### Make stack plots of results
PG.stack_plot(results)

# ### Save the stack plots to a folder

file_path = "Users/Documents"
PG.stack_plot(results; save = file_path)

# ### Show reserves in the stack plots

PG.stack_plot(results; reserves = true)

# ### Set different colors for the plots

colors = [:pink :green :blue :magenta :black]
PG.stack_plot(results; seriescolor = colors)
