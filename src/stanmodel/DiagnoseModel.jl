"""
# OptimizeModel 

Create a DiagnoseModel. 

### Required arguments
```julia
* `name::AbstractString`        : Name for the model
* `model::AbstractString`       : Stan model source
```

### Optional arguments
```julia
* `n_chains::Vector{Int64}=[4]`        : Optionally updated in stan_sample()
* `seed::RandomSeed`                     : Random seed settings
* `output::Output`              : File output options
* `init::Init`                         : Default interval bound for parameters
* `tmpdir::AbstractString`             : Directory where output files are stored
* `output_base::AbstractString`        : Base name for output files
* `exec_path::AbstractString`          : Path to cmdstan executable
* `data_file::vector{AbstractString}`  : Path to per chain data file
* `init_file::Vector{AbstractString}`  : Path to per chain init file
* `cmds::Vector{Cmd}`                  : Path to per chain init file
* `sample_file::Vector{String}         : Path to per chain samples file
* `log_file::Vector{String}            : Path to per chain log file
* `diagnostic_file::Vector{String}    : Path to per chain diagnostic file
* `summary=true`                       : Create computed stan summary
* `printsummary=true`                  : Show computed stan summary
* `sm::StanRun.StanModel`              : StanRun.StanModel
* `method::Diagnose`                   : Fix Optimize
```

"""
mutable struct DiagnoseModel <: CmdStanModels
  @shared_fields_stanmodels
  method::Optimize
end

function OptimizeModel(
  name::AbstractString,
  model::AbstractString,
  n_chains=[4];
  method = Diagnose(),
  seed = StanBase.RandomSeed(),
  init = StanBase.Init(),
  output = StanBase.Output(),
  tmpdir = mktempdir())
  
  !isdir(tmpdir) && mkdir(tmpdir)
  
  StanBase.update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  sm = StanModel(joinpath(tmpdir, "$(name).stan"))
  
  output_base = StanRun.default_output_base(sm)
  exec_path = StanRun.ensure_executable(sm)
  
  stan_compile(sm)
  
  DiagnoseModel(name, model, n_chains, seed, init, output,
    tmpdir, output_base, exec_path, String[], String[], 
    Cmd[], String[], String[], String[], false, false, sm, method)
end

function diagnose_show(io::IO, m::DiagnoseModel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  n_chains =                $(StanBase.get_n_chains(m))")
  println("  output =                  Output()")
  println("    file =                    \"$(m.output.file)\"")
  println("    diagnostics_file =        \"$(m.output.diagnostic_file)\"")
  println("    refresh =                 $(m.output.refresh)")
  println("  tmpdir =                  \"$(m.tmpdir)\"")
  optimize_show(io, m.method, compact)
end

show(io::IO, m::DiagnoseModel) = diagnose_show(io, m, false)
