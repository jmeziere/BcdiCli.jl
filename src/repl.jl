printed = false

expName = nothing
saveExp = nothing
algName = nothing
saveAlg = nothing

# Experiment information
organization = nothing
beamline = nothing
expFile = nothing
datDir = nothing

# Simulation information
box = nothing
numVoronoi = nothing
potFile = nothing
peakLocation = nothing
recBox = nothing
recNum = nothing
numPhotons = nothing
frame = nothing

# Solver Information
method = nothing
recipe = nothing
repetitions = nothing
outDir = nothing
opDef = []

if @has_preference("experiments")
    experiments = @load_preference("experiments")
else
    experiments = Dict()
end

if @has_preference("algorithms")
    algorithms = @load_preference("algorithms")
else
    algorithms = Dict()
end

function getVal(dict, key)
    if key in keys(dict)
        return dict[key]
    end
    return nothing
end

function parse_to_expr(s)
    global printed, expName, organization, beamline, expFile, datDir, box, numVoronoi, potFile, peakLocation, recBox, recNum, numPhotons, frame, saveExp, algName, method, recipe, repetitions, outDir, saveAlg
    printed = false
    s = lowercase(filter(x->!isspace(x), s))

    if s == "help"
        println("You are here")
    elseif length(s) > 5 && s[1:5] == "clear"
        if s[6:end] == "experiment"
            expName = nothing
            organization = nothing
            beamline = nothing
            expFile = nothing
            datDir = nothing
            box = nothing
            numVoronoi = nothing
            potFile = nothing
            peakLocation = nothing
            recBox = nothing
            recNum = nothing
            frame = nothing
            saveExp = nothing
        elseif s[6:end] == "experimentname"
            expName = nothing
            saveExp = nothing
        elseif s[6:end] == "organization"
            organization = nothing
            saveExp = nothing
        elseif s[6:end] == "beamline"
            beamline = nothing
            saveExp = nothing
        elseif s[6:end] == "experimentfile"
            expFile = nothing
            saveExp = nothing
        elseif s[6:end] == "datadirectory"
            datDir = nothing
            saveExp = nothing
        elseif s[6:end] == "box"
            box = nothing
            saveExp = nothing
        elseif s[6:end] == "numberofvoronoi"
            numVoronoi = nothing
            saveExp = nothing
        elseif s[6:end] == "potentialfile"
            potFile = nothing
            saveExp = nothing
        elseif s[6:end] == "peaklocations"
            peakLocation = nothing
            saveExp = nothing
        elseif s[6:end] == "reciprocalbox"
            recBox = nothing
            saveExp = nothing
        elseif s[6:end] == "numberofreciprocals"
            recNum = nothing
            saveExp = nothing
        elseif s[6:end] == "numberofphotons"
            numPhotons = nothing
            saveExp = nothing
        elseif s[6:end] == "frame"
            frame = nothing
            saveExp = nothing
        elseif s[6:end] == "algorithm"
            algName = nothing
            method = nothing
            recipe = nothing
            repetitions = nothing
            outDir = nothing
            saveAlg = nothing
        elseif s[6:end] == "algorithmname"
            algName = nothing
            saveAlg = nothing
        elseif s[6:end] == "method"
            method = nothing
            saveAlg = nothing
        elseif s[6:end] == "recipe"
            recipe = nothing
            saveAlg = nothing
        elseif s[6:end] == "repetitions"
            repetitions = nothing
            saveAlg = nothing
        elseif s[6:end] == "outputdirectory"
            outDir = nothing
            saveAlg = nothing
        end
    elseif length(s) > 6 && s[1:6] == "delete"
        if length(s) > 16 && s[7:16] == "experiment"
            delete!(experiments, s[17:end])
            @set_preferences!("experiments"=>experiments)
        elseif length(s) > 15 && s[7:15] == "algorithm"
            delete!(algorithms, s[16:end])
            @set_preferences!("algorithms"=>algorithms)
        end
    elseif saveExp == nothing
        if expName == nothing
            if expName == "back"
                return
            end
            expName = s
            if expName in keys(experiments)
                organization = getVal(experiments[expName],"organization")
                beamline = getVal(experiments[expName],"beamline")
                expFile = getVal(experiments[expName],"expFile")
                datDir = getVal(experiments[expName],"datDir")
                box = getVal(experiments[expName],"box")
                numVoronoi = getVal(experiments[expName],"numVoronoi")
                potFile = getVal(experiments[expName],"potFile")
                peakLocation = getVal(experiments[expName],"peakLocation")
                recBox = getVal(experiments[expName],"recBox")
                recNum = getVal(experiments[expName],"recNum")
                numPhotons = getVal(experiments[expName],"numPhotons")
                frame = getVal(experiments[expName],"frame")
                saveExp = "yes"
            end
        elseif organization == nothing
            if s == "aps" || s == "esrf" || s == "simulation"
                organization = s
            elseif s == "back"
                expName = nothing
                return
            end
        elseif organization == "aps"
            parseAPS(s)
        elseif organization == "esrf"
            parseESRF(s)
        elseif organization == "simulation"
            parseSimulation(s)
        end
        println(
            "\nCurrent Experiment\n",
            "Experiment Name: ",expName,"\n",
            "Organization: ",organization,"\n",
            "Experiment File: ",expFile,"\n",
            "Data Directory: ",datDir,"\n",
            "Box: ",box,"\n",
            "Number of Voronoi: ",numVoronoi,"\n",
            "Potential File: ",potFile,"\n",
            "Peak Locations: ",peakLocation,"\n",
            "Reciprocal Box: ",recBox,"\n",
            "Number of Reciprocals: ",recNum,"\n",
            "Number of Photons: ",numPhotons,"\n",
            "Frame: ",frame,"\n"
        )
    elseif saveAlg == nothing
        if algName == nothing
            if algName == "back"
                return
            end
            algName = s
            if algName in keys(algorithms)
                method = getVal(algorithms[algName],"method")
                recipe = getVal(algorithms[algName],"recipe")
                repetitions = getVal(algorithms[algName],"repetitions")
                outDir = getVal(algorithms[algName],"outDir")
                saveAlg = yes
            end
        else method == nothing
            parseMethod(s)
        end
        println(
            "\nCurrent Algorithm\n",
            "Algorithm Name: ",algName,"\n",
            "Method: ",method,"\n",
            "Recipe: ",recipe,"\n",
            "Repetitions: ",repetitions,"\n",
            "Output Directory: ",outDir,"\n"
        )
    else
        if s == "local"
            runBCDI(
                organization, expFile, datDir, box, numVoronoi, peakLocation, recBox, 
                recNum, numPhotons, frame, method, recipe, repetitions, outDir
            )
        elseif s == "slurm"
            writeBCDIslurm(
                organization, expFile, datDir, box, numVoronoi, peakLocation, recBox, 
                recNum, numPhotons, frame, method, recipe, repetitions, outDir
            )
        end
    end
