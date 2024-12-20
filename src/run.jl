function runBCDI(
    organization, expFile, datDir, box, numVoronoi, potFile, peakLocations, 
    recBox, recNum, numPhotons, frame, method, recipe, repetitions, outDir
)
    fid = h5open(outDir*"/results.hdf5", "w")
    input = fid["input"]
    output = fid["output"]

    if organization == "simulation"
        lammpsOptions = [
            "-screen","none",
            "-log","none",
            "-sf","gpu",
            "-pk","gpu","1","neigh","no"
        ]
        hRanges = []
        kRanges = []
        lRanges = []
        rotations  = []
        for i in 1:div(length(peakLocations), 3)
            center = [0.0,0.0,0.0]
            if frame == "sample"
                center = peakLocation[3*i-2:3*i]
                push!(rotations, [1. 0 0 ; 0 1 0 ; 0 0 1])
            elseif frame == "detector"
                center = [sqrt(mapreduce(x->x^2,+,peakLocation[3*i-2:3*i])), 0, 0]
                push!(BcdiSimulate.getRotations([[1,0,0]],[peakLocation[3*i-2:3*i]])[1])
            end
            push!(hRanges, range(
                center[1]-recBox/2,
                center[1]-recBox/2+recBox*recNum/(recNum+1),
                recNum
            ))
            push!(kRanges, range(
                center[2]-recBox/2,
                center[2]-recBox/2+recBox*recNum/(recNum+1),
                recNum
            ))
            push!(lRanges, range(
                center[3]-recBox/2,
                center[3]-recBox/2+recBox*recNum/(recNum+1),
                recNum
            ))
        end

        atomSimulateDiffraction(x, y, z, hRanges, kRanges, lRanges, numPhotons)
        x, y, z = createGoldSample([box,box,box],numVoronoi)

        x = Float32.(x)
        y = Float32.(y)
        z = Float32.(z)

        relaxCrystal(x, y, z, lmpOptions, potFile*" Au")

        x = Float64.(x)
        x .-= mean(x)
        y = Float64.(y)
        y .-= mean(y)
        z = Float64.(z)
        z .-= mean(z)

        intens, recSupport, GCens, GMaxs, boxSize = atomSimulateDiffraction(
            x, y, z, hRanges, kRanges, lRanges, rotations, numPhotons
        )

        if length(intens) >= 3
            reducedBasis = minkReduce(GMaxs[1], GMaxs[2], GMaxs[3])
            recPrimLatt = zeros(3,3)
            for i in 1:3
                recPrimLatt[i,:] .= reducedBasis[i] .* boxSize
            end
        end
        
        input["x"] = x
        input["y"] = y
        input["z"] = z
    end

    if method == "traditional"
        recipe = replace(
            recipe,
            "er"=>"BcdiTrad.ER",
            "hio"=>"BcdiTrad.HIO",
            "shrink"=>"BcdiTrad.Shrink",
            "center"=>"BcdiTrad.Center"
        )*"*state"
        state = BcdiTrad.State(intens[1], recSupport[1])
        eval(recipe)
        output["abs"] = Array(fftshift(abs.(state.realSpace)))
        output["phase"] = Array(fftshift(angle.(state.realSpace)))
    elseif method == "strain"
        recipe = replace(
            recipe,
            "er"=>"BcdiStrain.ER",
            "hio"=>"BcdiStrain.HIO",
            "shrink"=>"BcdiStrain.Shrink",
            "center"=>"BcdiStrain.Center",
            "mount"=>"BcdiStrain.Mount"
        )*"*state"
        state = BcdiStrain.State(intens, GMaxs .* boxSize, recSupport)
        eval(recipe)
        output["rho"] = Array(fftshift(state.rho))
        output["ux"] = Array(fftshift(state.ux))
        output["uy"] = Array(fftshift(state.uy))
        output["uz"] = Array(fftshift(state.uz))
    elseif method == "meso"
        recipe = replace(
            recipe,
            "mrbcdi"=>"BcdiMeso.MRBCDI"
        )*"*state"
        state = BcdiMeso.State(intens, GMaxs .* boxSize, recSupport)
        eval(recipe)
        output["rho"] = Array(fftshift(state.rho))
        output["ux"] = Array(fftshift(state.ux))
        output["uy"] = Array(fftshift(state.uy))
        output["uz"] = Array(fftshift(state.uz))
    elseif method == "diffract"
        for i in 1:length(intens)
            output["diff"*string(i)] = intens[i]
        end
    end

    close(fid)
    return
end

function writeBCDIslurm(
    organization, expFile, datDir, box, numVoronoi, peakLocation, potFile,
    recBox, recNum, numPhotons, frame, method, recipe, repetitions, outDir
)
    return
end
