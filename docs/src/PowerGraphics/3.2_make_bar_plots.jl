# # How to Make a bar plot

# See [How to set up plots](set_up_plots.md) to get started

using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# ### Make bar plots of results
PG.bar_plot(results)

# ### Save the bar plots to a folder

file_path = "Users/Documents"
PG.bar_plot(results; save = file_path)

# ### Show reserves in the bar plots

PG.bar_plot(results; reserves = true)

# ### Set different colors for the plots

colors = [:pink :green :blue :magenta :black]
PG.bar_plot(results; seriescolor = colors)