end

function prompt()
    global printed
    if !printed
        if saveExp == nothing
            if expName == nothing
                names = collect(keys(experiments))
                println(
                    "\n\nChoose Experiment Name:\n",
                    [names[i]*"\n" for i in 1:length(names)]...,
                    "Enter Any Name to Create New Experiment\n"
                )
            elseif organization == nothing
                println(
                    "\n\nChoose Organization:\n",
                    "APS\n",
                    "ESRF\n",
                    "Simulation\n"
                )
            elseif organization == "aps"
                promptAPS()
            elseif organization == "esrf"
                promptESRF()
            elseif organization == "simulation"
                promptSimulation()
            end
        elseif saveAlg == nothing
            if algName == nothing
                names = collect(keys(algorithms))
                println(
                    "\n\nChoose Algorithm Name:\n",
                    [names[i]*"\n" for i in 1:length(names)]...,
                    "Enter Any Name to Create New Algorithm\n"
                )
            else
                promptMethod()
            end
        else
            println(
                "\n\nChoose run method:\n",
                "\nExperiment Chosen:\n",
                "Experiment Name: ",expName,"\n",
                "Organization: ",organization,"\n",
                "Experiment File: ",expFile,"\n",
                "Data Directory: ",datDir,"\n",
                "Box: ",box,"\n",
                "Number of Voronoi: ",numVoronoi,"\n",
                "Potential File: ",potFile,"\n",
                "Peak Locations: ",peakLocation,"\n",
                "Reciprocal Box: ",recBox,"\n",
                "Number of Reciprocals: ",recNum,"\n",
                "Number of Photons: ",numPhotons,"\n",
                "Frame: ",frame,"\n",
                "\nAlgorithm Chosen:\n",
                "Algorithm Name: ",algName,"\n",
                "Method: ",method,"\n",
                "Recipe: ",recipe,"\n",
                "Repetitions: ",repetitions,"\n",
                "Output Directory: ",outDir,"\n",
                "\nRun type:\n",
                "Local\n",
                "Slurm\n"
            )
        end
        printed = true
    end
    return "BcdiCli> "
end

function __init__()
    if !isinteractive()
        @info "Session is not interactive"
        return
    end        
    initrepl(
        parse_to_expr,
        prompt_text=prompt,
        prompt_color = :red,
        start_key='>',
        mode_name="Bcdi_mode",
    )
end
