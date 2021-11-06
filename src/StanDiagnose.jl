"""

$(SIGNATURES)

Helper infrastructure to compile and sample models using `cmdstan`.
"""
module StanDiagnose

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

using StanBase, StanDump

import StanBase: update_model_file, par, handle_keywords!
import StanBase: executable_path, ensure_executable, stan_compile

include("stanmodel/DiagnoseModel.jl")

include("stanrun/stan_run.jl")
include("stanrun/cmdline.jl")

include("stansamples/read_diagnose.jl")

stan_diagnose = stan_run

export
  DiagnoseModel,
  stan_diagnose,
  read_diagnose

end # module
