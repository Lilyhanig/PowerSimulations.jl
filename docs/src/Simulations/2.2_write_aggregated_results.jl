# # Write Aggregated Results

# This is the Power Simulations package for SIIP.

# See [How to set up a simulation](2.0_set_up_simulation.md) to set up and run the simulation

# See [How to load simulation results](2.1_load_results.md) to aggregate the raw results
include("../set_up_simulation.jl");

# ## Write aggregated results to a folder
# ### Once a results object is created it may want to be written back to its dated folder to save

write_results(results)

# ### These results can be read back into memory with the folder path to the results

path = results.results_folder
new_results = load_results(path)

# ### The results can be exported and viewed in CSV format by running

PSI.write_to_CSV(new_results)

# However, once the results are written to CSV they cannot be read back into memory from the CSV file.

# ### Write results to a specific folder
# (other than the dated folder that contains the raw simulation output)

folder_path = joinpath(file_path, "aggregated_results")
if !isdir(folder_path)
    mkdir(folder_path)
end
write_results(results, folder_path)

# Read the results back from the folder
# ```julia
# newer_results = load_results(folder_path)
# ```
