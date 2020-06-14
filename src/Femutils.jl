module Femutils

export find_boundary, import_grid, juagrid2cm

using LightXML
using JuAFEM
using Base.Iterators

include("boundary.jl")
using .Boundary

include("import.jl")
include("convert.jl")

# include("plot.jl")

end # module
