# Plots

## GridVisualize/PlutoVista

Plotting is possible e.g. via [Nodal Evaluations](@ref) and the plot routines from
[ExtendableGrids.jl](https://github.com/WIAS-PDELib/ExtendableGrids.jl).
In Pluto notebooks it is recommended to use [PlutoVista.jl](https://github.com/j-fu/PlutoVista.jl) as an backend.


## UnicodePlots

For a fast and rough peak several UnicodePlots plotters are available via an extension (ExtendableFEMBaseUnicodePlotsExt)
that is loaded when UnicodePlots is available.

```@autodocs
Modules = [ExtendableFEMBase]
Pages = ["plots.jl"]
Order   = [:type, :function]
```
