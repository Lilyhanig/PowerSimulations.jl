# # How to plot only specific variables from the results

# See [How to set up plots](3.0_set_up_plots.md) to get started

# ## To plot only a couple of variables from the collected results:
# ### Define the variables to be plotted

# ```julia
# variables = [Symbol("P__PowerSystems.ThermalStandard"), Symbol("P__PowerSystems.RenewableDispatch")]
# stack_plot(results, variables)
# ```

# ![this one](plots-17/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-17/P__PowerSystems.RenewableDispatch_Stack.png)
# ![this one](plots-17/Plot_with_Fewer_Variables.png)

# This will plot all of the generators for the listed variables.

# ## To collect only a subset of variables and generators:

# ```julia
# selected_variables = Dict(
#    Symbol("P__PowerSystems.ThermalStandard") => [:Brighton, :Solitude],
#    Symbol("P__PowerSystems.RenewableDispatch") => [:windbusA, :windbusC],
# )
# results_subset = PG.sort_data(results; Variables = selected_variables)
# stack_plot(results_subset)
# ```

# ![this one](plots-18/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-18/P__PowerSystems.RenewableDispatch_Stack.png)
# ![this one](plots-18/Selected_Variables_Plot.png)

# `sort_data()` creates a new results object only containing the subset of variables and generators listed in the dictionary.
# If the Variables key word argument is not called, the default for `sort_data()` is to alphebatize the generators per variable.
