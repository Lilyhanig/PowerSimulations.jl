; cd "/Users/lhanig/.julia/dev/PowerSimulations"

using Pkg


 Pkg.instantiate()
 Pkg.activate()
 Pkg.build()

import PowerSystems
const PSY = PowerSystems

using JuMP
using Ipopt
Pkg.add("GLPK")
using GLPK
using BenchmarkTools
#using TimerOutput
  # using Gurobi
using OSQP
using Dates
using DataFrames
using ParameterJuMP
# using Xpress
using Test
const PJ = ParameterJuMP
import PowerModels
const PM = PowerModels
ipopt_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 4)
GLPK_optimizer = with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL)
OSQP_optimizer = JuMP.with_optimizer(OSQP.Optimizer)

# Xpress_optimizer = JuMP.with_optimizer(Xpress.Optimizer)
using Requires
using PowerSimulations
const PSI = PowerSimulations
using MathOptInterface
abstract type TestOptModel <: PSI.AbstractOperationModel end

#Creating Data Directory
base_dir = dirname(dirname(pathof(PowerSystems)));
include(joinpath(base_dir,"data/data_14bus_pu.jl"));
include(joinpath(base_dir,"data/data_5bus_pu.jl"));
DATA_DIR = joinpath(base_dir, "data")
RTS_GMLC_DIR = joinpath(DATA_DIR, "RTS_GMLC")

#Base Systems
c_sys5 = PSY.System(nodes5, thermal_generators5, loads5, branches5, nothing, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys5, load_forecast_DA)
c_sys14 = PSY.System(nodes14, thermal_generators14, loads14, branches14, nothing, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys14, forecast_DA14)
PTDF5 = PSY.PTDF(branches5, nodes5);
PTDF14 = PSY.PTDF(branches14, nodes14);

#System with Renewable Energy
c_sys5_re = PSY.System(nodes5, vcat(thermal_generators5, renewable_generators5), loads5, branches5, nothing, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys5_re, ren_forecast_DA)
add_forecasts!(c_sys5_re, load_forecast_DA)
c_sys5_re_only = PSY.System(nodes5, renewable_generators5, loads5, branches5, nothing, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys5_re_only, ren_forecast_DA)

#System with Storage Device
c_sys5_bat = PSY.System(nodes5, thermal_generators5, loads5, branches5, battery5, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys5_bat, load_forecast_DA)
#Systems with HVDC data in the branches
c_sys5_dc = PSY.System(nodes5, thermal_generators5, loads5, branches5_dc, nothing, 100.0, nothing, nothing, nothing);
add_forecasts!(c_sys5_dc, load_forecast_DA)

#add_forecasts!(c_sys5_dc, ren_forecast_DA)
add_forecasts!(c_sys14_dc, forecast_DA14)
b_ac_5 = collect(get_components(PSY.ACBranch, c_sys5_dc))
PTDF5_dc = PSY.PTDF(b_ac_5, nodes5);
b_ac_14 = collect(get_components(PSY.ACBranch, c_sys14_dc))
PTDF14_dc = PSY.PTDF(b_ac_14, nodes14);

#Function
function create_rts_system(forecast_resolution=Dates.Hour(1))
    data = PSY.PowerSystemTableData(RTS_GMLC_DIR, 100.0, joinpath(RTS_GMLC_DIR, "user_descriptors.yaml"))
    return PSY.System(data; forecast_resolution=forecast_resolution)
end

c_rts = create_rts_system();

# Defining Device models
branches = Dict{Symbol, DeviceModel}(:L => DeviceModel(PSY.Line, PSI.StaticLine),
                                      :T => DeviceModel(PSY.Transformer2W, PSI.StaticTransformer),
                                      :TT => DeviceModel(PSY.TapTransformer , PSI.StaticTransformer),
                                      :dc_line => DeviceModel(PSY.HVDCLine, PSI.HVDCDispatch))
services = Dict{Symbol, PSI.ServiceModel}()
devices = Dict{Symbol, DeviceModel}(:Generators => DeviceModel(PSY.ThermalStandard, PSI.ThermalDispatchNoMin),
                                    :Ren => DeviceModel(PSY.RenewableDispatch, PSI.RenewableFullDispatch),
                                    :Loads =>  DeviceModel(PSY.PowerLoad, PSI.StaticPowerLoad))

#Model_ref holds all the details of the model to be built 
model_ref= OperartionsTemplate(CopperPlatePowerModel, devices, branches, services)

# Making the Optimization Model 
OpModel = OperationsProblem(TestOptModel, model_ref, c_sys5_re; PTDF = PTDF5, optimizer = GLPK_optimizer)
res = solve_op_model!(OpModel)


##############################

path = "/Users/lhanig/GitHub/FeatherFiles/2019-08-13T15:16:00"
res = load_operation_results(path)
results = sort_data(res)

using Weave
using Plots
gr()

#stack_plot(results) 
#bar_plot(results
out_path="/Users/lhanig/GitHub"
jmd = "/Users/lhanig/.julia/dev/PowerSimulations/src/utils/report_design/report_design.jl"
report(results, out_path)


stacked_renew = get_stacked_plot_data(res, "P_RenewableDispatch") #; sort = Order_renew) #generates data for stacked plot
plot(stacked_renew, "P_RenewableDispatch")

stacked_therm = get_stacked_plot_data(res, "P_ThermalStandard") #; sort = Order_therm) #generates data for stacked plot
plot(stacked_therm, "P_ThermalStandard")

bar_renew = get_bar_plot_data(res, "P_RenewableDispatch"; sort = Order_renew)
plot(bar_renew, "P_RenewableDispatch")

bar_therm = get_bar_plot_data(res, "P_ThermalStandard"; sort = Order_therm)
plot(bar_therm, "P_ThermalStandard")

stacked_gen = get_stacked_generation_data(res) #; sort = Order_gen) #generates data for stacked plot
plot(stacked_gen)
