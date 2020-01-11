"""

$(SIGNATURES)

Helper infrastructure to compile and sample models using `cmdstan`.
"""
module StanDiagnose

using StanBase
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanBase: stan_sample, get_cmdstan_home
import StanBase: cmdline, stan_summary, read_summary
import StanBase: RandomSeed, Init, Output

include("stanmodel/diagnose_types.jl")
include("stanmodel/DiagnoseModel.jl")
include("stanrun/cmdline.jl")
include("stansamples/read_diagnose.jl")

stan_diagnose = stan_sample

export
  DiagnoseModel,
  stan_diagnose,
  read_diagnose,
  read_summary,
  stan_summary

end # module
