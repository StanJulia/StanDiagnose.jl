"""

# cmdline 

Recursively parse the model to construct command line. 

### Method
```julia
cmdline(m)
```

### Required arguments
```julia
* `m::SampleModel`                : CmdStanSampleModel
```
"""
function cmdline(m::Union{DiagnoseModel, Diagnose, Gradient, StanBase.RandomSeed}, id)
  
  #=
  `./bernoulli diagnose test=gradient epsilon=1.0e-6 error=1.0e-6 
  random seed=-1 id=1 data file=bernoulli_1.data.R 
  output file=bernoulli_diagnose_1.csv refresh=100`
  =#
  
  cmd = ``
  if isa(m, DiagnoseModel)
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    # Sample() specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method), id))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :seed), id))`
    
    # Init file required?
    if length(m.init_file) > 0 && isfile(m.init_file[id])
      cmd = `$cmd init=$(m.init_file[id])`
    else
      cmd = `$cmd init=$(m.init.bound)`
    end
    
    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      cmd = `$cmd id=$(id) data file=$(m.data_file[id])`
    end
    
    # Output options
    cmd = `$cmd output`
    if length(getfield(m, :output).file) > 0
      cmd = `$cmd file=$(string(getfield(m, :output).file))`
    end
    if length(m.diagnostic_file) > 0
      cmd = `$cmd diagnostic_file=$(string(getfield(m, :output).diagnostic_file))`
    end
    cmd = `$cmd refresh=$(string(getfield(m, :output).refresh))`
    
  else
    
    # The 'recursive' part
    if isa(m, Diagnose)
      cmd = `$cmd algorithm=$(split(lowercase(string(typeof(m))), '.')[end])`
    else
      if typeof(m) == StanBase.RandomSeed
        cmd = `$cmd random`
      else
        cmd = `$cmd $(split(lowercase(string(typeof(m))), '.')[end])`
      end
    end
    for name in fieldnames(typeof(m))
      if  isa(getfield(m, name), String) || isa(getfield(m, name), Tuple)
        cmd = `$cmd $(name)=$(getfield(m, name))`
      elseif length(fieldnames(typeof(getfield(m, name)))) == 0
        if isa(getfield(m, name), Bool)
          cmd = `$cmd $(name)=$(getfield(m, name) ? 1 : 0)`
        else
          if name == :metric || isa(getfield(m, name), DataType)
            cmd = `$cmd $(name)=$(split(lowercase(string(typeof(getfield(m, name)))), '.')[end])`
          else
            cmd = `$cmd $(name)=$(getfield(m, name))`
          end
        end
      else
        cmd = `$cmd $(cmdline(getfield(m, name), id))`
      end
    end
  end
  
  cmd
  
end

