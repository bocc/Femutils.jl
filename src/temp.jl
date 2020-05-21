using JuAFEM
using AbstractPlotting, Makie

grid = generate_grid(Triangle, (20, 20))

connectivity = vcat(collect.(getfield.(grid.cells,:nodes))'...)

nodes = vcat(collect.(getfield.(getfield.(grid.nodes,:x),:data))'...)

scene = Makie.mesh(nodes, connectivity, color = :ivory, shading = false)

Makie.wireframe!(scene[end][1], color = (:black, 0.6), linewidth = 1)

using LightXML
using Base.Iterators

gear = parse_file("C:/Users/Lenovo/Downloads/fem/gear.xml");

gear_root = root(gear);

mesh = gear_root["mesh"][1];

mesh_attributes = attributes_dict(mesh)

cells = mesh["cells"][1];
cells = cells[mesh_attributes["celltype"]];

@info "Cell type in this mesh: $(mesh_attributes["celltype"])"

connectivity = Array{Int64}(undef, size(cells)[1], 5)
for (idx, cell) in enumerate(cells)
    @views connectivity[idx,:] .= parse.(Int64, value.(attributes(cell)))
end

# 0 based to 1 based indexing
connectivity = connectivity[:,2:end] .+ 1

vertices = mesh["vertices"][1];
vertices = vertices["vertex"];

nodes_dim = parse(Int32, mesh_attributes["dim"])

@info "This mesh is $(nodes_dim)D"


nodes = Vector{Node{3,Float64}}(undef, size(nodes,1))
for (idx, vertex) in enumerate(vertices)
    (x,y,z) = parse.(Float64, value.(drop(attributes(vertex), 1)))
    nodes[idx] = Node((x,y,z))
end

connectivity = Vector{Tetrahedron}(undef, size(connectivity,1))
for (idx, r) in enumerate(eachrow(connectivity))
    connectivity[idx] = Tetrahedron((r[1],r[2],r[3],r[4]))
end


# c = Vector{Tetrahedron}(undef, size(connectivity,1))
# for (idx, r) in enumerate(eachrow(connectivity))
#     c[idx] = Tetrahedron((r[1],r[2],r[3],r[4]))
# end

# nodes = Array{Float64}(undef, size(vertices)[1], nodes_dim)
# @time for (idx, vertex) in enumerate(vertices)
#     @views nodes[idx,:] .= parse.(Float64, value.(drop(attributes(vertex), 1)))
# end

Grid(c,n)