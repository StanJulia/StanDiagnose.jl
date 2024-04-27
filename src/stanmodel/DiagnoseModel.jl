import Base: show

mutable struct DiagnoseModel <: CmdStanModels
    name::AbstractString;              # Name of the Stan program
    model::AbstractString;             # Stan language model program

    # Sample fields
    num_chains::Int64;                 # Number of chains
    num_threads::Int64;                # Number of threads

    seed::Int;                         # Seed section of cmd to run cmdstan
    refresh::Int;                      # Display progress in output files
    init_bound::Int;                   # Bound for initial param values

    # Check model gradient against finite difference
    test::Symbol;                      # :gradient
                                       
    epsilon::Float64;                  # Finite difference step size
    error::Float64;                    # Error threshold

    output_base::AbstractString;       # Used for file paths to be created
    tmpdir::AbstractString;            # Holds all created files
    exec_path::AbstractString;         # Path to the cmdstan excutable
    data_file::Vector{AbstractString}; # Array of data files input to cmdstan
    init_file::Vector{AbstractString}; # Array of init files input to cmdstan
    cmds::Vector{Cmd};                 # Array of cmds to be spawned/pipelined
    sample_file::Vector{String};       # Sample file array (.csv)
    log_file::Vector{String};          # Log file array
    diagnostic_file::Vector{String};   # Diagnostic file array
    cmdstan_home::AbstractString;      # Directory where cmdstan can be found
end

"""
# DiagnoseModel 

Create a DiagnoseModel and compile the Stan Language Model.. 

### Required arguments
```julia
* `name::AbstractString`        : Name for the model
* `model::AbstractString`       : Stan model source
```

### Optional positional argument
```julia
 `tmpdir::AbstractString`             : Directory where output files are stored
```

"""
function DiagnoseModel(
  name::AbstractString,
  model::AbstractString,
  tmpdir = mktempdir())
  
  !isdir(tmpdir) && mkdir(tmpdir)
  
  update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  
  output_base = joinpath(tmpdir, name)
  exec_path = executable_path(output_base)
  cmdstan_home = CMDSTAN_HOME

  error_output = IOBuffer()
  is_ok = cd(cmdstan_home) do
      success(pipeline(`$(make_command()) -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`;
                       stderr = error_output))
  end
  if !is_ok
      throw(StanModelError(model, String(take!(error_output))))
  end

  DiagnoseModel(name, model, 
    4,                                 # num_chains
    4,                                 # num_threads

    -1,                                # seed
    100,                               # refresh
    2,                                 # init_bound

    :gradient,                         # Test argument
    1e-6,                              # Epsilon
    1e-6,                              # Error                        
    
    output_base,                       # Path to output files
    tmpdir,                            # Tmpdir settings
    exec_path,                         # exec_path
    AbstractString[],                  # Data files
    AbstractString[],                  # Init files
    Cmd[],                             # Command lines
    String[],                          # Sample .csv files
    String[],                          # Log files
    String[],                          # Diagnostic files
    cmdstan_home)
end

function Base.show(io::IO, ::MIME"text/plain", m::DiagnoseModel)
    println(io, "\nDiagnose section:")
    println(io, "  name =                    ", m.name)
    println(io, "  num_chains =              ", m.num_chains)
    println(io, "  num_threads =             ", m.num_threads)
    println(io, "  seed =                    ", m.seed)
    println(io, "  refresh =                 ", m.refresh)
    println(io, "  init_bound =              ", m.init_bound)

    println(io, "\nGradient section:")
    println(io, "  test =                    ", m.test)
    println(io, "  epsilon =                 ", m.epsilon)
    println(io, "  error =                   ", m.error)

    println(io, "\nOther:")
    println(io, "  output_base =             ", m.output_base)
    println(io, "  tmpdir =                  ", m.tmpdir)
end
