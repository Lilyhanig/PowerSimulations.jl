using Pkg
using Revise
using PowerSystems
const PSY = PowerSystems
using InfrastructureSystems
const IS = InfrastructureSystems
using Ipopt
using GLPK
using Dates
using DataFrames
using ParameterJuMP
using JuMP
using Test
const PJ = ParameterJuMP
import PowerModels
const PM = PowerModels
ipopt_optimizer = with_optimizer(Ipopt.Optimizer, print_level = 4)
GLPK_optimizer = with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL)
using PowerSimulations
const PSI = PowerSimulations

base_dir = string(dirname(dirname(pathof(PowerSimulations))))
DATA_DIR = joinpath(base_dir, "test/test_data")
include(joinpath(DATA_DIR, "data_5bus_pu.jl"))
include(joinpath(DATA_DIR, "data_14bus_pu.jl"))

thermal_generators5_uc_testing(nodes5) = [ThermalStandard("Alta", true, nodes5[1], 0.0, 0.0,
           TechThermal(0.5, PowerSystems.ST, PowerSystems.COAL, (min=0.2, max=0.40),  (min = -0.30, max = 0.30), nothing, nothing),
           ThreePartCost((0.0, 1400.0), 0.0, 4.0, 2.0)
           ),
           ThermalStandard("Park City", true, nodes5[1], 0.0, 0.0,
               TechThermal(2.2125, PowerSystems.ST, PowerSystems.COAL, (min=0.65, max=1.70), (min =-1.275, max=1.275), (up=0.02, down=0.02), nothing),
               ThreePartCost((0.0, 1500.0), 0.0, 1.5, 0.75)
           ),
           ThermalStandard("Solitude", true, nodes5[3], 2.7, 0.00,
               TechThermal(5.20, PowerSystems.ST, PowerSystems.COAL, (min=1.0, max=5.20), (min =-3.90, max=3.90), (up=0.0012, down=0.0012), (up=5.0, down=3.0)),
               ThreePartCost((0.0, 3000.0), 0.0, 3.0, 1.5)
           ),
           ThermalStandard("Sundance", true, nodes5[4], 0.0, 0.00,
               TechThermal(2.5, PowerSystems.ST, PowerSystems.COAL, (min=1.0, max=2.0), (min =-1.5, max=1.5), (up=0.015, down=0.015), (up=2.0, down=1.0)),
               ThreePartCost((0.0, 4000.0), 0.0, 4.0, 2.0)
           ),
           ThermalStandard("Brighton", true, nodes5[5], 6.0, 0.0,
               TechThermal(7.5, PowerSystems.ST, PowerSystems.COAL, (min=3.0, max=6.0), (min =-4.50, max=4.50), (up=0.0015, down=0.0015), (up=5.0, down=3.0)),
               ThreePartCost((0.0, 1000.0), 0.0, 1.5, 0.75)
           )];
nodes = nodes5()
c_sys5_uc = System(nodes, vcat(thermal_generators5_uc_testing(nodes), renewable_generators5(nodes)), vcat(loads5(nodes), interruptible(nodes)), branches5(nodes), nothing, 100.0, nothing, nothing);
for t in 1:2
    for (ix, l) in enumerate(get_components(PowerLoad, c_sys5_uc))
        add_forecast!(c_sys5_uc, l, Deterministic("get_maxactivepower", load_timeseries_DA[t][ix]))
    end
    for (ix, r) in enumerate(get_components(RenewableGen, c_sys5_uc))
        add_forecast!(c_sys5_uc, r, Deterministic("get_rating", ren_timeseries_DA[t][ix]))
    end
    for (ix, i) in enumerate(get_components(InterruptibleLoad, c_sys5_uc))
        add_forecast!(c_sys5_uc, i, Deterministic("get_maxactivepower", Iload_timeseries_DA[t][ix]))
    end
end
using TimeSeries
using Dates
c_sys5_ed = System(nodes, vcat(thermal_generators5_uc_testing(nodes), renewable_generators5(nodes)), vcat(loads5(nodes), interruptible(nodes)), branches5(nodes), nothing, 100.0, nothing, nothing);

for t in 1:2 # loop over days
    for (ix, l) in enumerate(get_components(PowerLoad, c_sys5_ed))
        ta = load_timeseries_DA[t][ix]
        for i in 1:length(ta) # loop over hours
            ini_time = timestamp(ta[i]) #get the hour
            data = when(load_timeseries_RT[t][ix], hour, hour(ini_time[1])) # get the subset ts for that hour
            add_forecast!(c_sys5_ed, l, Deterministic("get_maxactivepower", data))
        end
    end
end
for t in 1:2
    for (ix, l) in enumerate(get_components(RenewableGen, c_sys5_ed))
        ta = load_timeseries_DA[t][ix]
        for i in 1:length(ta) # loop over hours
            ini_time = timestamp(ta[i]) #get the hour
            data = when(ren_timeseries_RT[t][ix], hour,hour(ini_time[1])) # get the subset ts for that hour
            add_forecast!(c_sys5_ed, l, Deterministic("get_rating", data))
        end
    end
end
for t in 1:2
    for (ix, l) in enumerate(get_components(InterruptibleLoad, c_sys5_ed))
        ta = load_timeseries_DA[t][ix]
        for i in 1:length(ta) # loop over hours
            ini_time = timestamp(ta[i]) #get the hour
            data = when(Iload_timeseries_RT[t][ix], hour,hour(ini_time[1])) # get the subset ts for that hour
            add_forecast!(c_sys5_ed, l, Deterministic("get_maxactivepower", data))
        end
    end
end