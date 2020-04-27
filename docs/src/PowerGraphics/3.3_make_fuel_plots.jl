# # How to Make a fuel plot

# See [How to set up plots](3.0_set_up_plots.md) to get started

# ### Define a system and solve for results

# use the [Power Simulations package](http://github.com/nrel/PowerSimulations.jl.git)

# to set a [Power Systems](http://github.com/nrel/PowerSystems.jl.git) system and solve a problem.

# ```julia
# using PowerGraphics
# using Plots
# using PlotlyJS
# using PowerSystems
# const PSY = PowerSystems
# const PG = PowerGraphics
# ```
# ### Make fuel plots of the results

# ```julia
# fuel_plot(results, system)
# ```
# ![this one](plots-13/Example_Fuel_Plot_Stack.png)
# ![this one](plots-13/Example_Fuel_Plot_Bar.png)

# ### Show reserves in the fuel plots

# ```julia
# fuel_plot(results, system; reserves = true)
# ```
# ![this one](plots-14/Example_Fuel_Plot_with_Reserves_Stack.png)
# ![this one](plots-14/Example_Fuel_Plot_with_Reserves_Bar.png)

# ### Set different colors for the plots

# ```julia
# colors = [:pink :green :blue :magenta :black]
# fuel_plot(results, system; seriescolor = colors)
# ```

# ![this one](plots-15/Example_Fuel_Plot_with_Other_Colors_Stack.png)
# ![this one](plots-15/Example_Fuel_Plot_with_Other_Colors_Bar.png)

# ### Set a title

# ```julia
# title = "Example of a Title"
# fuel_plot(results, system; title = title)
# ```

# ![this one](plots-16/Example_of_a_Title_Stack.png)
# ![this one](plots-16/Example_of_a_Title_Bar.png)

# ### For saving the plot with the PlotlyJS backend, you can set a different format for saving

# ```julia
# fuel_plot(results, system; save = path, format = "png")
# ```

# Default format for saving is html.
# Optional formats for saving include png, html, and svg.

# ## Alternatively, set up a dictionary of the desired sorting method using `make_fuel_dictionary()`

# For example, if the generators are to be sorted by a different method than the default fuels

# ```julia
# Categories = Dict{String, NamedTuple}(
#     "coal" => NamedTuple{(:primemover, :fuel)}, (PSY.PrimeMovers.ST, PSY.ThermalFuels.COAL),
#     "oil" =>  NamedTuple{(:primemover, :fuel)}, (PSY.PrimeMovers.ST, PSY.ThermalFuels.DISTILLATE_FUEL_OIL))
# generators = make_fuel_dictionary(results, system; Categories = Categories)
# fuel_plot(results, generators)
# ```
