#+ term = false
#' ---
#' title : Weave example
#' author : SIIP
#' date : Friday the 13th
#' ---



using PowerSimulations
using Plots

gr()

bar_plot(WEAVE_ARGS["res"])




stack_plot(WEAVE_ARGS["res"])




for (k,v) in WEAVE_ARGS["variables"]
display((WEAVE_ARGS["variables"])[k])
end



