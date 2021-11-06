"""

# cmdline 

Recursively parse the model to construct command line. 

### Method
```julia
cmdline(m, id)
```

### Required arguments
```julia
* `m::SampleModel`                     # CmdStanSampleModel
* `id::Int`                            # Chain id
```
"""
function cmdline(m::DiagnoseModel, id)
  
  #=
  `./bernoulli diagnose test=gradient epsilon=1.0e-6 error=1.0e-6 
  random seed=-1 id=1 data file=bernoulli_1.data.R 
  output file=bernoulli_diagnose_1.csv refresh=100`
  =#
  
  cmd = ``
   
  # Handle the model name field for unix and windows
  cmd = `$(m.exec_path)`

  # Diagnose specific portion of the model
  cmd = `$cmd diagnose`
  
  # Gradient specific portion of the model
  cmd = `$cmd test=$(string(m.test))`
  cmd = `$cmd epsilon=$(m.epsilon)`
  cmd = `$cmd error=$(m.error)`
  
  # Common to all models, not recursive
  cmd = `$cmd random seed=$(m.seed)`
  
  cmd = `$cmd id=$(id)`

  # Data file required?
  if length(m.data_file) > 0 && isfile(m.data_file[id])
    cmd = `$cmd data file=$(m.data_file[id])`
  end
  
  # Output files
  cmd = `$cmd output`
  if length(m.sample_file) > 0
    cmd = `$cmd file=$(m.sample_file[id])`
  end

  if length(m.diagnostic_file) > 0
    cmd = `$cmd diagnostic_file=$(m.diagnostic_file[id])`
  end

  cmd = `$cmd refresh=$(m.refresh)`
    
  
  cmd
  
end

