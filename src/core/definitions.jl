#################################################################################
#Type Alias for long type signatures
const MinMax = NamedTuple{(:min, :max),NTuple{2,Float64}}
const NamedMinMax = Tuple{String,MinMax}
const UpDown = NamedTuple{(:up, :down),NTuple{2,Float64}}
const InOut = NamedTuple{(:in, :out),NTuple{2,Float64}}

# Type Alias From other Packages
const PM = PowerModels
const PSY = PowerSystems
const PSI = PowerSimulations
const IS = InfrastructureSystems
const MOI = MathOptInterface
const MOIU = MathOptInterface.Utilities
const PJ = ParameterJuMP
const MOPFM = MOI.FileFormats.Model
const TS = TimeSeries

#Type Alias for JuMP and PJ containers
const JuMPExpressionMatrix = Matrix{<:JuMP.AbstractJuMPScalar}
const PGAE{V} = PJ.ParametrizedGenericAffExpr{Float64,V} where {V<:JuMP.AbstractVariableRef}
const GAE{V} = JuMP.GenericAffExpr{Float64,V} where {V<:JuMP.AbstractVariableRef}
const JuMPAffineExpressionArray = Matrix{GAE{V}} where {V<:JuMP.AbstractVariableRef}
const JuMPAffineExpressionVector = Vector{GAE{V}} where {V<:JuMP.AbstractVariableRef}
const JuMPConstraintArray = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}
const JuMPParamArray = JuMP.Containers.DenseAxisArray{PJ.ParameterRef}
const DSDA = Dict{Symbol,JuMP.Containers.DenseAxisArray}

# Tolerance of comparisons
const ComparisonTolerance = 1.0e-10

const OPERATIONS_ACCEPTED_KWARGS = [
    :horizon,
    :initial_conditions,
    :use_forecast_data,
    :use_parameters,
    :JuMPmodel,
    :optimizer,
    :PTDF,
]
const SIMULATION_BUILD_KWARGS = [:system_to_file, :PTDF_matrices]

# The constants below are strings instead of enums because there is a requirement that users
# should be able to define their own without changing PowerSimulations.

# Variables / Parameters
const ACTIVE_POWER = "P"
const ENERGY = "E"
const ENERGY_BUDGET = "energy_budget"
const FLOW_ACTIVE_POWER = "Fp"
const ON = "On"
const REACTIVE_POWER = "Q"
const ACTIVE_POWER_IN = "Pin"
const ACTIVE_POWER_OUT = "Pout"
const RESERVE = "R"
const SERVICE_REQUIREMENT = "service_requirement"
const START = "Start"
const STOP = "Stop"
const THETA = "theta"
const VM = "Vm"
const INFLOW = "In"
const SPILLAGE = "Sp"

# Constraints
const ACTIVE = "active"
const ACTIVE_RANGE = "activerange"
const ACTIVE_RANGE_LB = "activerange_lb"
const ACTIVE_RANGE_UB = "activerange_ub"
const COMMITMENT = "commitment"
const DURATION = "duration"
const DURATION_DOWN = "duration_dn"
const DURATION_UP = "duration_up"
const ENERGY_CAPACITY = "energy_capacity"
const ENERGY_LIMIT = "energy_limit"
const FEED_FORWARD = "FF"
const FEED_FORWARD_BIN = "FFbin"
const FLOW_LIMIT = "FlowLimit"
const FLOW_LIMIT_FROM_TO = "FlowLimitFT"
const FLOW_LIMIT_TO_FROM = "FlowLimitTF"
const FLOW_REACTIVE_POWER_FROM_TO = "FqFT"
const FLOW_REACTIVE_POWER_TO_FROM = "FqTF"
const FLOW_ACTIVE_POWER_FROM_TO = "FpFT"
const FLOW_ACTIVE_POWER_TO_FROM = "FpTF"
const INPUT_POWER_RANGE = "inputpower_range"
const OUTPUT_POWER_RANGE = "outputpower_range"
const RAMP = "ramp"
const RAMP_DOWN = "ramp_dn"
const RAMP_UP = "ramp_up"
const RATE_LIMIT = "RateLimit"
const RATE_LIMIT_FT = "RateLimitFT"
const RATE_LIMIT_TF = "RateLimitTF"
const REACTIVE = "reactive"
const REACTIVE_RANGE = "reactiverange"
const REQUIREMENT = "requirement"
const INFLOW_RANGE = "inflowrange"
