# # How to plot multiple results in subplots for comparisons

# See [How to set up plots](3.0_set_up_plots.md) to get started

# ### Run the simulation and get various results

# ### Plot the results as an array

# ```julia
# stack_plot([results_one, results_two])
# ```

# ![this one](plots-19/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-19/P__PowerSystems.RenewableDispatch_Stack.png)
# ![this one](plots-19/Comparison.png)

# ### Plot by Fuel Type

# ```julia
# fuel_plot([results_one, results_two], c_sys5_re)
# ```

# ![this one](plots-20/Comparison_Stack.png)
# ![this one](plots-20/Comparison_Bar.png)

# ## Multiple results can be compared while also plotting fewer variables

# ```julia
# variables = [Symbol("P__PowerSystems.RenewableDispatch")]
# stack_plot([results_one, results_two], variables)
# ```

# ![this one](plots-21/P__PowerSystems.ThermalStandard_Stack.png)
# ![this one](plots-21/P__PowerSystems.RenewableDispatch_Stack.png)
# ![this one](plots-21/Comparison_with_fewer_variables.png)
