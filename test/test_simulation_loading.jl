path = (joinpath(pwd(), "test_reading_results"))
!isdir(path) && mkdir(path)


function test_load_simulation(file_path::String)
    stages_definition = Dict("UC" => Stage(GenericOpProblem, template_uc, c_sys5_uc, GLPK_optimizer),
                             "ED" => Stage(GenericOpProblem, template_ed, c_sys5_ed, GLPK_optimizer))

    sequence = SimulationSequence(
        order = Dict(1 => "UC", 2 => "ED"),
        intra_stage_chronologies = Dict(("UC"=>"ED") => Synchronize(from_steps = 24, to_executions = 1)),
        horizons = Dict("UC" => 24, "ED" => 12),
        intervals = Dict("UC" => Hour(24), "ED" => Hour(1)),
        feed_forward = Dict(("ED", :devices, :Generators) => SemiContinuousFF(binary_from_stage = :ON, affected_variables = [:P])),
        cache = Dict("ED" => [TimeStatusChange(:ON_ThermalStandard)]),
        ini_cond_chronology = Dict("UC" => Consecutive(), "ED" => Consecutive()))
    sim = Simulation(
        name = "aggregation",
        steps = 1, step_resolution =Hour(24),
        stages = stages_definition,
        stages_sequence = sequence,
        simulation_folder= file_path,
        verbose = true)
    build!(sim)
    sim_results = execute!(sim)
    stage_names = keys(sim.stages)
    step = ["step-1", "step-2"]

    @testset "testing reading and writing to the results folder" begin
        for name in stage_names
            files = collect(readdir(sim_results.results_folder))
            for f in files
                rm("$(sim_results.results_folder)/$f")
            end
            res = load_simulation_results(sim_results, name; write = true)
            loaded_res = load_operation_results(sim_results.results_folder)
            @test loaded_res.variables == res.variables
        end
    end

    @testset "testing file names" begin
        for name in stage_names
            files = collect(readdir(sim_results.results_folder))
            for f in files
                rm("$(sim_results.results_folder)/$f")
            end
            res = load_simulation_results(sim_results, name; write = true)
            variable_list = String.(PSI.get_variable_names(sim, name))
            variable_list = [variable_list; "optimizer_log"; "time_stamp"; "check"]
            file_list = collect(readdir(sim_results.results_folder))
            for name in file_list
                variable = splitext(name)[1]
                @test any(x -> x == variable, variable_list)
            end
        end
    end

    @testset "testing argument errors" begin
        for name in stage_names
            files = collect(readdir(sim_results.results_folder))
            for f in files
                rm("$(sim_results.results_folder)/$f")
            end
            res = load_simulation_results(sim_results, name)
            @test_throws IS.ConflictingInputsError write_results(res, "nothing", "results")
        end
    end

    @testset "testing load simulation results between the two methods of load simulation" begin
        for name in stage_names
            variable = PSI.get_variable_names(sim, name)
            results = load_simulation_results(sim_results, name)
            res = load_simulation_results(sim_results, name, step, variable)
            @test results.variables == res.variables
        end
    end
 ##################### from execute !
    @testset "Testing to verify parameter feedforward for consecutive UC to ED" begin
        P_keys = [PowerSimulations.UpdateRef{VariableRef}(:ON_ThermalStandard)]
        vars_names = [:ON_ThermalStandard]
        for (ik, key) in enumerate(P_keys)
            variable_ref = PSI.get_reference(sim_results, "UC", 1, vars_names[ik])[1] # 1 is first step
            ic = collect(values(value.(sim.stages["ED"].internal.psi_container.parameters[key])).data)# [device, time] 1 is first execution
            raw_result = Feather.read(variable_ref)
            for i in 1:size(ic,1)
                result = raw_result[end,i] # end is last result [time, device]
                initial = ic[i,1] # [device, time]
                @test isapprox(initial, result)
            end
        end
    end

    @testset "Testing to verify length of time_stamp" begin
        for name in keys(sim.stages)
            results = load_simulation_results(sim_results, name)
            @test size(unique(results.time_stamp), 1) == size(results.time_stamp, 1)
        end
    end

    @testset "Testing to verify no gaps in the time_stamp" begin
        for name in keys(sim.stages)
            stage = sim.stages[name]
            results = load_simulation_results(sim_results, name)
            resolution = convert(Dates.Millisecond, PSY.get_forecasts_resolution(PSI.get_sys(stage)))
            time_stamp = results.time_stamp
            length = size(time_stamp,1)
            test = results.time_stamp[1,1]:resolution:results.time_stamp[length,1]
            @test time_stamp[!,:Range] == test
        end
    end
