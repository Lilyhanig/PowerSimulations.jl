struct SimulationResultsReference
    ref::Dict
    results_folder::String
    chronologies::Dict
    base_power::Dict
end

function SimulationResultsReference(sim::Simulation; kwargs...)
    date_run = convert(String, last(split(dirname(sim.internal.raw_dir), "/")))
    ref = make_references(sim, date_run; kwargs...)
    chronologies = Dict()
    base_powers = Dict()
    for (stage_number, stage_name) in sim.sequence.order
        stage = get_stage(sim, stage_name)
        interval = get_stage_interval(sim, stage_name)
        resolution = PSY.get_forecasts_resolution(get_sys(stage))
        chronologies["stage-$stage_name"] = convert(Int, (interval / resolution))
        base_powers[stage_name] = Int(sim.stages[stage_name].sys.basepower)
    end
    return SimulationResultsReference(
        ref,
        sim.internal.results_dir,
        chronologies,
        base_powers,
    )
end

"""
    make_references(sim::Simulation, date_run::String; kwargs...)

Creates a dictionary of variables with a dictionary of stages
that contains dataframes of date/step/and desired file path
so that the results can be parsed sequentially by variable
and stage type.

**Note:** make_references can only be run after run_sim_model
or else, the folder structure will not yet be populated with results

# Arguments
- `sim::Simulation = sim`: simulation object created by Simulation()
- `date_run::String = "2019-10-03T09-18-00"``: the name of the file created
that contains the specific simulation run of the date run and "-test"

# Example
```julia
sim = Simulation("test", 7, stages, "/Users/yourusername/Desktop/"; system_to_file = false)
execute!(sim::Simulation; kwargs...)
references = make_references(sim, "2019-10-03T09-18-00-test")
```

# Accepted Key Words
- `constraints_duals::Vector{Symbol}`: name of dual constraints to be added to results
"""
function make_references(sim::Simulation, date_run::String; kwargs...)
    sim.internal.date_ref[1] = sim.initial_time
    sim.internal.date_ref[2] = sim.initial_time
    references = Dict()
    for (stage_number, stage_name) in sim.sequence.order
        variables = Dict{Symbol, Any}()
        interval = get_stage_interval(sim, stage_name)
        variable_names =
            (collect(keys(get_psi_container(sim.stages[stage_name]).variables)))
        if :constraints_duals in keys(kwargs) && !isnothing(kwargs[:constraints_duals])
            dual_cons = Symbol.(_concat_string(kwargs[:constraints_duals]))
            variable_names = vcat(variable_names, dual_cons)
        end
        for name in variable_names
            variables[name] = DataFrames.DataFrame(
                Date = Dates.DateTime[],
                Step = String[],
                File_Path = String[],
            )
        end
        for s in 1:(sim.steps)
            stage = get_stage(sim, stage_name)
            for run in 1:(stage.internal.executions)
                sim.internal.current_time = sim.internal.date_ref[stage_number]
                for name in variable_names
                    full_path = joinpath(
                        sim.internal.raw_dir,
                        "step-$(s)-stage-$(stage_name)",
                        replace_chars("$(sim.internal.current_time)", ":", "-"),
                        "$(name).feather",
                    )
                    if isfile(full_path)
                        date_df = DataFrames.DataFrame(
                            Date = sim.internal.current_time,
                            Step = "step-$(s)",
                            File_Path = full_path,
                        )
                        variables[name] = vcat(variables[name], date_df)
                    else
                        @error "$full_path, does not contain any simulation result raw data"
                    end
                end
                sim.internal.run_count[s][stage_number] += 1
                sim.internal.date_ref[stage_number] =
                    sim.internal.date_ref[stage_number] + interval
            end
        end
        references["stage-$stage_name"] = variables
    end
    return references
end

struct SimulationResults <: IS.Results
    variables::Dict{Symbol, DataFrames.DataFrame}
    total_cost::Dict
    optimizer_log::Dict
    time_stamp::DataFrames.DataFrame
    results_folder::Union{Nothing, String}
    base_power::Int
    function SimulationResults(
        variables::Dict,
        total_cost::Dict,
        optimizer_log::Dict,
        time_stamp::DataFrames.DataFrame,
        base_power::Int,
    )
        new(variables, total_cost, optimizer_log, time_stamp, nothing, base_power)
    end
    function SimulationResults(
        variables::Dict,
        total_cost::Dict,
        optimizer_log::Dict,
        time_stamp::DataFrames.DataFrame,
        results_folder::String,
        base_power::Int,
    )
        new(variables, total_cost, optimizer_log, time_stamp, results_folder, base_power)
    end
end

