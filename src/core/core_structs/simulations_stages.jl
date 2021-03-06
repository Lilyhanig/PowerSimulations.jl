######## Internal Simulation Object Structs ########
abstract type AbstractStage end

mutable struct _Stage{M<:AbstractOperationsProblem} <: AbstractStage
    key::Int64
    reference::OperationsTemplate
    op_problem::Type{M}
    sys::PSY.System
    canonical::Canonical
    optimizer::JuMP.OptimizerFactory
    executions::Int64
    execution_count::Int64
    interval::Dates.Period
    chronology_ref::Dict{Int64, <:Chronology}
    ini_cond_chron::Union{<:Chronology, Nothing}
    cache::Dict{Type{<:AbstractCache}, AbstractCache}

    function _Stage(key::Int64,
                    reference::OperationsTemplate,
                    op_problem::Type{M},
                    sys::PSY.System,
                    canonical::Canonical,
                    optimizer::JuMP.OptimizerFactory,
                    executions::Int64,
                    interval::Dates.Period,
                    chronology_ref::Dict{Int64, <:Chronology},
                    cache::Vector{<:AbstractCache}) where M <: AbstractOperationsProblem

    ini_cond_chron = get(chronology_ref, 0, nothing)
    if !isempty(get_initial_conditions(canonical))
        if isnothing(ini_cond_chron)
            @warn("Initial Conditions chronology set for Stage $(key) which contains Initial conditions")
        end
    end

    pop!(chronology_ref, 0, nothing)

    cache_dict = Dict{Type{<:AbstractCache}, AbstractCache}()
    for c in cache
        cache_dict[typeof(c)] = c
    end


    new{M}(key,
           reference,
           op_problem,
           sys,
           canonical,
           optimizer,
           executions,
           0,
           interval,
           chronology_ref,
           ini_cond_chron,
           cache_dict)

    end

end

######## Exposed Structs to define a Simulation Object ########

mutable struct Stage <: AbstractStage
    op_problem::Type{<:AbstractOperationsProblem}
    model::OperationsTemplate
    initial_time::Dates.DateTime
    horizon::Int64
    interval::Dates.Period
    execution_count::Int64
    sys::PSY.System
    optimizer::JuMP.OptimizerFactory
    chronology_ref::Dict{Int64, <:Chronology}
    cache::Vector{<:AbstractCache}

    function Stage(::Type{M},
                   model::OperationsTemplate,
                   initial_time::Dates.DateTime,
                   horizon::Int64,
                   interval::Dates.Period,
                   execution_count::Int64,
                   sys::PSY.System,
                   optimizer::JuMP.OptimizerFactory,
                   chronology_ref=Dict{Int, <:Chronology}(),
                   cache::Vector{<:AbstractCache}=Vector{AbstractCache}()) where M<:AbstractOperationsProblem

        new(M,
            model,
            initial_time,
            horizon,
            interval,
            execution_count,
            sys,
            optimizer,
            chronology_ref,
            cache)
    end

end

function Stage(::Type{M},
               model::OperationsTemplate,
               horizon::Int64,
               interval::Dates.Period,
               execution_count::Int64,
               sys::PSY.System,
               optimizer::JuMP.OptimizerFactory,
               chronology_ref::Dict{Int64, <:Chronology},
               cache::Union{Nothing, AbstractCache}=nothing;
               kwargs...) where M<:AbstractOperationsProblem

    initial_time = get(kwargs, :initial_time, PSY.get_forecast_initial_times(sys)[1])
    cacheinput = isnothing(cache) ? Vector{AbstractCache}() : [cache]
    return Stage(M, 
                model,
                initial_time,
                horizon,
                interval,
                execution_count,
                sys,
                optimizer,
                chronology_ref,
                cacheinput)

end

function Stage(model::OperationsTemplate,
               horizon::Int64,
               interval::Dates.Period,
               execution_count::Int64,
               sys::PSY.System,
               optimizer::JuMP.OptimizerFactory,
               chronology_ref::Dict{Int64, <:Chronology},
               cache::Union{Nothing, AbstractCache}=nothing;
               kwargs...)
    
    initial_time = get(kwargs, :initial_time, PSY.get_forecast_initial_times(sys)[1])
    return Stage(GenericOpProblem,
                model,
                horizon,
                interval,
                execution_count,
                sys,
                optimizer,
                chronology_ref,
                cache; initial_time = initial_time, kwargs...)

end

get_execution_count(s::S) where S <: AbstractStage = s.execution_count
get_sys(s::S) where S <: AbstractStage = s.sys
get_chronology_ref(s::S) where S <: AbstractStage = s.chronology_ref

get_template(s::Stage) = s.model
