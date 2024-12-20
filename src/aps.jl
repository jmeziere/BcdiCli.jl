function parseAPS(s)
    global organization, beamline
    if beamline == nothing
        if s == "back"
            organization = nothing
        end
    end
end

function promptAPS()
    if beamline == nothing
        println(
            "\n\nChoose Beamline:\n"
        )
    end
end
