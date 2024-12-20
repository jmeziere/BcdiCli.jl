module BcdiCli
    export APS, ESRF, Simulation

    using ReplMaker
    using Preferences
    using MinkowskiReduction
    using BcdiTrad
    using BcdiStrain
    using BcdiMeso
    using BcdiSimulate

    include("repl.jl")
    include("aps.jl")
    include("esrf.jl")
    include("simulation.jl")
    include("method.jl")
end
