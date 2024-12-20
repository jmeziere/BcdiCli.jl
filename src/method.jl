function parseMethod(s)
    global algName, method, recipe, repetitions, outDir, saveAlg, opDef
    if method == nothing
        if s == "back"
            algName = nothing
            return
        end
        if s == "traditional" || s == "strain" || s == "meso" || s == "diffract"
            method = s
        end
    elseif recipe == nothing && method != "diffract"
        if s == "back"
            method = nothing
            return
        end
        if length(s) > 2 && s[1:2] == "op"
            push!(opDef, s[3:end])
        elseif length(s) > 3 && s[1:3] == "rec"
            for i in 1:length(opDef)
                opDef[i] = ('a'-1+i)*"="*opDef[i]*";"
            end
            recipe = join(opDef)*s[4:end]
            resize!(opDef, 0)
        end
    elseif repetitions == nothing && method == "diffract"
        if s == "back"
            method = nothing
            return
        end
        repetitions = Int64(Meta.parse(s))
    elseif outDir == nothing
        if s == "back"
            if method != "diffract"
                recipe = nothing
            else
                repetitions = nothing
            end
            return
        end
        outDir = s
    elseif saveAlg == nothing
        if s == "back"
            outDir = nothing
            return
        end
        if s == "yes"
            algorithms[algName] = Dict{String,Any}(
                "method"=>method,
                "recipe"=>recipe,
                "repetitions"=>repetitions,
                "outDir"=>outDir
            )
            @set_preferences!("algorithms"=>algorithms)
        end
        saveAlg = s
    end
end

function promptMethod()
    if method == nothing
        println(
            "\n\nChoose solver method:\n",
            "Traditional\n",
            "Strain\n",
            "Meso\n",
            "Diffract\n"
        )
    elseif recipe == nothing && method != "diffract"
        opAvail = []
        if method == "traditional"
            opAvail = ["ER()","HIO(beta)","Shrink(threshold,sigma,state)","Center(state)"]
        elseif method == "strain"
            opAvail = [
                "ER()","HIO(beta)","Shrink(threshold,sigma,state)",
                "Center(state)","Mount(beta,state,recPrimLatt)"
            ]
        elseif method == "meso"
            opAvail = [
                "MRBCDI(state,recPrimLatt,numPeaks,iterations,lambdaTV,lambdaBeta,aBeta,bBeta,cBeta,alpha)"
            ]
        end
        println(
            "\n\nCreate a recipe:\n",
            "\nDefine new operators by Op <name>\n",
            "Variables state and recPrimLatt are placeholders and should be entered with those names\n",
            "Available operators:\n",
            [opAvail[i]*"\n" for i in 1:length(opAvail)]...,
            "\nDefined operators\n",
            [('a'-1+i)*") "*opDef[i]*"\n" for i in 1:length(opDef)]...,
            "\nDefine the recipe by Rec <recipe>\n",
            "Recipes will use the letters associated with defined operators (e.g. a^2*b)"
        )
    elseif repetitions == nothing && method == "diffract"
        println(
            "\n\nChoose number of repetitions:\n"
        )
    elseif saveAlg == nothing
        println(
            "\n\nSave Solver?\n",
            "yes\n",
            "no\n"
        )
    end
end
