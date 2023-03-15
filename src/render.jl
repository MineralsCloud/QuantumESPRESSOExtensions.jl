using CrystallographyBase: Lattice
using Mustache: render, @mt_str
using QuantumESPRESSOBase.PWscf: AtomicPosition

const ATOMIC_POSITIONS = mt"""
ATOMIC_POSITIONS { crystal }
{{#:atomic_positions}}
{{#.}}{{:atom}} {{#:pos}}{{.}} {{/:pos}} {{/.}}
{{/:atomic_positions}}
"""
const CELL_PARAMETERS = mt"""
CELL_PARAMETERS { {{:unit}} }
{{#:cell}}
{{#.}}  {{.}}  {{/.}}
{{/:cell}}
"""

function render(io::IO, ::Type{CellParametersCard}, cs::CrystalStructure)
    lattice = Lattice(cs.cell)
    u = if unit(eltype(lattice)) == u"bohr"
        "bohr"
    elseif unit(eltype(lattice)) == u"angstrom"
        "angstrom"
    else
        "alat"
    end
    return render(io, CELL_PARAMETERS, (unit=u, cell=ustrip.(eachcol(lattice))))
end
function render(io::IO, ::Type{AtomicPositionsCard}, cs::CrystalStructure)
    atoms, positions = cs.cell.atoms, cs.cell.positions
    atomic_positions = map(atoms, positions) do atom, position
        AtomicPosition(atom, position)
    end
    return render(io, ATOMIC_POSITIONS, (atomic_positions=atomic_positions,))
end
