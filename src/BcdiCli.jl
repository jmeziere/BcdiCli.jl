module BcdiCli
    using ReplMaker
    using REPL
    using InteractiveUtils

    function parse_to_expr(s)
        quote Meta.parse($s) end
    end

println("here")
    initrepl(
        parse_to_expr,
        prompt_text="BcdiCli> ",
        prompt_color = :red,
        start_key='>',
        mode_name="Bcdi_mode",
        valid_input_checker=complete_julia
    )
println("here")
end
