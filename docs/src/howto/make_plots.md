```@meta
EditURL = "<unknown>/src/PowerGraphics/make_plots.jl"
```

```@example make_plots
import PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/get_test_data.jl")
op_results = PSI.run_economic_dispatch(c_sys5; optimizer = GLPK_optimizer)
```

3.0

```@example make_plots
Plots.gr()

path = joinpath("/Users/lhanig/.julia/dev/PowerSimulations/docs/build/howto", "plots-1")
if !isdir(path)
    mkdir(path)
end
PG.stack_plot(op_results; save = path, display = false, title = "Example GR Plot")
```

## To make an interactive PlotlyJS plot, reset the backend

```@example make_plots
Plots.plotlyjs()

path = joinpath("/Users/lhanig/.julia/dev/PowerSimulations/docs/build/howto", "plots-2")
if !isdir(path)
    mkdir(path)
end
PG.stack_plot(
    op_results;
    save = path,
    display = false,
    format = "png",
    title = "Example PlotlyJS Plot",
)
```

3.1

```@example make_plots
path = mkdir(joinpath(pwd(), "plots-3"))
PG.stack_plot(op_results; save = path, format = "png", title = "Example Stack Plot")

path = mkdir(joinpath(pwd(), "plots-4"))
PG.stack_plot(op_results; save = path, format = "png", title = "Example saved Stack Plot")

path = mkdir(joinpath(pwd(), "plots-5"))
PG.stack_plot(
    op_results;
    reserves = true,
    save = path,
    format = "png",
    title = "Example Stack Plot with Reserves",
)

colors = [:pink :green :blue :magenta :black]
path = mkdir(joinpath(pwd(), "plots-6"))
PG.stack_plot(
    op_results;
    seriescolor = colors,
    save = path,
    format = "png",
    title = "Example Stack Plot with Other Colors",
)

title = "Example of a Title"
path = mkdir(joinpath(pwd(), "plots-7"))
PG.stack_plot(op_results; save = path, format = "png", title = title)
```

3.2

```@example make_plots
path = mkdir(joinpath(pwd(), "plots-8"))
PG.bar_plot(op_results; save = path, format = "png", title = "Example Bar Plot")

path = mkdir(joinpath(pwd(), "plots-9"))
PG.bar_plot(op_results; save = path, format = "png", title = "Example saved Bar Plot")

path = mkdir(joinpath(pwd(), "plots-10"))
PG.bar_plot(
    op_results;
    reserves = true,
    save = path,
    format = "png",
    title = "Example Bar Plot with Reserves",
)

path = mkdir(joinpath(pwd(), "plots-11"));
PG.bar_plot(
    op_results;
    seriescolor = colors,
    save = path,
    format = "png",
    title = "Example Bar Plot with Other Colors",
)

title = "Example of a Title"
path = mkdir(joinpath(pwd(), "plots-12"));
PG.bar_plot(op_results; save = path, format = "png", title = title);
nothing #hide
```

3.3

```@example make_plots
Plots.gr()
system = c_sys5_re;
re_results = PSI.run_economic_dispatch(c_sys5_re; optimizer = GLPK_optimizer)
path = mkdir(joinpath(pwd(), "plots-13"))
PG.fuel_plot(re_results, system; save = path, format = "png", title = "Example Fuel Plot")

path = mkdir(joinpath(pwd(), "plots-14"))
PG.fuel_plot(
    re_results,
    system;
    reserves = true,
    save = path,
    format = "png",
    title = "Example Fuel Plot with Reserves",
)

colors = [:pink :green :blue :magenta :black]
path = mkdir(joinpath(pwd(), "plots-15"));
PG.fuel_plot(
    re_results,
    system;
    seriescolor = colors,
    save = path,
    format = "png",
    title = "Example Fuel Plot with Other Colors",
)

title = "Example of a Title"
path = mkdir(joinpath(pwd(), "plots-16"));
PG.fuel_plot(re_results, system; save = path, format = "png", title = title)
```

3.4

```@example make_plots
path = mkdir(joinpath(pwd(), "plots-17"));
variables = [Symbol("P__PowerSystems.RenewableDispatch")]
PG.stack_plot(
    re_results,
    variables;
    save = path,
    format = "png",
    title = "Plot with Fewer Variables",
)

selected_variables = Dict(
    Symbol("P__PowerSystems.ThermalStandard") => [:Brighton, :Solitude],
    Symbol("P__PowerSystems.RenewableDispatch") => [:WindBusA, :WindBusC],
)
results_subset = PG.sort_data(re_results; Variables = selected_variables)
path = mkdir(joinpath(pwd(), "plots-18"));
PG.stack_plot(
    results_subset;
    save = path,
    format = "png",
    title = "Selected Variables Plot",
)
```

3.5

```@example make_plots
results_one =
    PSI.run_economic_dispatch(c_sys5_re; optimizer = GLPK_optimizer, parameters = false)
results_two =
    PSI.run_economic_dispatch(c_sys5_re; optimizer = GLPK_optimizer, parameters = true)

path = mkdir(joinpath(pwd(), "plots-19"));
PG.stack_plot([results_one, results_two]; save = path, format = "png", title = "Comparison")
Plots.gr()
path = mkdir(joinpath(pwd(), "plots-20"));
PG.fuel_plot(
    [results_one, results_two],
    c_sys5_re;
    save = path,
    format = "png",
    title = "Comparison",
)

variables =
    [Symbol("P__PowerSystems.ThermalStandard"), Symbol("P__PowerSystems.RenewableDispatch")]
path = mkdir(joinpath(pwd(), "plots-21"));
PG.stack_plot(
    [results_one, results_two],
    variables;
    save = path,
    format = "png",
    title = "Comparison with fewer variables",
)
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

