using Documenter
using PowerSimulations
using Literate
using PowerGraphics
const PG = PowerGraphics

include("src/fake_data.jl")

folders = Dict(
    "Operations" => readdir("docs/src/Operations"),
    "Simulations" => readdir("docs/src/Simulations"),
    "PowerGraphics" => readdir("docs/src/PowerGraphics"),
)

for (name, folder) in folders
    for file in folder
        outputdir = joinpath(pwd(), "docs/src/howto")
        inputfile = joinpath(pwd(), "docs/src/$name/$file")
        Literate.markdown(inputfile, outputdir)
    end
end

makedocs(
    sitename = "PowerSimulations.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [PowerSimulations],
    strict = true,
    authors = "Jose Daniel Lara, Clayton Barrows and Dheepak Krishnamurthy",
    pages = Any[
        "Introduction" => "index.md",
        #"Quick Start Guide" => "qs_guide.md",
        "Operation Model" => "man/op_problem.md",
        "API" => Any["PowerSimulations" => "api/PowerSimulations.md"],
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#

deploydocs(
    repo = "github.com/NREL/PowerSimulations.jl.git",
    branch = "gh-pages",
    target = "build",
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    make = nothing,
)
