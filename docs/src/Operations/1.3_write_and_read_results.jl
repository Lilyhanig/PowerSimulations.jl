# # Write and Read Operations Results

# This is the Power Simulations package for SIIP.

# See [Set Up Operations](1.0_set_up_operations.md) to solve a single-step Simulation
include("../../src/get_test_Data.jl");
# Run the operational problem and create a results object

results = solve!(operations_problem)

# ### Write the results to a folder
folder_path = joinpath(file_path, "operations")
if !isdir(folder_path)
    mkdir(folder_path)
end

PSI.write_results(results, folder_path)

# ### Read the results back from the folder path
results = PSI.load_operation_results(folder_path)