function deserialize_sim_output(file_path::String)
    path = joinpath(file_path, "output_references")
    list = setdiff(
        collect(readdir(path)),
        ["results_folder.json", "chronologies.json", "base_power.json"],
    )
    ref = Dict()
    for stage in list
        ref[stage] = Dict{Symbol, Any}()
        for variable in collect(readdir(joinpath(path, stage)))
            var = splitext(variable)[1]
            ref[stage][Symbol(var)] = Feather.read(joinpath(path, stage, variable))
            ref[stage][Symbol(var)][!, :Date] =
                convert(Array{Dates.DateTime}, ref[stage][Symbol(var)][!, :Date])
        end
    end
    results_folder = read_json(joinpath(path, "results_folder.json"))
    chronologies = Dict{Any, Any}(read_json(joinpath(path, "chronologies.json")))
    base_power = Dict{Any, Any}(read_json(joinpath(path, "base_power.json")))
    sim_output = SimulationResultsReference(ref, results_folder, chronologies, base_power)
    return sim_output
end

"""
    load_simulation_results(stage, step, variable, SimulationResultsReference)

This function goes through the reference table of file paths and
aggregates the results over time into a struct of type OperationsProblemResults
for the desired step range and variables

# Arguments
- `SimulationResultsReference::SimulationResultsReference`: the container for the reference dictionary created in execute!
- `stage_number::Int = 1``: The stage of the results getting parsed: 1 or 2
- `step::Array{String} = ["step-1", "step-2", "step-3"]`: the steps of the results getting parsed
- `variable::Array{Symbol} = [:P_ThermalStandard, :P_RenewableDispatch]`: the variables to be parsed

# Example
```julia
stage = "stage-1"
step = ["step-1", "step-2", "step-3"] # has to match the date range
variable = [:P_ThermalStandard, :P_RenewableDispatch]
results = load_simulation_results(stage,step, variable, SimulationResultsReference)
```
# Accepted Key Words
"""

function load_simulation_results(
    path::String,
    stage_name::String,
    step::Array,
    variable::Array;
    kwargs...,
)
    sim_results = deserialize_sim_output(path)
    load_simulation_results(sim_results, stage_name, step, variable; kwargs...)
end
function load_simulation_results(
    sim_output::SimulationResultsReference,
    stage_name::String,
    step::Array,
    variable::Array;
    kwargs...,
)
    results_folder = sim_output.results_folder
    stage = "stage-$stage_name"
    references = sim_output.ref
    base_power = sim_output.base_power[stage_name]
    variables = Dict() # variable dictionary
    duals = Dict()
    time_stamp = DataFrames.DataFrame(Range = Dates.DateTime[])
    time_length = sim_output.chronologies[stage]
    dual = _find_duals(collect(keys(references[stage])))
    variable = setdiff(variable, dual)
    for l in 1:length(variable)
        date_df = references[stage][variable[l]]
        step_df = DataFrames.DataFrame(
            Date = Dates.DateTime[],
            Step = String[],
            File_Path = String[],
        )
        for n in 1:length(step)
            step_df = vcat(step_df, date_df[date_df.Step .== step[n], :])
        end
        variables[(variable[l])] = DataFrames.DataFrame()
        for (ix, time) in enumerate(step_df.Date)
            file_path = step_df[ix, :File_Path]
            var = Feather.read("$file_path")
            variables[(variable[l])] = vcat(variables[(variable[l])], var[1:time_length, :])
            if l == 1
                time_stamp = vcat(time_stamp, _read_time(file_path, time_length))
                check_file_integrity(dirname(file_path))
            end
        end
    end
    time_stamp[!, :Range] = convert(Array{Dates.DateTime}, time_stamp[!, :Range])
    file_path = dirname(references[stage][variable[1]][1, :File_Path])
    optimizer = read_json(joinpath(file_path, "optimizer_log.json"))
    obj_value = Dict{Symbol, Any}(:OBJECTIVE_FUNCTION => optimizer["obj_value"])
    if !isempty(dual)
        duals = _read_references(duals, dual, stage, step, references, time_length)
        results = DualResults(
            variables,
            obj_value,
            optimizer,
            time_stamp,
            duals,
            results_folder,
            base_power,
        )
    else
        results = SimulationResults(
            variables,
            obj_value,
            optimizer,
            time_stamp,
            results_folder,
            base_power,
        )
    end
    return results
end

"""
    load_simulation_results(file_path, stage)

This function goes through the reference table of file paths and
aggregates the results over time into a struct of type OperationsProblemResults

# Arguments
- `file_path::String`: the file path to the dated folder with the raw results
- `stage_number::String`: The stage of the results getting parsed

# Example
```julia
execute!(simulation)
results = load_simulation_results("file_path", "stage_name")
```
# Accepted Key Words
"""
function load_simulation_results(path::String, stage_name::String, kwargs...)
    sim_results = deserialize_sim_output(path)
    load_simulation_results(sim_results, stage_name; kwargs...)