###################

    stages_definition = Dict("UC" => Stage(GenericOpProblem, template_uc, c_sys5_uc, GLPK_optimizer),
                             "ED" => Stage(GenericOpProblem, template_ed, c_sys5_ed, GLPK_optimizer))

    sequence = SimulationSequence(
        order = Dict(1 => "UC", 2 => "ED"),
        intra_stage_chronologies = Dict(("UC"=>"ED") => Synchronize(from_steps = 24, to_executions = 1)),
        horizons = Dict("UC" => 24, "ED" => 12),
        intervals = Dict("UC" => Hour(24), "ED" => Hour(1)),
        feed_forward = Dict(("ED", :devices, :Generators) => SemiContinuousFF(binary_from_stage = :ON, affected_variables = [:P])),
        cache = Dict("ED" => [TimeStatusChange(:ON_ThermalStandard)]),
        ini_cond_chronology = Dict("UC" => Consecutive(), "ED" => Consecutive()))
    sim = Simulation(
        name = "consecutive",
        steps = 2, step_resolution = Hour(24),
        stages = stages_definition,
        stages_sequence = sequence,
        simulation_folder= file_path,
        verbose = true)
    build!(sim)
    sim_results = execute!(sim)

    @testset "Testing to verify time gap for Consecutive" begin
        names = ["UC"]
        for name in names
            variable_list = PSI.get_variable_names(sim, name)
            reference_1 = PSI.get_reference(sim_results, name, 1, variable_list[1])[1]
            reference_2 = PSI.get_reference(sim_results, name, 2, variable_list[1])[1]
            time_file_path_1 = joinpath(dirname(reference_1), "time_stamp.feather") #first line, file path
            time_file_path_2 = joinpath(dirname(reference_2), "time_stamp.feather")
            time_1 = convert(Dates.DateTime, Feather.read(time_file_path_1)[end,1]) # first time
            time_2 = convert(Dates.DateTime, Feather.read(time_file_path_2)[1,1])
            @test time_2 == time_1
        end
    end

    @testset "Testing to verify initial condition feedforward for consecutive ED to UC" begin
        ic_keys = [PSI.ICKey(PSI.DevicePower, PSY.ThermalStandard)]
        vars_names = [:P_ThermalStandard]
        for (ik,key) in enumerate(ic_keys)
            variable_ref = PSI.get_reference(sim_results, "ED", 1, vars_names[ik])[24]
            initial_conditions = get_initial_conditions(PSI.get_psi_container(sim, "UC"), key)
            for ic in initial_conditions 
                raw_result = Feather.read(variable_ref)[end,Symbol(PSI.device_name(ic))] # last value of last hour
                initial_cond = value(PSI.get_condition(ic))
                @test isapprox(raw_result, initial_cond)
            end
        end
    end
####################
    stages_definition = Dict("UC" => Stage(GenericOpProblem, template_uc, c_sys5_uc, GLPK_optimizer),
                             "ED" => Stage(GenericOpProblem, template_ed, c_sys5_ed, GLPK_optimizer))
    sequence = SimulationSequence(
        order = Dict(1 => "UC", 2 => "ED"),
        intra_stage_chronologies = Dict(("UC"=>"ED") => Synchronize(from_steps = 1, to_executions = 12)),
        horizons = Dict("UC" => 24, "ED" => 12),
        intervals = Dict("UC" => Hour(1), "ED" => Minute(5)),
        feed_forward = Dict(("ED", :devices, :Generators) => SemiContinuousFF(binary_from_stage = :ON, affected_variables = [:P])),
        cache = Dict("ED" => [TimeStatusChange(:ON_ThermalStandard)]),
        ini_cond_chronology = Dict("UC" => RecedingHorizon(), "ED" => RecedingHorizon()))

    sim = Simulation(
        name = "receding_results",
        steps = 2, step_resolution = Hour(1),
        stages = stages_definition,
        stages_sequence = sequence,
        simulation_folder = file_path,
        verbose = true)
    build!(sim)
    sim_results = execute!(sim)

    @testset "Testing to verify raw results match aggregated for Receding Horizon" begin
        stages = ["UC", "ED"]
        for stage in stages
            results = load_simulation_results(sim_results, stage)
            vars_names = [:P_ThermalStandard]
            for name in vars_names
                results.variables[name]
                variable_ref = sim_results.ref["stage-$stage"][name]
                vars = results.variables[name]
                for step in sim.steps
                    output = vars[step, :]
                    raw_result = first(Feather.read(variable_ref[step, 3]))
                    @test isapprox(output, raw_result, atol = 1e-4)
                end
            end
        end
    end
