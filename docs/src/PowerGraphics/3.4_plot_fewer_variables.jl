using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# # How to plot only specific variables from the results

# See [How to set up plots](set_up_plots.md) to get started

# ## To plot only a couple of variables from the collected results:
# ### Define the variables to be plotted
variables = [:variable_1, :variable_2]
PG.stack_plot(results, variables)
PG.bar_plot(results, variables)

# This will plot all of the generators for the listed variables.

# ## To collect only a subset of variables and generators:

selected_variables = Dict(:variable_1 => [:generator_1, :generator_2],
                 :variable_2 => [:generator_1, :generator_2, :generator_3])

results_subset = PG.sort_data(results; Variables = selected_variables)

PG.stack_plot(results_subset)
PG.bar_plot(results_subset)

# PG.sort_data() creates a new results object only containing the subset of variables and generators listed in the dictionary.
# If the Variables key word argument is not called, the default for PG.sort_data() is to alphebatize the generators per variable.
