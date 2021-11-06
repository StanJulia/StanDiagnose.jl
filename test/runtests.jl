using StanDiagnose
using Test

if haskey(ENV, "JULIA_CMDSTAN_HOME")

  ProjDir = dirname(@__FILE__)

  bernoulli_model = "
  data { 
    int<lower=0> N; 
    int<lower=0,upper=1> y[N];
  } 
  parameters {
    real<lower=0,upper=1> theta;
  } 
  model {
    theta ~ beta(1,1);
      y ~ bernoulli(theta);
  }
  "
  data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

  @testset "Bernoulli diagnose" begin

    stanmodel = DiagnoseModel("bernoulli", bernoulli_model);
    rc = stan_diagnose(stanmodel; data);

    if success(rc)
      diags = read_diagnose(stanmodel)
      tmp = diags[:error][1]
      @test round.(tmp, digits=6) ≈ 0.0
    end
    
    stanmodel = DiagnoseModel("bernoulli", bernoulli_model);
    rc2 = stan_diagnose(stanmodel; data);

    if success(rc2)
      diags = read_diagnose(stanmodel)
      tmp = diags[:error][1]
      @test round.(tmp, digits=6) ≈ 0.0
    end
  end

else
  println("\nJULIA_CMDSTAN_HOME not set. Skipping tests")
end
