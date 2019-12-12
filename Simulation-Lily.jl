activate ../.julia/dev/PowerSimulations/


instantiate
using PowerSystems
using PowerSimulations
const PSY = PowerSystems
const PSI = PowerSimulations
#using Xpress
using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
Pkg.add("Ipopt")
using GLPK
using JuMP
using Ipopt
using Dates

Xpress_optimizer = JuMP.with_optimizer(GLPK.Optimizer)

RTSDIR = "/Users/lhanig/.julia/dev/RTS-GMLC/RTS_Data/SourceData/."

rts_data = PSY.PowerSystemTableData(RTSDIR, 
    100.0, joinpath(RTSDIR,"../FormattedData/SIIP/user_descriptors.yaml"))

 sys_DA = System(rts_data; forecast_resolution = Dates.Hour(1))

 sys_RT = System(rts_data; forecast_resolution = Dates.Minute(5))

# print(summary(sys_DA))

get_forecast_initial_times(sys_DA)

split_forecasts!(sys_DA, 
    get_forecasts(Deterministic, sys_DA, Dates.DateTime("2020-01-01T00:00:00")),
    Dates.Hour(24),
    48)

get_forecast_initial_times(sys_DA)

print(summary(sys_DA))

split_forecasts!(sys_RT, 
    get_forecasts(Deterministic, sys_RT, Dates.DateTime("2020-01-01T00:00:00")),
    Dates.Minute(5),
    12)


branches = Dict{Symbol, DeviceModel}(#:L => DeviceModel(PSY.Line, PSI.StaticLine),
#:T => DeviceModel(PSY.Transformer2W, PSI.StaticTransformer),
#:TT => DeviceModel(PSY.TapTransformer, PSI.StaticTransformer),
#:dc_line => DeviceModel(PSY.HVDCLine, PSI.HVDCDispatch)
)

services = Dict{Symbol, PSI.ServiceModel}()

devices = Dict{Symbol, DeviceModel}(:Generators => DeviceModel(PSY.ThermalStandard, PSI.ThermalBasicUnitCommitment),
   :Ren => DeviceModel(PSY.RenewableDispatch, PSI.RenewableFullDispatch),
   :Loads =>  DeviceModel(PSY.PowerLoad, PSI.StaticPowerLoad),
   #:ILoads =>  DeviceModel(PSY.InterruptibleLoad, PSI.StaticPowerLoad),
   )       


model_ref_uc= OperationsTemplate(CopperPlatePowerModel, devices, branches, services);

## ED Model Ref
branches = Dict{Symbol, DeviceModel}(#:L => DeviceModel(PSY.Line, PSI.StaticLine),
                                     #:T => DeviceModel(PSY.Transformer2W, PSI.StaticTransformer),
                                     #:TT => DeviceModel(PSY.TapTransformer, PSI.StaticTransformer),
                                     #:dc_line => DeviceModel(PSY.HVDCLine, PSI.HVDCDispatch)
                                        )

services = Dict{Symbol, PSI.ServiceModel}()

devices = Dict{Symbol, DeviceModel}(:Generators => DeviceModel(PSY.ThermalStandard, PSI.ThermalDispatch, SemiContinuousFF(:P, :ON)),
                                    :Ren => DeviceModel(PSY.RenewableDispatch, PSI.RenewableFullDispatch),
                                    :Loads =>  DeviceModel(PSY.PowerLoad, PSI.StaticPowerLoad),
                                    #:ILoads =>  DeviceModel(PSY.InterruptibleLoad, PSI.DispatchablePowerLoad),
                                    )       

model_ref_ed= OperationsTemplate(CopperPlatePowerModel, devices, branches, services);

stages = Dict(1 => Stage(model_ref_uc, 1, sys_DA, Xpress_optimizer),
              2 => Stage(model_ref_ed, 24, sys_RT, Xpress_optimizer,  Dict(1 => Synchronize)))



sim = Simulation("test2", 7, stages, "/Users/lhanig/Downloads/"; verbose = true, system_to_file = false)


#####################

references = run_sim_model!(sim)

Pkg.add("FeatherFiles")
using Feather
using Dates
using DataFrames
date_range = (Dates.DateTime(2020, January, 1):Dates.Hour(24):Dates.DateTime(2020, January, 4))
stage = "stage-1"
step = ["step-1","step-2","step-3","step-4"]
variable = [:P_ThermalStandard, :ON_ThermalStandard, :START_ThermalStandard]

results = load_simulation_results(stage,step, date_range, variable, references)

using Plots
using RecipesBase
gr()
bar_plot(results)
stack_plot(results)

######
