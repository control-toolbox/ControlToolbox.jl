# ocp solution to use a close init to the solution
N  = 1001
U⁺ = range(6.0, stop=-6.0, length=N); # solution
U⁺ = U⁺[1:end-1];

# ocp description
t0 = 0.0                # t0 is fixed
tf = 1.0                # tf is fixed
x0 = [-1.0; 0.0]        # the initial condition is fixed
xf = [ 0.0; 0.0]        # the target
A  = [0.0 1.0
      0.0 0.0]
B  = [0.0; 1.0]
f(x, u) = A*x+B*u[1];  # dynamics
L(x, u) = 0.5*u[1]^2   # integrand of the Lagrange cost

# ocp definition
ocp = OCP(L, f, t0, x0, tf, xf, 2, 1)

# initial iterate
U_init = U⁺-1e0*ones(N-1); U_init = [ [U_init[i]] for i=1:N-1 ]

# resolution
sol = solve(ocp, :descent, init=U_init, 
                  grid_size=N, penalty_constraint=1e4, iterations=5, step_length=1, display=false)

plot(sol)

@testset "Descent - Solve" begin
    @test typeof(sol) == DescentOCPSol
end