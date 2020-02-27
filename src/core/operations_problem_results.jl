get_results(result::IS.Results) = nothing
struct OperationsProblemResults <: IS.Results
    variables::Dict{Symbol, DataFrames.DataFrame}
    total_cost::Dict
    optimizer_log::Dict
    time_stamp::DataFrames.DataFrame
    base_power::Int
end

"""This function creates the correct results struct for the context"""
function _make_results(
    variables::Dict,
    total_cost::Dict,
    optimizer_log::Dict,
    time_stamp::DataFrames.DataFrame,
    base_power::Int,
)
    return OperationsProblemResults(variables, total_cost, optimizer_log, time_stamp, base_power)
end
"""This function creates the correct results struct for the context"""
function _make_results(
    variables::Dict,
    total_cost::Dict,
    optimizer_log::Dict,
    time_stamp::Array,
    base_power::Int,
)
    time_stamp = DataFrames.DataFrame(Range = time_stamp)
    return OperationsProblemResults(variables, total_cost, optimizer_log, time_stamp, base_power)
end
"""This function creates the correct results struct for the context"""
function _make_results(
    variables::Dict,
    total_cost::Dict,
    optimizer_log::Dict,
    time_stamp::Array,
    constraints_duals::Dict,
    base_power::Int,
)
    time_stamp = DataFrames.DataFrame(Range = time_stamp)
    return DualResults(
        variables,
        total_cost,
        optimizer_log,
        time_stamp,
        constraints_duals,
        nothing,
        base_power,
    )
end
function get_variable(res_model::OperationsProblemResults, key::Symbol)
    try
        !isnothing(res_model.variables)
        return get(res_model.variables, key, nothing)
    catch
        throw(ArgumentError("No variable with key $(key) has been found."))
    end
end

function get_optimizer_log(results::OperationsProblemResults)
    return results.optimizer_log
end

function get_time_stamps(results::OperationsProblemResults, key::Symbol)
    return results.time_stamp
end

"""
    results = load_operation_results(path)

This function can be used to load results from a folder
of results from a single-step problem, or for a single foulder
within a simulation.

# Arguments
- `path::AbstractString = folder path`
- `directory::AbstractString = "2019-10-03T09-18-00"`: the foulder name that contains
feather files of the results.

# Example
```julia
results = load_operation_results("/Users/test/2019-10-03T09-18-00")
```
"""
function load_operation_results(folder_path::AbstractString)

    if isfile(folder_path)
        throw(ArgumentError("Not a folder path."))
    end
    files_in_folder = collect(readdir(folder_path))
    variable_list = setdiff(
        files_in_folder,
        ["time_stamp.feather", "base_power.json", "optimizer_log.json", "check.sha256"],
    )
    variables = Dict{Symbol, DataFrames.DataFrame}()
    duals = Dict()
    dual = _find_duals(variable_list)
    variable_list = setdiff(variable_list, dual)
    for name in variable_list
        variable_name = splitext(name)[1]
        file_path = joinpath(folder_path, name)
        variables[Symbol(variable_name)] = Feather.read(file_path)
    end
    optimizer = read_json(joinpath(folder_path, "optimizer_log.json"))
    time_stamp = Feather.read(joinpath(folder_path, "time_stamp.feather"))
    @show base_power = Int(JSON.read(joinpath(folder_path, "base_power.json"))[1])
    if size(time_stamp, 1) > find_var_length(variables, variable_list)
        time_stamp = shorten_time_stamp(time_stamp)
    end
    obj_value = Dict{Symbol, Any}(:OBJECTIVE_FUNCTION => optimizer["obj_value"])
    check_file_integrity(folder_path)
    results = _make_results(variables, obj_value, optimizer, time_stamp, base_power)
    return results
end

# this ensures that the time_stamp is not double shortened
function find_var_length(variables::Dict, variable_list::Array)
    return size(variables[Symbol(splitext(variable_list[1])[1])], 1)
end

function shorten_time_stamp(time::DataFrames.DataFrame)
    time = time[1:(size(time, 1) - 1), :]
    return time
end

# This method is also used by DualResults
"""
    write_results(results::IS.Results, save_path::String)

Exports Operational Problem Results to a path

# Arguments
- `results::OperationsProblemResults`: results from the simulation
- `save_path::String`: folder path where the files will be written

# Accepted Key Words
- `file_type = CSV`: only CSV and featherfile are accepted
"""
function write_results(results::IS.Results, save_path::String; kwargs...)
    if !isdir(save_path)
        throw(IS.ConflictingInputsError("Specified path is not valid. Run write_results to save results."))
    end
    folder_path = mkdir(joinpath(
        save_path,
        replace_chars("$(round(Dates.now(), Dates.Minute))", ":", "-"),
    ))
    _write_data(results.variables, folder_path; kwargs...)
    _write_data(results.base_power, folder_path)
    _write_optimizer_log(results.optimizer_log, folder_path)
    _write_data(results.time_stamp, folder_path, "time_stamp"; kwargs...)
    files = collect(readdir(folder_path))
    compute_file_hash(folder_path, files)
    @info("Files written to $folder_path folder.")
    return
end

# writes the results to CSV files in a folder path, but they can't be read back
function write_to_CSV(results::OperationsProblemResults, folder_path::String)
    write_results(results, folder_path, "results"; file_type = CSV)
end
