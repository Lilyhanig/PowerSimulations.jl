# # How to Make a bar plot

# See [How to set up plots](3.0_set_up_plots.md) to get started

# ```julia
# using PowerGraphics
# using Plots
# using PlotlyJS
# const PG = PowerGraphics
# ```

# ### Make bar plots of results

# ```julia
# bar_plot(results)
# ```

# ![this one](plots-8/P__PowerSystems.ThermalStandard_Bar.png)
# ![this one](plots-8/Example_Bar_Plot.png)

# ### Save the bar plots to a folder

# ```julia
# folder_path = joinpath(file_path, "plots_1")
# if !isdir(folder_path)
#    mkdir(folder_path)
# end
# bar_plot(results; save = folder_path)
# ```

# ![this one](plots-9/P__PowerSystems.ThermalStandard_Bar.png)
# ![this one](plots-9/Example_saved_Bar_Plot.png)

# ### Show reserves in the bar plots

# ```julia
# bar_plot(results; reserves = true)
# ```

# ![this one](plots-10/P__PowerSystems.ThermalStandard_Bar.png)
# ![this one](plots-10/Example_Bar_Plot_with_Reserves.png)

# ### Set different colors for the plots

# ```julia
# colors = [:pink :green :blue :magenta :black]
# bar_plot(results; seriescolor = colors)
# ```

# ![this one](plots-11/P__PowerSystems.ThermalStandard_Bar.png)
# ![this one](plots-11/Example_Bar_Plot_with_Other_Colors.png)

# ### Set a title

# ```julia
# title = "Example of a Title"
# bar_plot(results; title = title)
# ```

# ![this one](plots-12/P__PowerSystems.ThermalStandard_Bar.png)
# ![this one](plots-12/Example_of_a_Title.png)

# ### For saving the plot with the PlotlyJS backend, you can set a different format for saving
# ```julia
# bar_plot(results; save = path, format = "png")
# ```
# Default format for saving is html.
# Optional formats for saving include png, html, and svg.
