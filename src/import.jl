module Import

using LightXML
using JuAFEM
using Base.Iterators

export import_grid

function import_grid(path::AbstractString)::Grid
    isfile(path) || error("$path not found.")

    # TODO quadratic versions
    cell_types = Dict(
        "line" => Line,
        "triangle" => Triangle,
        "quadrilateral" => Quadrilateral,
        "tetrahedron" => Tetrahedron,
        "hexahedron" => Hexahedron,
    )
    
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

    @info "Cell type in this mesh: $(mesh_attributes["celltype"])"

    mesh_dim = parse(Int32, mesh_attributes["dim"])

    mesh_dim ∈ [2,3] || error("Found a mesh dimension outside of 2 and 3.")

    @info "This mesh is $(mesh_dim)D"

    # nodes
    nodes = Vector{Node{3,Float64}}(undef, size(vertices,1))
    for (idx, vertex) in enumerate(vertices)
        p = parse.(Float64, value.(drop(attributes(vertex), 1)))

        nodes[idx] = Node{3,Float64}(Tuple(p))
    end

    # cells
    cell_type = cell_types[mesh_attributes["celltype"]]

    connectivity = Vector{cell_type}(undef, size(cells,1))
    for (idx, cell) in enumerate(cells)
        # 0-based to 1-based indexing, skip first column
        p = parse.(Int64, value.(attributes(cell))) .+ 1

        connectivity[idx] = cell_type(Tuple(p[2:end]))
    end

    Grid(connectivity,nodes)
end

end