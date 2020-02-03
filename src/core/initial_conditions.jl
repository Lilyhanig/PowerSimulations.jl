struct DevicePower <: InitialConditionType end
struct DeviceStatus <: InitialConditionType end
struct TimeDurationON <: InitialConditionType end
struct TimeDurationOFF <: InitialConditionType end
struct DeviceEnergy <: InitialConditionType end

mutable struct InitialCondition{T<:Union{PJ.ParameterRef,Float64}}
    device::PSY.Device
    update_ref::UpdateRef
    value::T
    cache_type::Union{Nothing,Type{<:AbstractCache}}
end

function InitialCondition(
    device::PSY.Device,
    update_ref::UpdateRef,
    value::T,
) where {T<:Union{PJ.ParameterRef,Float64}}
    return InitialCondition(device, update_ref, value, nothing)
end

struct ICKey{IC<:InitialConditionType,D<:PSY.Device}
    ic_type::Type{IC}
    device_type::Type{D}
end

const InitialConditionsContainer = Dict{ICKey,Array{InitialCondition}}

function value(p::InitialCondition{Float64})
    return p.value
end

function value(p::InitialCondition{PJ.ParameterRef})
    return PJ.value(p.value)
end

get_condition(ic::InitialCondition) = ic.value

device_name(ini_cond::InitialCondition) = PSY.get_name(ini_cond.device)

#########################Initial Condition Updating#########################################
# TODO: Consider when more than one UC model is used for the stages that the counts need
# to be scaled.
function calculate_ic_quantity(
    initial_condition_key::ICKey{TimeDurationOFF,T},
    ic::InitialCondition,
    var_value::Float64,
    cache::Union{Nothing,AbstractCache},
) where {T<:PSY.Component}
    name = device_name(ic)
    time_cache = cache_value(cache, name)

    current_counter = time_cache[:count]
    last_status = time_cache[:status]
    var_status = isapprox(var_value, 0.0, atol = ComparisonTolerance) ? 0.0 : 1.0
    @assert abs(last_status - var_status) < ComparisonTolerance

    return last_status >= 1.0 ? current_counter : 0.0
end

function calculate_ic_quantity(
    initial_condition_key::ICKey{TimeDurationON,T},
    ic::InitialCondition,
    var_value::Float64,
    cache::Union{Nothing,AbstractCache},
) where {T<:PSY.Component}
    name = device_name(ic)
    time_cache = cache_value(cache, name)

    current_counter = time_cache[:count]
    last_status = time_cache[:status]
    var_status = isapprox(var_value, 0.0, atol = ComparisonTolerance) ? 0.0 : 1.0
    @assert abs(last_status - var_status) < ComparisonTolerance

    return last_status >= 1.0 ? 0.0 : current_counter
end

function calculate_ic_quantity(
    initial_condition_key::ICKey{DeviceStatus,T},
    ic::InitialCondition,
    var_value::Float64,
    cache::Union{Nothing,AbstractCache},
) where {T<:PSY.Component}
    return isapprox(var_value, 0.0, atol = ComparisonTolerance) ? 0.0 : 1.0
end

function calculate_ic_quantity(
    initial_condition_key::ICKey{DevicePower,T},
    ic::InitialCondition,
    var_value::Float64,
    cache::Union{Nothing,AbstractCache},
) where {T<:PSY.ThermalGen}
    if isnothing(cache)
        status_change_to_on =
            value(ic) <= ComparisonTolerance && var_value >= ComparisonTolerance
        status_change_to_off =
            value(ic) >= ComparisonTolerance && var_value <= ComparisonTolerance
    else
        name = device_name(ic)
        time_cache = cache_value(cache, name)
        status_change_to_on =
            time_cache[:status] >= ComparisonTolerance && var_value <= ComparisonTolerance
        status_change_to_off =
            time_cache[:status] <= ComparisonTolerance && var_value >= ComparisonTolerance
    end

    if status_change_to_on
        return ic.device.tech.activepowerlimits.min
    end

    if status_change_to_off
        return 0.0
    end

    return var_value
end
