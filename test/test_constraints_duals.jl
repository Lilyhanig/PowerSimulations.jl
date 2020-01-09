path = joinpath(pwd(), "test_constraints_duals")
!isdir(path) && mkdir(path)
import CSV

function test_duals(file_path)

stages_definition = Dict("UC" => Stage(GenericOpProblem, template_uc, c_sys5_uc, GLPK_optimizer),
                        "ED" => Stage(GenericOpProblem, template_ed, c_sys5_ed, GLPK_optimizer))

    sequence = SimulationSequence(order = Dict(1 => "UC", 2 => "ED"),
                   intra_stage_chronologies = Dict(("UC"=>"ED") => Synchronize(from_steps = 24, to_executions = 1)),
                   horizons = Dict("UC" => 24, "ED" => 12),
                   intervals = Dict("UC" => Hour(24), "ED" => Hour(1)),
                   feed_forward = Dict(("ED", :devices, :Generators) => SemiContinuousFF(binary_from_stage = :ON, affected_variables = [:P])),
                   cache = Dict("ED" => [TimeStatusChange(:ON_ThermalStandard)]),
                   ini_cond_chronology = Dict("UC" => Consecutive(), "ED" => Consecutive())
                   )
    sim = Simulation(name = "aggregation",
                 steps = 1, step_resolution =Hour(24),
                 stages = stages_definition,
                 stages_sequence = sequence,
                 simulation_folder= file_path,
                 verbose = true)
    build!(sim)

    @testset "testing dual constraints in results" begin

        duals = [:CopperPlateBalance]
        sim_results = execute!(sim; constraints_duals = duals)
        res = PSI.load_simulation_results(sim_results, "ED")
        dual = JuMP.dual(sim.stages["ED"].internal.psi_container.constraints[:CopperPlateBalance][1])
        @test dual == res.duals[:CopperPlateBalance_dual][1, 1]

        path = joinpath(file_path, "one")
        !isdir(path) && mkdir(path)
        PSI.write_to_CSV(res, path)
        @test !isempty(path)

        path = joinpath(file_path, "two")
        !isdir(path) && mkdir(path)
        PSI.write_results(res, path, "results")
        @test !isempty(path)

    end

end

try test_duals(path)
finally
    @info("removing test files")
    rm(path, recursive=true)
end