"""
````
abstract type HCURLN1{edim} <: AbstractHcurlFiniteElement where {edim<:Int}
````

Hcurl-conforming vector-valued (ncomponents = edim) Nedelec space of first kind and order 1.

allowed ElementGeometries:
- Triangle2D
"""
abstract type HCURLN1{edim} <: AbstractHcurlFiniteElement where {edim <: Int} end

function Base.show(io::Core.IO, ::Type{<:HCURLN1{edim}}) where {edim}
	print(io, "HCURLN1{$edim}")
end

get_ncomponents(FEType::Type{<:HCURLN1}) = FEType.parameters[1]
get_ndofs(::Union{Type{<:ON_EDGES}, Type{<:ON_BEDGES}, Type{<:ON_FACES}, Type{<:ON_BFACES}}, FEType::Type{<:HCURLN1}, EG::Type{<:Edge1D}) = 2
get_ndofs(::Type{ON_CELLS}, FEType::Type{HCURLN1{2}}, EG::Type{<:Triangle2D}) = 2*num_faces(EG) + 2

get_polynomialorder(::Type{<:HCURLN1{2}}, ::Type{<:AbstractElementGeometry1D}) = 1;
get_polynomialorder(::Type{<:HCURLN1{2}}, ::Type{<:AbstractElementGeometry2D}) = 2;

get_dofmap_pattern(FEType::Type{<:HCURLN1{2}}, ::Type{CellDofs}, EG::Type{<:AbstractElementGeometry2D}) = "f2i2"
get_dofmap_pattern(FEType::Type{<:HCURLN1{2}}, ::Union{Type{FaceDofs}, Type{BFaceDofs}}, EG::Type{<:AbstractElementGeometry1D}) = "i2"

isdefined(FEType::Type{<:HCURLN1}, ::Type{<:Triangle2D}) = true

function ExtendableGrids.interpolate!(Target::AbstractArray{T, 1}, FE::FESpace{Tv, Ti, FEType, APT}, ::Type{ON_EDGES}, data; items = [], kwargs...) where {T, Tv, Ti, FEType <: HCURLN1, APT}
	edim = get_ncomponents(FEType)
	if edim == 3
		# todo
	end
end

function ExtendableGrids.interpolate!(Target::AbstractArray{T, 1}, FE::FESpace{Tv, Ti, FEType, APT}, ::Type{ON_FACES}, data; items = [], kwargs...) where {T, Tv, Ti, FEType <: HCURLN1, APT}
	edim = get_ncomponents(FEType)
	if edim == 2
		xFaceNormals = FE.xgrid[FaceNormals]
        nfaces = num_sources(xFaceNormals)
		if items == []
			items = 1:size(xFaceNormals, 2)
		end
        # integrate normal flux of exact_function over edges
		data_eval = zeros(T, 2)
        function tangentflux_eval2d(result, qpinfo)
            data(data_eval, qpinfo)
			result[1] = -data_eval[1] * xFaceNormals[2, qpinfo.item] # rotated normal = tangent
			result[1] += data_eval[2] * xFaceNormals[1, qpinfo.item]
            result[2] = result[1] * (qpinfo.xref[1] - 1 // 2)
        end
        integrate!(Target, FE.xgrid, ON_FACES, tangentflux_eval2d; quadorder = 2, items = items, offset = [0,nfaces], kwargs...)
	elseif edim == 3
		# delegate face edges to edge interpolation
		subitems = slice(FE.xgrid[FaceEdges], items)
		interpolate!(Target, FE, ON_EDGES, data; items = subitems, kwargs...)
	end
end

function ExtendableGrids.interpolate!(Target, FE::FESpace{Tv, Ti, FEType, APT}, ::Type{ON_CELLS}, data; items = [], kwargs...) where {Tv, Ti, FEType <: HCURLN1, APT}
	edim = get_ncomponents(FEType)
	if edim == 2
		# delegate cell faces to face interpolation
		subitems = slice(FE.xgrid[CellFaces], items)
		interpolate!(Target, FE, ON_FACES, data; items = subitems, kwargs...)
	elseif edim == 3
		# delegate cell edges to edge interpolation
		subitems = slice(FE.xgrid[CellEdges], items)
		interpolate!(Target, FE, ON_EDGES, data; items = subitems, kwargs...)
	end
end

# on faces dofs are only tangential fluxes
function get_basis(::Union{Type{<:ON_EDGES}, Type{<:ON_BEDGES}, Type{<:ON_BFACES}, Type{<:ON_FACES}}, ::Type{<:HCURLN1}, ::Type{<:AbstractElementGeometry})
	function closure(refbasis, xref)
		refbasis[1, 1] = 1                # tangent-flux of N0 function on single face
		refbasis[2, 1] = 12 * (xref[1] - 1 // 2) # linear tangent-flux of additional N1 edge function
	end
end

function get_basis(::Type{ON_CELLS}, ::Type{HCURLN1{2}}, ::Type{<:Triangle2D})
	function closure(refbasis, xref)
        ## HCURLN0 basis
		refbasis[1, 1] = 1 - xref[2]
		refbasis[1, 2] = xref[1]
		refbasis[3, 1] = -xref[2]
		refbasis[3, 2] = xref[1]
		refbasis[5, 1] = -xref[2]
		refbasis[5, 2] = xref[1] - 1

        ## additional functions
		for k ∈ 1:2
			# additional N1 edge basis functions
			refbasis[2, k] = -12 * (1 // 2 - xref[1] - xref[2]) * refbasis[1, k]
			refbasis[4, k] = -(12 * (xref[1] - 1 // 2)) * refbasis[3, k]
			refbasis[6, k] = -(12 * (xref[2] - 1 // 2)) * refbasis[5, k]
			# interior functions
			refbasis[7, k] = 12 * xref[2] * refbasis[1, k]
			refbasis[8, k] = 12 * xref[1] * refbasis[5, k]
		end

		return nothing
	end
end

function get_coefficients(::Type{ON_CELLS}, FE::FESpace{Tv, Ti, <:HCURLN1, APT}, EG::Type{<:AbstractElementGeometry2D}) where {Tv, Ti, APT}
	xCellFaceSigns = FE.xgrid[CellFaceSigns]
	nfaces = num_faces(EG)
	function closure(coefficients, cell)
		# multiplication with normal vector signs (only RT0)
		for j ∈ 1:nfaces, k ∈ 1:size(coefficients, 1)
			coefficients[k, 2*j-1] = xCellFaceSigns[j, cell]
		end
		return nothing
	end
end
