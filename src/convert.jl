# TODO facesets export
"""
Converts a JuAFEM grid to (nodes,connectivity) representation
"""
function juagrid2cm(grid::Grid)
    nodes = Array{Float64}(undef,length(grid.nodes),3)
    for (idx,n) in enumerate(grid.nodes)
        nodes[idx,:] .= n.x
    end

    # this is not very nice :( it also assumes that all cells
    # are of identical type
    nnodes = typeof(grid.cells[1]).parameters[2]

    connectivity = Array{Int32}(undef,length(grid.cells),nnodes)
    for (idx,c) in enumerate(grid.cells)
        connectivity[idx,:] .= c.nodes
    end

    (nodes, connectivity)
end