################### from execute !!
    @testset "Testing to verify time gap for Receding Horizon" begin
        names = ["UC"] # TODO why doesn't this work for ED??
        for name in names
            variable_list = PSI.get_variable_names(sim, name)
            reference_1 = PSI.get_reference(sim_results, name, 1, variable_list[1])[1]
            reference_2 = PSI.get_reference(sim_results, name, 2, variable_list[1])[1]
            time_file_path_1 = joinpath(dirname(reference_1), "time_stamp.feather") #first line, file path
            time_file_path_2 = joinpath(dirname(reference_2), "time_stamp.feather")
            time_1 = convert(Dates.DateTime, Feather.read(time_file_path_1)[1,1]) # first time
            time_2 = convert(Dates.DateTime, Feather.read(time_file_path_2)[1,1])
            time_change = time_2 - time_1
            interval = PSI.get_interval(PSI.get_sequence(sim),name)
            @test Dates.Hour(time_change) == Dates.Hour(interval)
        end
    end

    @testset "Testing to verify parameter feedforward for Receding Horizon" begin
        P_keys = [PowerSimulations.UpdateRef{VariableRef}(:ON_ThermalStandard)]
        vars_names = [:ON_ThermalStandard]
        for (ik, key) in enumerate(P_keys)
            variable_ref = PSI.get_reference(sim_results, "UC", 2, vars_names[ik])[1]
            raw_result = Feather.read(variable_ref)
            ic = sim.stages["ED"].internal.psi_container.parameters[key]
            for name in DataFrames.names(raw_result)
                result = raw_result[1, name] # first time period of results  [time, device]
                initial = value(ic[String(name)]) # [device, time]
                @test isapprox(initial, result, atol=1.0e-4)
            end
        end
    end

    @testset "Testing to verify initial condition feedforward for Receding Horizon" begin
        results = load_simulation_results(sim_results, "ED")
        ic_keys = [PSI.ICKey(PSI.DevicePower, PSY.ThermalStandard)]
        vars_names = [:P_ThermalStandard]
        for (ik, key) in enumerate(ic_keys)
            initial_conditions = get_initial_conditions(PSI.get_psi_container(sim, "UC"), key)
            vars = results.variables[vars_names[ik]] # change to getter function
            for ic in initial_conditions 
                output = vars[1,Symbol(PSI.device_name(ic))] # change to getter function
                initial_cond = value(PSI.get_condition(ic))
                @test isapprox(output, initial_cond, atol = 1e-4)
            end
        end
    end
    ####################
    @testset "negative test checking total sums" begin
        stage_names = keys(sim.stages)
        for name in stage_names
            files = collect(readdir(sim_results.results_folder))
            for f in files
                rm("$(sim_results.results_folder)/$f")
            end
            variable_list = PSI.get_variable_names(sim, name)
            res = load_simulation_results(sim_results, name; write = true)
            file_path = joinpath(sim_results.results_folder,"$(variable_list[1]).feather")
            rm(file_path)
            fake_df = DataFrames.DataFrame(:A => Array(1:10))
            Feather.write(file_path, fake_df)
               @test_logs((:error, r"hash mismatch"), match_mode=:any,
                    @test_throws(IS.HashMismatchError, check_file_integrity(dirname(file_path)))
                )
        end
        for name in stage_names
            variable_list = PSI.get_variable_names(sim, name)
            check_file_path = PSI.get_reference(sim_results, name, 1, variable_list[1])[1]
            rm(check_file_path)
            time_length = sim_results.chronologies["stage-$name"]
            fake_df = DataFrames.DataFrame(:A => Array(1:time_length))
            Feather.write(check_file_path, fake_df)
                @test_logs((:error, r"hash mismatch"), match_mode=:any,
                    @test_throws(IS.HashMismatchError, check_file_integrity(dirname(check_file_path)))
                )
        end
    end

end
try
    test_load_simulation(path)
finally
    @info("removing test files")
    rm(path, recursive=true)
end
