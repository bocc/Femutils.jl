module Femutils

abstract type MeshType end

abstract type ConnectivityMatrix <: MeshType end
abstract type JuAFEMGrid <: MeshType end

export MeshType, ConnectivityMatrix, JuAFEMGrid

# submodules are used here to avoid namespace collisions
include("import.jl")

using .Import
export import_grid

include("convert.jl")

using .Convert
export juagrid2cm

include("boundary.jl")

using .Boundary
export find_boundary

# include("plot.jl")

end # module
