# Femutils.jl
Parsing and plotting meshes

This is an attempt to use meshes of the [Fenics Project](https://fenicsproject.org/)'s 
[XML format](https://fenicsproject.org/pub/data/meshes/) with the 
[JuAFEM](https://github.com/KristofferC/JuAFEM.jl) framework.

The goal is to be able to do this:
```
grid = import_mesh("path/mesh.xml")
plot(grid)
```
