[![Build status](https://github.com/chmerdon/ExtendableFEMBase.jl/workflows/linux-macos-windows/badge.svg)](https://github.com/chmerdon/ExtendableFEMBase.jl/actions)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://chmerdon.github.io/ExtendableFEMBase.jl/stable/index.html)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://chmerdon.github.io/ExtendableFEMBase.jl/dev/index.html)

# ExtendableFEMBase

This package provides basic finite element structures to setup finite element schemes on ExtendableGrids. For a full high-level API
see [ExtendableFEM.jl](https://github.com/chmerdon/ExtendableFEM.jl).

This low level structures in the package incorporate:

- Finite element types (Basis functions on reference geometries and dof management for several H1, Hdiv and Hcurl elements)
- FESpace (Discrete finite element space with respect to a mesh from ExtendableGrids, knows the Dofmaps)
- FEMatrix (block overlay for an ExtendableSparse matrix, where each block corresponds to a coupling between two FESpaces in a system)
- FEVector (block overlay for an array, where each block corresponds to a FESpace)
- FunctionOperators (primitive linear operators like Identity, Gradient, Divergence) and rules how to evaluate them for for different finite element types
- FEEvaluator (finite element basis evaluators for different FunctionOperators and entities of the grid)
- QuadratureRule (basic quadrature rules for different ElementGeometries from ExtendableGrids)
- interpolations (standard interpolations into the provided finite element spaces, averaging routines and interpolations between meshes/FESpaces)
- reconstruction operators (special FunctionOperators that involve an interpolation into a different finite element type)
  
  
