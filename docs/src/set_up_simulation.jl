include("../../src/get_test_data.jl")
using PowerSimulations
using PowerSystems
using Dates
const PSY = PowerSystems
const PSI = PowerSimulations
#c_sys5_ed
system_ed = c_sys5_re
system_uc = c_sys5_re

branches = Dict()
services = Dict()
devices = Dict(
    :Generators => PSI.DeviceModel(ThermalStandard, PSI.ThermalBasicUnitCommitment),
    :Ren => PSI.DeviceModel(RenewableDispatch, PSI.RenewableFixed),
    :Loads => PSI.DeviceModel(PowerLoad, PSI.StaticPowerLoad),
    :ILoads => PSI.DeviceModel(InterruptibleLoad, PSI.StaticPowerLoad),
)
#=
template_basic_uc =
    PSI.OperationsProblemTemplate(CopperPlatePowerModel, devices, branches, services)

branches = Dict()
services = Dict()
devices = Dict(
    :Generators => PSI.DeviceModel(ThermalStandard, PSI.ThermalStandardUnitCommitment),
    :Ren => PSI.DeviceModel(RenewableDispatch, PSI.RenewableFixed),
    :Loads => PSI.DeviceModel(PowerLoad, PSI.StaticPowerLoad),
    :ILoads => PSI.DeviceModel(InterruptibleLoad, PSI.StaticPowerLoad),
)=#
template_uc =
    PSI.OperationsProblemTemplate(CopperPlatePowerModel, devices, branches, services)

## ED Model Ref
branches = Dict()
services = Dict()
devices = Dict(
    :Generators => PSI.DeviceModel(ThermalStandard, PSI.ThermalDispatchNoMin),
    :Ren => PSI.DeviceModel(RenewableDispatch, PSI.RenewableFullDispatch),
    :Loads => PSI.DeviceModel(PowerLoad, PSI.StaticPowerLoad),
    :ILoads => PSI.DeviceModel(InterruptibleLoad, PSI.DispatchablePowerLoad),
)
template_ed =
    PSI.OperationsProblemTemplate(CopperPlatePowerModel, devices, branches, services)

# Define a template

stages_definition = Dict(
    "UC" => PSI.Stage(TestOpProblem, template_uc, system_uc, Cbc_optimizer),
    "ED" => PSI.Stage(TestOpProblem, template_ed, system_ed, Cbc_optimizer),
)

sequence = PSI.SimulationSequence(
    order = Dict(1 => "UC", 2 => "ED"),
    step_resolution = Hour(1),
    feedforward_chronologies = Dict(("UC" => "ED") => PSI.RecedingHorizon()),
    horizons = Dict("UC" => 24, "ED" => 12),
    intervals = Dict(
        "UC" => (Hour(1), PSI.RecedingHorizon()),
        "ED" => (Minute(5), PSI.RecedingHorizon()),
    ),
    feedforward = Dict(
        ("ED", :devices, :Generators) => PSI.SemiContinuousFF(
            binary_from_stage = PSI.ON,
            affected_variables = [PSI.ACTIVE_POWER],
        ),
    ),
    ini_cond_chronology = PSI.IntraStageChronology(),
)
file_path = "/Users/lhanig/Downloads/Documentation"
if !isdir(file_path)
    mkdir(file_path)
end
simulation = PSI.Simulation(
    name = "testing",
    steps = 2,
    stages = stages_definition,
    stages_sequence = sequence,
    simulation_folder = file_path,
)
PSI.build!(simulation)
simulation_output = execute!(simulation)
results = PSI.load_simulation_results(simulation_output, "UC");