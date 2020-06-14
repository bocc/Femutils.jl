# TODO quadratic versions
cell_types = Dict(
    "line" => Line,
    "triangle" => Triangle,
    "quadrilateral" => Quadrilateral,
    "tetrahedron" => Tetrahedron,
    "hexahedron" => Hexahedron,
)

struct MeshInfo
    dim::Int
    celltype
end

# TODO handle mixed type meshes

"""
Import a Fenics grid as either raw `(nodes,connectivity_matrix)` or as JuAFEM's
`Grid`. The `output` keyword argument can be set to :`connectivity_matrix` (default) 
or :`juafem_grid`.
"""
function import_grid(path::AbstractString; output=:connectivity_matrix)
    output ∈ [:connectivity_matrix,:juafem_grid] ||
        error("Expected output format $output was not recognized.")

    (nodes,connectivity,mesh_info) = parse_XML(path)

    if output == :connectivity_matrix
        mesh = (nodes, connectivity)
    elseif output == :juafem_grid
        mesh = cm2juafem(nodes,connectivity,mesh_info)
    end

    return mesh
end

function parse_XML(path::AbstractString)
    isfile(path) || error("$path not found.")

    xml = parse_file(path)

    xml_root = root(xml);

    mesh = xml_root["mesh"][1];
    
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

    # nodes
    nodes = Array{Float64}(undef, size(vertices,1), mesh_dim)
    for (idx, vertex) in enumerate(vertices)
        p = parse.(Float64, value.(drop(attributes(vertex), 1)))

        nodes[idx,:] .= p
    end

    # cells
    n = JuAFEM.nnodes(cell_types[mesh_attributes["celltype"]])

    connectivity = Array{Int32}(undef,size(cells,1),n)
    for (idx, cell) in enumerate(cells)
        # 0 to 1-based indexing, skip first column
        p = parse.(Int32, value.(attributes(cell))) .+ 1

        connectivity[idx,:] .= p[2:end]
    end

    (nodes, connectivity, MeshInfo(mesh_dim,cell_types[mesh_attributes["celltype"]]))    
end

# TODO this should be in the conversion part
function cm2juafem(nodes, connectivity, mesh_info::MeshInfo)
    dim = mesh_info.dim
    celltype = mesh_info.celltype

    boundary = find_boundary(connectivity)

    boundary_matrix = JuAFEM.boundaries_to_sparse(boundary)

    # nodes
    vertices = Vector{Node{dim,Float64}}(undef, size(nodes,1))
    for (idx, r) in enumerate(eachrow(nodes))
        vertices[idx] = Node(Tuple(r))
    end

    # cells
    cells = Vector{celltype}(undef, size(connectivity,1))
    for (idx, r) in enumerate(eachrow(connectivity))
        cells[idx] = celltype(Tuple(r))
    end

    return Grid(cells, vertices, boundary_matrix=boundary_matrix)
end
