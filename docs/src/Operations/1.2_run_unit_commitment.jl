# # How to Run a Unit Commitment problem

# See [How to set up operations](1.0_set_up_operations.md) to get started and to set up a system.
using PowerSystems;
using PowerSimulations;
include("../../src/get_test_data.jl");
const PSY = PowerSystems;
const PSI = PowerSimulations;
system = c_sys5;

# Set an optimizer, such as
# ```julia
# using JuMP
# using GLPK
# solver = JuMP.optimizer_with_attributes(GLPK.Optimizer)
# ```

# ### Run an economic dispatch problem on your system.

results = PSI.run_unit_commitment(system; optimizer = solver)

# ### The default settings for the template can be overrode
# for a more customized formulation, define the branches, services, or devices to be injected

branch = Dict(:line => PSI.DeviceModel(PSY.Line, PSI.StaticLine))
results = PSI.run_unit_commitment(system; branches = branch, optimizer = solver)

# Key word arguments include `branches`, `services`, and `devices`