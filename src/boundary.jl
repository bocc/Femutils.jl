module Boundary

export find_boundary

"""
Find boundary cells & faces in a tetrahedral mesh, given it's
connectivity matrix. Boundary faces are ones which only belong to
a single tetrahedron in the mesh.

Returns a vector of (cell_idx, face_idx) tuples.
"""
function find_boundary(connectivity::Matrix{T}) where T <: Integer
    # faces = [
    #     1 2 3;
    #     1 2 4;
    #     1 3 4;
    #     1 4 3;
    # ]

    # tetrahedron
    faces = Dict(1 => [1,2,3], 2 => [1,2,4], 3 => [2,3,4], 4 => [1,4,3])
    # TODO triangle, quadrilateral, etc

    h = Dict{Vector,Tuple}()
    for (t, r) in enumerate(eachrow(connectivity))
        for f in keys(faces)
    
            # we want to neglect face orientations
            key = sort(r[faces[f]])
    
            if haskey(h, key)
                delete!(h,key)
            else
                h[key] = (t,f)
            end
        end
    end
    
    boundary = sort(collect(values(h)), by = x -> (x[1],x[2]))
end

end # module
