# # Getting Started with Power Graphics

# This is the plotting package for SIIP.

# Start by creating a results object using the [PowerSimulations package](http://github.com/nrel/PowerSimulations.jl.git)

# Set up Power Graphics:

import PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# To make a simple GR() backend plot (static plot), simply call

PG.stack_plot(results)

# To make an interactive PlotlyJS plot, reset the backend

plotlyjs()
PG.stack_plot(results)
