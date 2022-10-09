# --------------------------------------------------------------------------------------------------
# Aliases for types
#
const Times       = Union{Vector{<:Number}, StepRangeLen}
const States      = Vector{<:Vector{<:Number}}
const Adjoints    = Vector{<:Vector{<:Number}} #Union{Vector{<:Number}, Vector{<:Vector{<:Number}}, Matrix{<:Vector{<:Number}}}
const Controls    = Vector{<:Vector{<:Number}} #Union{Vector{<:Number}, Vector{<:Vector{<:Number}}}
const Time        = Number
const State       = Vector{<:Number}
const Adjoint     = Vector{<:Number}
const Dimension   = Integer

# --------------------------------------------------------------------------------------------------
# Optimal control problems
#
abstract type OptimalControlProblem end

# pretty print : https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing
mutable struct SimpleRegularOCP <: OptimalControlProblem
    description                 :: Description
    state_dimension             :: Union{Dimension, Nothing}
    control_dimension           :: Union{Dimension, Nothing}
    final_constraint_dimension  :: Union{Dimension, Nothing}
    Lagrange_cost               :: Function 
    dynamics                    :: Function
    initial_time                :: Time
    initial_condition           :: State
    final_time                  :: Time
    final_constraint            :: Function
end

# instantiation of the ocp: choose the right type depending upon the inputs
function OCP(   description...; # keyword arguments from here
                control_dimension           :: Dimension,
                Lagrange_cost               :: Function, 
                dynamics                    :: Function, 
                initial_condition           :: State, 
                final_time                  :: Time, 
                final_constraint            :: Function, # optional from here
                final_constraint_dimension  :: Union{Dimension, Nothing}=nothing,
                state_dimension             :: Union{Dimension, Nothing}=nothing,
                initial_time                :: Time=0.0)

    # create the right ocp type depending on inputs
    state_dimension = state_dimension===nothing ? length(initial_condition) : state_dimension 
    ocp = SimpleRegularOCP(makeDescription(description...), state_dimension, control_dimension, 
                final_constraint_dimension, Lagrange_cost, dynamics, initial_time, initial_condition, 
                final_time, final_constraint)
    
    return ocp

end

# --------------------------------------------------------------------------------------------------
# Display: text/html ?  
# Base.show, Base.print
function Base.show(io::IO, ocp::SimpleRegularOCP)

    dimx = ocp.state_dimension===nothing ? "n" : ocp.state_dimension
    dimu = ocp.control_dimension===nothing ? "m" : ocp.control_dimension
    dimc = ocp.final_constraint_dimension===nothing ? "p" : ocp.final_constraint_dimension

    desc = ocp.description

    println(io, "Optimal control problem of the form:")
    println(io, "")
    print(io, " minimize  J(x, u) = ")
    isnonautonomous(desc) ? 
          println(io, '\u222B', " L(t, x(t), u(t)) dt, over [t0, tf]") : 
          println(io, '\u222B', " L(x(t), u(t)) dt, over [t0, tf]")
    println(io, "")
    println(io, " subject to")
    println(io, "")
    isnonautonomous(desc) ? 
          println(io, "     x", '\u0307', "(t) = f(t, x(t), u(t)), t in [t0, tf] a.e.,") : 
          println(io, "     x", '\u0307', "(t) = f(x(t), u(t)), t in [t0, tf] a.e.,")
    println(io, "")
    println(io, "     c(x(tf)) = 0,")
    println(io, "")
    println(io, " where x(t) ", '\u2208' ," R", dimx==1 ? "" : Base.string("^", dimx),
          ", u(t) ", '\u2208' ," R", dimu==1 ? "" : Base.string("^", dimu),
          " and c(x) ", '\u2208' ," R", dimc==1 ? "" : Base.string("^", dimc),
           ".")
    println(io, "")
    println(io, " Besides, t0, tf and x0 are fixed. ")
    println(io, "")

end

# --------------------------------------------------------------------------------------------------
# Initialization
#
abstract type OptimalControlInit end

# --------------------------------------------------------------------------------------------------
# Solution
#
abstract type OptimalControlSolution end

# --------------------------------------------------------------------------------------------------
# Resolution
#
function solve(ocp::OptimalControlProblem, description...; kwargs...)
    method = getCompleteSolverDescription(makeDescription(description...))
    if :descent in method
        return solve_by_descent(ocp, method; kwargs...)
    else
        nothing
    end  
end

# --------------------------------------------------------------------------------------------------
# Description of the methods
#
#methods_desc = Dict(
#    :descent => "Descent method for optimal control problem"
#)