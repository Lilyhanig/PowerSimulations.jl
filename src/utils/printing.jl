#=
function Base.show(io::IO, op_problem::OperationsProblem)
    println(io, "Operation Model")
end
=#

function _organize_device_model(val::Dict{Symbol, DeviceModel}, field::Symbol, io::IO)

    println(io, "  $(field): ")
    for (i, ix) in val

        println(io, "      $(i):")
        for inner_field in fieldnames(DeviceModel)

            value = getfield(val[i], Symbol(inner_field))

            if !isnothing(value)
                println(io, "        $(inner_field) = $value")
            end
        end
    end

end

"""
    Base.show(io::IO, ::MIME"text/plain", op_problem::OperationsProblem)

This function goes through the fields in OperationsProblem and then in OperationsTemplate,
if the field contains a Device model dictionary, it calls organize_device_model() &
prints the data by field, key, value. If the field is not a Device model dictionary,
and a value exists for that field it prints the value.


"""
function Base.show(io::IO, ::MIME"text/plain", op_problem::OperationsProblem)

    println(io, "\nOperations Problem")
    println(io, "===============\n")

    for field in fieldnames(OperationsTemplate)

        val = getfield(op_problem.template, Symbol(field))

        if typeof(val) == Dict{Symbol, DeviceModel}

            _organize_device_model(val, field, io)

        else
            if !isnothing(val)
                println(io, "  $(field):  $(val)")
            else
                println(io, "no data")
            end
        end
    end
end




function Base.show(io::IO, op_problem::Canonical)
    println(io, "Canonical()")
end

function Base.show(io::IO, op_problem::Simulation)
    println(io, "Simulation()")
end
#=
function Base.show(io::IO, results::OperationsProblemResults)
    println(io, "Results Model")
 end

=#

function Base.show(io::IO, ::MIME"text/plain", results::Results)
    println(io, "\nResults")
    println(io, "===============\n")

    for (k, v) in results.variables
        time = DataFrames.DataFrame(Time = results.time_stamp[!, :Range])
        if size(time, 1) == size(v, 1)
            var = hcat(time, v)
        else
            var = v
        end
        println(io, "$(k)")
        println(io, "==================")
        println(io, "$(var)\n")
    end
    println(io, "Optimizer Log")
    println(io, "-------------")
    for (k, v) in results.optimizer_log
        println(io, "        $(k) = $(v)")
    end
    println(io, "\n")
    for (k, v) in results.total_cost
        println(io, "Total Cost: $(k) = $(v)")
    end
    if :check_sum in fieldnames(typeof(results))
        println(io, "check sum: $(results.check_sum[1])\n")
    end
 end

 function Base.show(io::IO, ::MIME"text/html", results::PSI.Results)

    println(io, "<h1>Results</h1>")
    for (k, v) in results.variables
        time = DataFrames.DataFrame(Time = results.time_stamp[!, :Range])
        if size(time, 1) == size(v, 1)
            var = hcat(time, v)
        else
            var = v
        end
        println(io, "<b>$(k)</b>")
        show(io, MIME"text/html"(), var)
    end
    println(io, "<p><b>Optimizer Log</b></p>")
    for (k, v) in results.optimizer_log
        println(io, "<p>        $(k) = $(v)</p>")
    end
    println(io, "\n")
    for (k, v) in results.total_cost
        println(io, "<p><b>Total Cost: $(v)<b/></p>")
    end
    if :check_sum in fieldnames(typeof(results))
        println(io, "<p><b>check sum: $(results.check_sum[1])</b></p>")
    end
 end

 function Base.show(io::IO, stage::Stage)
    println(io, "Stage()")
 end

 function Base.show(io::IO, ::MIME"text/html", services::Dict{Symbol, PSI.ServiceModel})
    println(io, "<h1>Services</h1>")
    for (k, v) in services
        println(io, "<p><b>$(k)</b></p>")
        println(io, "<p>$(v)</p>")
    end
 end