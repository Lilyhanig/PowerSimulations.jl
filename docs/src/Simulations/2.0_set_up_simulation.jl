# # How to set up a Sequential Simulation

# This is the Power Simulations package for SIIP.
# To run through a sequential simulations tutorial see [SIIP Examples](http://github.com/nrel-siip/PowerSystems.jl.git/notebook/PowerSimulations_examples)
# ```julia
# using PowerSimulations
# using PowerSystems
# using Dates
# const PSY = PowerSystems
# const PSI = PowerSimulations
# ```
include("../../src/get_test_data.jl");
# Start by creating a system using [Power Systems](http://github.com/nrel/PowerSystems.jl.git)
system_ed = c_sys5_ed;
system_uc = c_sys5_uc;

# ### Define the templates for each stage

# ### Unit Commitment template
devices = Dict(
    :Generators => DeviceModel(ThermalStandard, ThermalStandardUnitCommitment),
    :Ren => DeviceModel(RenewableDispatch, RenewableFullDispatch),
    :Loads => DeviceModel(PowerLoad, StaticPowerLoad),
    :HydroROR => DeviceModel(HydroDispatch, HydroDispatchRunOfRiver),
    :RenFx => DeviceModel(RenewableFix, RenewableFixed),
)
template_uc = template_unit_commitment(devices = devices)

# ### Economic Dispatch template
devices = Dict(
    :Generators => DeviceModel(ThermalStandard, ThermalDispatch),
    :Ren => DeviceModel(RenewableDispatch, RenewableFullDispatch),
    :Loads => DeviceModel(PowerLoad, StaticPowerLoad),
    :HydroROR => DeviceModel(HydroDispatch, HydroDispatchRunOfRiver),
    :RenFx => DeviceModel(RenewableFix, RenewableFixed),
)

template_ed = template_economic_dispatch(devices = devices)

# ### Define the stages
stages_definition = Dict(
    "UC" => PSI.Stage(TestOpProblem, template_uc, system_uc, Cbc_optimizer),
    "ED" => PSI.Stage(TestOpProblem, template_ed, system_ed, Cbc_optimizer),
)

# ### Define the Sequence
sequence = PSI.SimulationSequence(
    order = Dict(1 => "UC", 2 => "ED"),
    step_resolution = Hour(1),
    feedforward_chronologies = Dict(("UC" => "ED") => Synchronize(periods = 24)),
    horizons = Dict("UC" => 24, "ED" => 12),
    intervals = Dict(
        "UC" => (Hour(1), Consecutive()),
        "ED" => (Minute(5), Consecutive()),
    ),
    feedforward = Dict(
        ("ED", :devices, :Generators) => PSI.SemiContinuousFF(
            binary_from_stage = PSI.ON,
            affected_variables = [PSI.ACTIVE_POWER],
        ),
    ),
    ini_cond_chronology = PSI.InterStageChronology(),
    cache = Dict(("UC",) => TimeStatusChange(PSY.ThermalStandard, PSI.ON)),
)
# ### Set up the simulation
simulation = Simulation(
    name = "example",
    steps = 2,
    stages = stages_definition,
    stages_sequence = sequence,
    simulation_folder = file_path,
)
# ### Build the Simulation Problem
build!(simulation)

# ### Execute the Simulation
# ```julia
# simulation_output = execute!(simulation)
# ```

# Results Extraction
# See [How to load results](2.1_load_results.md)

# ### Plotting
# Documentation for plotting can be found at [Plots](3.0_set_up_plots.md)
# The plotting package for SIIP can be found at [Power Graphics](http://github.com/nrel-siip/PowerGraphics.jl.git)
