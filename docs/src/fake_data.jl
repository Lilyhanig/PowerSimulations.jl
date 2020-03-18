using PowerSimulations
using DataFrames
using Dates
const PSI = PowerSimulations
using PowerGraphics
const PG = PowerGraphics
variables = Dict{Symbol, DataFrames.DataFrame}()
variables[:P_ThermalStandard] = DataFrames.DataFrame(
    :one => [1, 2, 3, 2, 1],
    :two => [3, 2, 1, 2, 3],
    :three => [1, 2, 3, 2, 1],
)
variables[:P_RenewableDispatch] = DataFrames.DataFrame(
    :one => [3, 2, 3, 2, 3],
    :two => [1, 2, 1, 2, 1],
    :three => [3, 2, 3, 2, 3],
)

parameters = Dict{Symbol, DataFrames.DataFrame}()
parameters[:parameter_P_FixedGeneration] = DataFrames.DataFrame(
    :one => [2, 2, 1, 2, 2],
    :two => [3, 4, 1, 2, 2],
    :three => [3, 2, 3, 1, 1],
)

parameters[:parameter_P_PowerLoad] = DataFrames.DataFrame(
    :one => [3, 1, 3, 2, 1],
    :two => [1, 2, 1, 1, 1],
    :three => [3, 3, 3, 2, 3],
)
optimizer_log = Dict()
objective_value = Dict()
dual_values = Dict{Symbol, Any}()
right_now = round(Dates.now(), Dates.Hour)
time_stamp =
    DataFrames.DataFrame(:Range => right_now:Dates.Hour(1):(right_now + Dates.Hour(4)))
base_power = 100.0
results = PSI.OperationsProblemResults(base_power, variables, optimizer_log, objective_value, time_stamp, dual_values,parameters)

generators = Dict("Coal" => [:one; :two], "Wind" => [:three])
