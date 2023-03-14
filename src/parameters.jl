using AbInitioSoftware:
    CrystalStructure,
    Pseudopotential,
    Cutoff,
    FftMesh,
    Smearing,
    Gaussian,
    MethfesselPaxton,
    MarzariVanderbilt,
    FermiDirac,
    ConvergenceThreshold,
    ForcesThreshold,
    TotalEnergyThreshold,
    EnergyErrorThreshold,
    IterativeDiagonalizationThreshold,
    System
using QuantumESPRESSOBase.PWscf: InsufficientInfoError
using Unitful: AbstractQuantity, Energy, Force, unit, ustrip, @u_str
using UnitfulAtomic

import QuantumESPRESSOBase.PWscf:
    CellParametersCard,
    AtomicPositionsCard,
    AtomicSpecies,
    AtomicSpeciesCard,
    SystemNamelist,
    ElectronsNamelist,
    PWInput

function CellParametersCard(cs::CrystalStructure)
    lattice = cs.cell.lattice
    if eltype(lattice) <: AbstractQuantity
        if unit(first(lattice)) == u"angstrom"
            lattice = ustrip.(u"angstrom", lattice)
            return CellParametersCard(lattice, "angstrom")
        elseif unit(first(lattice)) == u"bohr"
            lattice = ustrip.(u"bohr", lattice)
            return CellParametersCard(lattice, "bohr")
        else
            throw(InsufficientInfoError("the `CellParametersCard` does not have units!"))
        end
    end
end

AtomicPositionsCard(cs::CrystalStructure) = AtomicPositionsCard(cs.cell, "crystal")

function AtomicSpeciesCard(cs::CrystalStructure, ps::Pseudopotential)
    atoms = string.(cs.cell.atoms)
end

SystemNamelist(nml::SystemNamelist, cutoff::Cutoff) =
    SystemNamelist(nml; ecutwfc=cutoff.energy, ecutrho=cutoff.density, ecutfock=cutoff.fock)
SystemNamelist(nml::SystemNamelist, fft::FftMesh) =
    SystemNamelist(nml; nr1=fft.x, nr2=fft.y, nr3=fft.z)
SystemNamelist(nml::SystemNamelist, smearing::Smearing) = SystemNamelist(
    nml;
    occupations="smearing",
    degauss=degauss(smearing.degauss),
    smearing=qevalue(smearing),
)
SystemNamelist(nml::SystemNamelist, threshold::TotalEnergyThreshold) =
    SystemNamelist(nml; etot_conv_thr=getthreshold(threshold))
SystemNamelist(nml::SystemNamelist, threshold::ForcesThreshold) =
    SystemNamelist(nml; forc_conv_thr=getthreshold(threshold))
ElectronsNamelist(nml::ElectronsNamelist, threshold::EnergyErrorThreshold) =
    ElectronsNamelist(nml; conv_thr=getthreshold(threshold))
ElectronsNamelist(nml::ElectronsNamelist, threshold::ForcesThreshold) =
    ElectronsNamelist(nml; diago_thr_init=getthreshold(threshold))

function PWInput(system::System)
    cell = CellParametersCard(filter(Base.Fix2(isa, CrystalStructure), system.parameters))
    atomic_positions = AtomicPositionsCard(
        filter(Base.Fix2(isa, CrystalStructure), system.parameters)
    )
    sys = SystemNamelist(; ibrav=0)
    for item in filter(
        Base.Fix2(isa, Union{Cutoff,FftMesh,Smearing,TotalEnergyThreshold,ForcesThreshold}),
        system.parameters,
    )
        sys = SystemNamelist(sys, item)
    end
    electrons = ElectronsNamelist()
    for item in filter(
        Base.Fix2(isa, Union{EnergyErrorThreshold,ForcesThreshold}), system.parameters
    )
        electrons = ElectronsNamelist(electrons, item)
    end
    return PWInput(;
        system=sys,
        electrons=electrons,
        atomic_positions=atomic_positions,
        cell_parameters=cell,
    )
end

degauss(value::Real) = value
degauss(value::Energy) = ustrip(u"Ry", value)

getthreshold(threshold::ConvergenceThreshold) = getthreshold(threshold.value)
getthreshold(value::Energy) = ustrip(u"Ry", value)
getthreshold(value::Force) = ustrip(u"Ry/bohr^3", value)

qevalue(smearing::Gaussian) = "gaussian"
qevalue(smearing::MethfesselPaxton) = "methfessel-paxton"
qevalue(smearing::Gaussian) = "marzari-vanderbilt"
qevalue(smearing::Gaussian) = "fermi-dirac"
