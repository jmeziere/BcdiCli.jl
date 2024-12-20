function parseSimulation(s)
    global experiments, organization, box, numVoronoi, potFile, peakLocation, recBox, recNum, numPhotons, frame, saveExp
    if box == nothing
        if s == "back"
            organization = nothing
            return
        end
        box = Float64(Meta.parse(s))
    elseif numVoronoi == nothing
        if s == "back"
            box = nothing
            return
        end
        numVoronoi = Int64(Meta.parse(s))
    elseif potFile == nothing
        if s == "back"
            numVoronoi = nothing
            return
        end
        potFile = s
    elseif peakLocation == nothing
        if s == "back"
            potFile = nothing
            return
        end
        peakLocation = Float64.(eval(Meta.parse(s)))
    elseif potFile == nothing
        if s == "back"
            peakLocation = nothing
            return
        end
        potFile = s
    elseif recBox == nothing
        if s == "back"
            potFile = nothing
            return
        end
        recBox = Float64(Meta.parse(s))
    elseif recNum == nothing
        if s == "back"
            recBox = nothing
            return
        end
        recNum = Int64(Meta.parse(s))
    elseif numPhotons == nothing
        if s == "back"
            recNum = nothing
            return
        end
        numPhotons = Int64.(eval(Meta.parse(s)))
    elseif frame == nothing
        if s == "back"
            recBox = nothing
            return
        end
        if s == "sample" || s == "detector"
            frame = s
        end
    elseif saveExp == nothing
        if s == "back"
            numVoronoi = nothing
            return
        end
        if s == "yes"
            experiments[expName] = Dict{String,Any}(
                "organization"=>organization,
                "box"=>box,
                "numVoronoi"=>numVoronoi,
                "peakLocation"=>peakLocation,
                "potFile"=>potFile,
                "recBox"=>recBox,
                "recNum"=>recNum,
                "numPhotons"=>numPhotons,
                "frame"=>frame
            )
            @set_preferences!("experiments"=>experiments)
        end
        saveExp = s
    end
end

function promptSimulation()
    if box == nothing
        println(
            "\n\nCurrently, only gold nanoparticles can be simulated\n",
            "Choose real space cube size in Angstroms (e.g. 100.0)\n"
        )
    elseif numVoronoi == nothing
        println(
            "\n\nChoose number of voronoi for box tesselation\n",
            "Only central sample will be kept\n"
        )
    elseif potFile == nothing
        println(
            "\n\nChoose potential file location:\n"
        )
    elseif peakLocation == nothing
        println(
            "\n\nChoose center of measurements in Angstroms^-1 (e.g. [0.25,0.25,0.25])\n",
            "The [1 1 1] peak should be close to [0.25,0.25,0.25] in Angstroms^-1\n",
            "Multiple peaks can be specified by adding onto the list (e.g. [0.25,0.25,0.25, -0.25,0.25,0.25])\n"
        ) 
    elseif recBox == nothing
        println(
            "\n\nChoose reciprocal space cube size in Angstroms^-1 (e.g. 0.05)\n"
        )
    elseif recNum == nothing
        println(
            "\n\nChoose number of reciprocal space samples (e.g. 100)\n"
        )
    elseif numPhotons == nothing
        println(
            "\n\nChoose number of photons for each peak (e.g. [100,1e6,50])\n"
        )
    elseif frame == nothing
        println(
            "\n\nFrame of reference of measurements:\n",
            "Sample\n",
            "Detector\n"
        )
    elseif saveExp == nothing
        println(
            "\n\nSave Simulation?\n",
            "yes\n",
            "no\n"
        )
    end
end