end
"""
    load_simulation_results(SimulationResultsReference, stage)

This function goes through the reference table of file paths and
aggregates the results over time into a struct of type OperationsProblemResults

# Arguments
- `SimulationResultsReference::SimulationResultsReference`: the container for the reference dictionary created in execute!
- `stage_number::String`: The stage of the results getting parsed

# Example
```julia
sim_output = execute!(simulation)
results = load_simulation_results(sim_output, "stage_name")
```
# Accepted Key Words
"""
function load_simulation_results(
    sim_output::SimulationResultsReference,
    stage_name::String;
    kwargs...,
)
    results_folder = sim_output.results_folder
    stage = "stage-$stage_name"
    references = sim_output.ref
    base_power = sim_output.base_power[stage_name]
    variables = Dict()
    duals = Dict()
    variable = (collect(keys(references[stage])))
    dual = _find_duals(variable)
    variable = setdiff(variable, dual)
    time_stamp = DataFrames.DataFrame(Range = Dates.DateTime[])
    time_length = sim_output.chronologies[stage]

    for l in 1:length(variable)
        date_df = references[stage][variable[l]]
        variables[(variable[l])] = DataFrames.DataFrame()
        for (ix, time) in enumerate(date_df.Date)
            file_path = date_df[ix, :File_Path]
            var = Feather.read(file_path)
            variables[(variable[l])] = vcat(variables[(variable[l])], var[1:time_length, :])
            if l == 1
                time_stamp = vcat(time_stamp, _read_time(file_path, time_length))
                check_file_integrity(dirname(file_path))
            end
        end
    end
    time_stamp[!, :Range] = convert(Array{Dates.DateTime}, time_stamp[!, :Range])
    file_path = dirname(references[stage][variable[1]][1, :File_Path])
    optimizer = read_json(joinpath(file_path, "optimizer_log.json"))
    obj_value = Dict{Symbol, Any}(:OBJECTIVE_FUNCTION => optimizer["obj_value"])
    if !isempty(dual)
        duals = _read_references(duals, dual, stage, references, time_length)
        results = DualResults(
            variables,
            obj_value,
            optimizer,
            time_stamp,
            duals,
            results_folder,
            base_power,
        )
    else
        results = SimulationResults(
            variables,
            obj_value,
            optimizer,
            time_stamp,
            results_folder,
            base_power,
        )
    end
    return results
end
"""
    check_file_integrity(path::String)

Checks the hash value for each file made with the file is written with the new hash_value to verify the file hasn't been tampered with since written

# Arguments
- `path::String`: this is the folder path that contains the results and the check.sha256 file
"""
function check_file_integrity(path::String)
    file_path = joinpath(path, "check.sha256")
    text = open(file_path, "r") do io
        return readlines(io)
    end

    matched = true
    for line in text
        expected_hash, file_name = split(line)
        actual_hash = compute_sha256(file_name)
        if expected_hash != actual_hash
            @error "hash mismatch for file" file_name expected_hash actual_hash
            matched = false
        end
    end

    if !matched
        throw(IS.HashMismatchError("The hash value in the written files does not match the read files, results may have been tampered."))
    end
end

function get_variable_names(sim::Simulation, stage::Any)
    return get_variable_names(sim.stages[stage].internal.psi_container)
end

function get_reference(
    sim_results::SimulationResultsReference,
    stage::String,
    step::Int,
    variable::Symbol,
)
    file_paths = sim_results.ref["stage-$stage"][variable]
    return filter(file_paths -> file_paths.Step == "step-$step", file_paths)[:, :File_Path]
end

get_psi_container(sim::Simulation, stage::Any) = sim.stages[stage].internal.psi_container

"""
    write_results(results::SimulationResults)

Exports Simulations Results to the path where they come from in the results folder

# Arguments
- `results::SimulationResults`: results from the simulation
- `save_path::String`: folder path where the files will be written
- `results_folder`: name of the folder where the results will be written

# Accepted Key Words
- `file_type = CSV`: only CSV and featherfile are accepted
"""

function write_results(res::SimulationResults; kwargs...)
    folder_path = res.results_folder
    if !isdir(folder_path)
        throw(IS.ConflictingInputsError("Specified path is not valid. Set up results folder."))
    end
    _write_data(res.variables, res.time_stamp, folder_path; kwargs...)
    _write_optimizer_log(res.optimizer_log, folder_path)
    _write_data(res.base_power, folder_path)
    _write_data(res.time_stamp, folder_path, "time_stamp"; kwargs...)
    files = collect(readdir(folder_path))
    compute_file_hash(folder_path, files)
    @info("Files written to $folder_path folder.")
    return
end

function serialize_sim_output(sim_results::SimulationResultsReference)
    file_path = mkdir(joinpath(dirname(sim_results.results_folder), "output_references"))
    for (k, stage) in sim_results.ref
        for (i, v) in stage
            path = joinpath(file_path, "$k")
            !isdir(path) && mkdir(path)
            Feather.write(joinpath(path, "$i.feather"), v)
        end
    end
    JSON.write(
        joinpath(file_path, "results_folder.json"),
        JSON.json(sim_results.results_folder),
    )
    JSON.write(
        joinpath(file_path, "chronologies.json"),
        JSON.json(sim_results.chronologies),
    )
    JSON.write(joinpath(file_path, "base_power.json"), JSON.json(sim_results.base_power))
end

# writes the results to CSV files in a folder path, but they can't be read back
function write_to_CSV(results::SimulationResults, folder_path::String)
    write_results(results, folder_path; file_type = CSV)
end
