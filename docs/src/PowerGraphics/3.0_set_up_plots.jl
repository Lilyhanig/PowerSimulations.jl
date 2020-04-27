# # Getting Started with Power Graphics

# This uses the plotting package for SIIP [PowerGraphics](http://github.com/nrel-siip/PowerGraphics.jl.git))

# Start by creating a results object using [PowerSimulations](http://github.com/nrel-siip/PowerSimulations.jl.git)

# Set up Power Graphics:
# ```julia
# import PowerGraphics
# using Plots
# using PlotlyJS
# const PG = PowerGraphics
# ```

# ## To make a simple GR() backend plot (static plot), simply call

# ```julia
# stack_plot(results)
# ```

# ![this one](plots-1/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-1/Example_GR_Plot.png)

# ## To make an interactive PlotlyJS plot, reset the backend

# ```julia
# Plots.plotlyjs()

# stack_plot(results)
# ```
# ![this one](plots-2/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-2/Example_PlotlyJS_Plot.png)
