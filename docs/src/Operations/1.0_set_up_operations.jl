
# # Getting Started with Power Simulations

# This is the Power Simulations package for SIIP.

# PowerSimulations.jl supports the construction and solution of optimal power system scheduling problems (Operations Problems). Operations problems form the fundamental building blocks for [sequential simulations](2.0_set_up_simulation.md).

# To run through an operations tutorial see [SIIP Examples](http://github.com/nrel-siip/PowerSystems.jl.git/notebook/PowerSimulations_examples)

# Start by creating a system using [Power Systems](http://github.com/nrel-siip/PowerSystems.jl.git)
# ```julia
# using PowerSimulations
# const PSI = PowerSimulations
# ```
include("../../src/get_test_data.jl");

# ### Create a Branch Formulation
# This is a relatively standard branch formulation
# ```julia
# branches = Dict{Symbol, DeviceModel}(
#     :L => DeviceModel(Line, StaticLine),
#     :T => DeviceModel(Transformer2W, StaticTransformer),
#     :TT => DeviceModel(TapTransformer, StaticTransformer),
# )
# ```
# ### Inject Device Formulations
# ```julia
# devices = Dict{Symbol, DeviceModel}(
#     :Generators => DeviceModel(ThermalStandard, ThermalDispatch),
#     :Loads => DeviceModel(PowerLoad, StaticPowerLoad),
# )
# ```
# Set up services
# ```julia
# services = Dict{Symbol, ServiceModel}(:ReserveUp => ServiceModel(VariableReserve{ReserveUp}, RangeReserve),
#                                       :ReserveDown => ServiceModel(VariableReserve{ReserveDown}, RangeReserve))
# ```
# ### Create a Problem Template
template = OperationsProblemTemplate(CopperPlatePowerModel, devices, branches, services)


# ### Define an optimizer
# ```julia
# solver = optimizer_with_attributes(GLPK.optimizer, "msg_lev" => GLPK.MSG_OFF)
# ```
# ### Combine the System and Template to build an operations problem
operations_problem = OperationsProblem(TestOpProblem, template, system; optimizer = solver)

# ### Solve an Operations Problem

results = solve!(operations_problem)

# ### Inspect results
# several functions exist to look at specific components
variable_values = get_variables(results)

# others include
# ```julia
# get_total_cost()
# get_time_stamp()
# get_optimizer_log()
# get_parameters()
# ```

# ### Plotting
# Documentation for plotting can be found at [Plots](3.0_set_up_plots.md)
# The plotting package for SIIP can be found at [Power Graphics](http://github.com/nrel-siip/PowerGraphics.jl.git)
