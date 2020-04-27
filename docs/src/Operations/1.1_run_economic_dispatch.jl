# # How to Run an Economic Dispatch problem

# See [How to set up operations](1.0_set_up_operations.md) to get started and to set up a system.
# ```julia
# using PowerSystems
# using PowerSimulations
# const PSY = PowerSystems
# const PSI = PowerSimulations
# ```
include("../../src/get_test_data.jl");
# ### Define an optimizer
# ```julia
# using JuMP
# using GLPK
# solver = JuMP.optimizer_with_attributes(GLPK.Optimizer)
# ```
# ### Run an economic dispatch problem on your system

results = PSI.run_economic_dispatch(system; optimizer = solver)

# ### The default settings for the template can be overrode
# for a more customized formulation, define the branches, services, or devices to be injected

branch = Dict(:line => DeviceModel(PSY.Line, PSI.StaticLine))
results = PSI.run_economic_dispatch(system; branches = branch, optimizer = solver)

# Key word arguments include `branches`, `services`, and `devices`