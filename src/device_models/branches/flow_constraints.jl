function thermalflowlimits(m::JuMP.Model, system_formulation::Type{S}, devices::Array{B,1}, time_periods::Int64) where {B <: PowerSystems.Branch, S <: PM.AbstractDCPForm}

    fbr = m[:fbr]
    name_index = m[:fbr].axes[1]
    time_index = m[:fbr].axes[2]

    Flow_max_tf = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index), time_periods), name_index, time_index)
    Flow_max_ft = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index), time_periods), name_index, time_index)

    for t in time_index, (ix, name) in enumerate(name_index)
        if name == devices[ix].name
            Flow_max_tf[name, t] = @constraint(m, fbr[name, t] <= devices[ix].rate.to_from)
            Flow_max_ft[name, t] = @constraint(m, fbr[name, t] >= -1*devices[ix].rate.from_to)
        else
            error("Branch name in Array and variable do not match")
        end
    end

    JuMP.register_object(m, :Flow_max_ToFrom, Flow_max_tf)
    JuMP.register_object(m, :Flow_max_FromTo, Flow_max_ft)

    return m
end

function thermalflowlimits(m::JuMP.Model, system_formulation::Type{S}, devices::Array{B,1}, time_periods::Int64) where {B <: PowerSystems.Branch, S <: PM.AbstractDCPLLForm}

    fbr_fr = m[:fbr_fr]
    fbr_to = m[:fbr_to]
    name_index = m[:fbr_fr].axes[1]
    time_index = m[:fbr_to].axes[2]

    Flow_max_tf = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index), time_periods), name_index, time_index)
    Flow_max_ft = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index), time_periods), name_index, time_index)

    for t in time_index, (ix, name) in enumerate(name_index)
        if name == devices[ix].name
            Flow_max_tf[name, t] = @constraint(m, fbr_fr[name, t] <= devices[ix].rate.to_from)
            Flow_max_ft[name, t] = @constraint(m, fbr_to[name, t] >= -1*devices[ix].rate.from_to)
        else
            error("Branch name in Array and variable do not match")
        end
    end

    JuMP.register_object(m, :Flow_max_ToFrom, Flow_max_tf)
    JuMP.register_object(m, :Flow_max_FromTo, Flow_max_ft)

    return m
end

#TODO: Implement Limits in AC. Use Norm from JuMP Implemented norms. 