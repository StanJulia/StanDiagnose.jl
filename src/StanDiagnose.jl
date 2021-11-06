"""

$(SIGNATURES)

Helper infrastructure to compile and sample models using `cmdstan`.
"""
module StanDiagnose

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

using StanBase, StanDump

import StanBase: update_model_file, par, handle_keywords!
import StanBase: executable_path, ensure_executable, stan_compile
import StanBase: update_R_files
import StanBase: data_file_path, init_file_path, sample_file_path
import StanBase: generated_quantities_file_path, log_file_path
import StanBase: diagnostic_file_path, setup_diagnostics

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
