######## Internal Simulation Object Structs ########
mutable struct StageInternal
    number::Int64
    executions::Int64
    execution_count::Int64
    synchronized_executions::Dict{Int64, Int64} # Number of executions per upper level stage step
    psi_container::Union{Nothing, PSIContainer}
    cache_dict::Dict{Type{<:AbstractCache}, AbstractCache}
    # Can probably be eliminated and use getter functions from
    # Simulation object. Need to determine if its always available in the stage update steps.
    chronolgy_dict::Dict{Int64, <:FeedForwardChronology}
    function StageInternal(number, executions, execution_count, psi_container)
        new(
            number,
            executions,
            execution_count,
            Dict{Int64, Int64}(),
            psi_container,
            Dict{Type{<:AbstractCache}, AbstractCache}(),
            Dict{Int64, FeedForwardChronology}(),
        )
    end
end

@doc raw"""
    Stage({M<:AbstractOperationsProblem}
        template::OperationsProblemTemplate
        sys::PSY.System
        optimizer::JuMP.OptimizerFactory
        internal::Union{Nothing, StageInternal}
        )

""" # TODO: Add DocString
mutable struct Stage{M <: AbstractOperationsProblem}
    template::OperationsProblemTemplate
    sys::PSY.System
    optimizer::JuMP.OptimizerFactory
    internal::Union{Nothing, StageInternal}

    function Stage(
        ::Type{M},
        template::OperationsProblemTemplate,
        sys::PSY.System,
        optimizer::JuMP.OptimizerFactory,
    ) where {M <: AbstractOperationsProblem}

        new{M}(template, sys, optimizer, nothing)

    end
end

function Stage(
    template::OperationsProblemTemplate,
    sys::PSY.System,
    optimizer::JuMP.OptimizerFactory,
) where {M <: AbstractOperationsProblem}
    return Stage(GenericOpProblem, template, sys, optimizer)
end

get_execution_count(s::Stage) = s.internal.execution_count
get_executions(s::Stage) = s.internal.executions
get_sys(s::Stage) = s.sys
get_template(s::Stage) = s.template
get_number(s::Stage) = s.internal.number
get_psi_container(s::Stage) = s.internal.psi_container

#Defined here because it requires Stage to defined

initial_condition_update!(
    initial_condition_key::ICKey,
    ::Nothing,
    ini_cond_vector::Vector{InitialCondition},
    to_stage::Stage,
    from_stage::Stage,
) = nothing

function initial_condition_update!(
    initial_condition_key::ICKey,
    sync::T,
    ini_cond_vector::Vector{InitialCondition},
    to_stage::Stage,
    from_stage::Stage,
) where {T <: FeedForwardChronology}
    for ic in ini_cond_vector
        name = device_name(ic)
        var_value = get_stage_variable(T, (from_stage => to_stage), name, ic.update_ref)
        cache = isnothing(ic.cache_type) ? nothing :
            from_stage.internal.cache_dict[ic.cache_type]
        quantity = calculate_ic_quantity(initial_condition_key, ic, var_value, cache)
        PJ.fix(ic.value, quantity)
    end

    return
end
