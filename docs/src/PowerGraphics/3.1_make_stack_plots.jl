# # How to Make a stack plot

# See [How to set up plots](3.0_set_up_plots.md) to get started

# ```julia
# using PowerGraphics
# using Plots
# using PlotlyJS
# const PG = PowerGraphics
# ```

# ### Make stack plots of results

# ```julia
# stack_plot(results)
# ```

# ![this one](plots-3/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-3/Example_Stack_Plot.png)

# ### Save the stack plots to a folder

# ```julia
# folder_path = joinpath(file_path, "plots_1")
# if !isdir(folder_path)
#    mkdir(folder_path)
# end
# stack_plot(results; save = folder_path)
# ```

# ![this one](plots-4/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-4/Example_saved_Stack_Plot.png)

# ### Show reserves in the stack plots

# ```julia
# stack_plot(results; reserves = true)
# ```
# ![this one](plots-5/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-5/Example_Stack_Plot_with_Reserves.png)

# ### Set different colors for the plots

# ```julia
# colors = [:pink :green :blue :magenta :black]
# stack_plot(results; seriescolor = colors)
# ```
# ![this one](plots-6/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-6/Example_Stack_Plot_with_Other_Colors.png)

# ### Set a title

# ```julia
# title = "Example of a Title"
# stack_plot(results; title = title)
# ```
# ![this one](plots-7/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-7/Example_of_a_Title.png)

# ### For saving the plot with the PlotlyJS backend, you can set a different format for saving
# ```julia
# stack_plot(results; save = path, format = "png")
# ```
# Default format for saving is html.
# Optional formats for saving include png, html, and svg.
