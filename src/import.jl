module Import

using Femutils

using LightXML
using JuAFEM
using Base.Iterators

export import_grid

# TODO quadratic versions
cell_types = Dict(
    "line" => Line,
    "triangle" => Triangle,
    "quadrilateral" => Quadrilateral,
    "tetrahedron" => Tetrahedron,
    "hexahedron" => Hexahedron,
)

struct MeshXML
    vertices
    cells
    dim::Int
    celltype
end

# TODO find a way to dispatch on expected output format (connectivity/JuAFEM)
# TODO handle mixed type meshes

"""
Import a Fenics grid as either raw `(nodes,connectivity_matrix)` or as JuAFEM's
`Grid`. The `output` keyword argument can be set to :`connectivity_matrix` (default) 
or :`juafem_grid`.
"""
function import_grid(path::AbstractString; output=:connectivity_matrix)
xml_mesh = parse_XML(path)

if output == :connectivity_matrix
    mesh = import_connectivity(xml_mesh)
elseif output == :juafem_grid
    mesh = import_juafem(xml_mesh)
else
    error("Expected output format $output was not recognized.")
end

    return mesh
end

function parse_XML(path::AbstractString)
    isfile(path) || error("$path not found.")

    xml = parse_file(path)

    xml_root = root(xml)

    mesh = xml_root["mesh"][1]
    
    mesh_attributes = attributes_dict(mesh)
    ["celltype","dim"] ⊆ keys(mesh_attributes) || error("Mesh info missing.")

    cells = mesh["cells"][1];
    cells = cells[mesh_attributes["celltype"]];

    vertices = mesh["vertices"][1];
    vertices = vertices["vertex"];

    mesh_attributes["celltype"] ∈ keys(cell_types) || 
        error("Cell type '$(mesh_attributes["celltype"])' not recognized.")

    mesh_dim = parse(Int32, mesh_attributes["dim"])

    mesh_dim ∈ [1,2,3] || error("Found a mesh dimension outside of 2 and 3.")

    MeshXML(vertices,cells,mesh_dim,cell_types[mesh_attributes["celltype"]])
end

function import_connectivity(raw::MeshXML)
    # nodes
    nodes = Array{Float64}(undef, size(raw.vertices,1), raw.dim)

    for (idx, vertex) in enumerate(raw.vertices)
        p = parse.(Float64, value.(drop(attributes(vertex), 1)))

        nodes[idx,:] .= p
    end

    # cells
    n = JuAFEM.nnodes(raw.celltype)

    connectivity = Array{Int32}(undef,size(raw.cells,1),n)
    for (idx, cell) in enumerate(raw.cells)
        # 0-based to 1-based indexing, skip first column
        p = parse.(Int32, value.(attributes(cell))) .+ 1

        connectivity[idx,:] .= p[2:end]
    end

    (nodes, connectivity)    
end

function import_juafem(raw::MeshXML)
    # nodes
    nodes = Vector{Node{raw.dim,Float64}}(undef, size(raw.vertices,1))
    for (idx, vertex) in enumerate(raw.vertices)
        p = parse.(Float64, value.(drop(attributes(vertex), 1)))

        nodes[idx] = Node(Tuple(p))
    end

    # cells
    connectivity = Vector{raw.celltype}(undef, size(raw.cells,1))
    for (idx, cell) in enumerate(raw.cells)
        # 0-based to 1-based indexing, skip first column
        p = parse.(Int64, value.(attributes(cell))) .+ 1

        connectivity[idx] = raw.celltype(Tuple(p[2:end]))
    end

    Grid(connectivity,nodes)
end

end # module