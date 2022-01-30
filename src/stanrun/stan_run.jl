"""

stan_sample()

Draw from a StanJulia SampleModel (<: CmdStanModel.)

## Required argument
```julia
* `m <: CmdStanModels`                 # SampleModel.
* `use_json=true`                      # Use JSON3 for data and init files
* `check_num_chains=true`              # Check for correct Julia chains and C++ chains
```

### Most frequently used keyword arguments
```julia
* `data`                               # Observations Dict or NamedTuple.
* `init`                               # Init Dict or NT (default: -2 to +2).
```

### Returns
```julia
* `rc`                                 # Return code, 0 is success.
```

See extended help for other keyword arguments ( `??stan_sample` ).

# Extended help

### Additional configuration keyword arguments
```julia
* `num_chains=4`                       # Update number of chains.

* `num_samples=1000`                   # Number of samples.
* `num_warmups=1000`                   # Number of warmup samples.
* `save_warmup=false`                  # Save warmup samples.

* `thin=1`                             # Set thinning value.
* `refresh=100`                        # Output refresh rate.
* `seed=-1`                            # Set seed value.

* `test=:gradient`                     # Test :gradient.
* `epsilon=1e-8`                       # Finite difference step size.
* `error=1e-8`                         # Error threshold.
```
"""
function stan_run(m::T, 
    use_json=true,
    check_num_chains=true; kwargs...) where {T <: CmdStanModels}

    handle_keywords!(m, kwargs, check_num_chains)
    
    # Diagnostics files requested?
    diagnostics = false
    if :diagnostics in keys(kwargs)
        diagnostics = kwargs[:diagnostics]
        setup_diagnostics(m, m.num_chains)
    end

    # Remove existing sample files
    for id in 1:m.num_chains
        sfile = sample_file_path(m.output_base, id)
        isfile(sfile) && rm(sfile)
    end

    if use_json
        :init in keys(kwargs) && update_json_files(m, kwargs[:init],
            m.num_chains, "init")
        :data in keys(kwargs) && update_json_files(m, kwargs[:data],
            m.num_chains, "data")
    else
        :init in keys(kwargs) && update_R_files(m, kwargs[:init],
            m.num_chains, "init")
        :data in keys(kwargs) && update_R_files(m, kwargs[:data],
            m.num_chains, "data")
    end

    m.cmds = [stan_cmds(m, id; kwargs...) for id in 1:m.num_chains]

    #println(typeof(m.cmds))
    #println()
    #println(m.cmds)

    run(pipeline(par(m.cmds), stdout=m.log_file[1]))
end

"""

Generate a cmdstan command line (a run `cmd`).

$(SIGNATURES)

Internal, not exported.
"""
function stan_cmds(m::T, id::Integer; kwargs...) where {T <: CmdStanModels}
    append!(m.sample_file, [sample_file_path(m.output_base, id)])
    append!(m.log_file, [log_file_path(m.output_base, id)])
    if length(m.diagnostic_file) > 0
      append!(m.diagnostic_file, [diagnostic_file_path(m.output_base, id)])
    end
    cmdline(m, id)
end
