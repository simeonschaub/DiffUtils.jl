module DiffUtils

using diffutils_jll
using FIFOStreams

@noinline function check_argtype(name::Symbol, val, T::Type)
    @nospecialize
    val isa T || throw(ArgumentError("expected option `$name` to be of type `$T`, but got $val::$T instead."))
    nothing
end

const _BOOLEAN_ARGS = [
    "-q", "--brief",
    "-s", "--report-identical-files",
    "-e", "--ed",
    "-n", "--rcs",
    "-y", "--side-by-side",
    "--left-column",
    "--suppress-common-lines",
    "-p", "--show-c-function",
    "-t", "--expand-tabs",
    "-T", "--initial-tab",
    "--suppress-blank-empty",
    "-l", "--paginate",
    "-r", "--recursive",
    "--no-dereference",
    "-N", "--new-file",
    "--unidirectional-new-file",
    "--ignore-file-name-case",
    "--no-ignore-file-name-case",
    "-i", "--ignore-case",
    "-E", "--ignore-tab-expansion",
    "-Z", "--ignore-trailing-space",
    "-b", "--ignore-space-change",
    "-w", "--ignore-all-space",
    "-B", "--ignore-blank-lines",
    "-a", "--text",
    "--strip-trailing-cr",
    "-d", "--minimal",
    "--speed-large-files",
]
const BOOLEAN_ARGS = Dict(
    Symbol(replace(strip(arg, '-'), '-' => '_')) => arg
    for arg in _BOOLEAN_ARGS
)

const _INTEGER_ARGS = [
    "-c", "-C", "--context",
    "-u", "-U", "--unified",
    "-W", "--width",
    "--tabsize",
    "--horizon-lines",
]
const INTEGER_ARGS = Dict(
    Symbol(replace(strip(arg, '-'), '-' => '_')) => arg
    for arg in _BOOLEAN_ARGS
)

function parse_options(options::Dict{Symbol,Any})
    args = String[]
    for (name, val) in pairs(options)
        if haskey(BOOLEAN_ARGS, name)
            check_argtype(name, val, Bool)
            val && push!(args, BOOLEAN_ARGS[name])
        elseif haskey(INTEGER_ARGS, name)
            check_argtype(name, val, Int)
            argname = BOOLEAN_ARGS[name]
            if occursin(r"^\-[a-z]$", argname)
                push!(args, "$argname$val")
            elseif occursin(r"^\-[A-Z]$", argname)
                push!(args, argname)
                push!(args, string(val))
            else
                push!(args, "$argname=$val")
            end
        elseif name === :color
            check_argtype(name, val, Union{Bool, AbstractString, Symbol})
            if val isa Bool
                val && push!(args, "--color")
            else
                push!(args, "--color=$val")
            end
        elseif name === :labels
            check_argtype(name, val, NTuple{2, Union{AbstractString, Symbol}})
            push!(args, "--label=$(val[1])")
            push!(args, "--label=$(val[2])")
        end
    end
    return args
end

const DEFAULT_OPTIONS = Dict(
    :side_by_side => true,
    :color => true,
    :labels => ("stream 1", "stream 2"),
)

function diff(f::Function; stdout=stdout, @nospecialize(options...))
    _diff() do diff
        s = FIFOStreamCollection(2)
        local ret
        try
            args = parse_options(merge(DEFAULT_OPTIONS, Dict{Symbol, Any}(pairs(options))))
            cmd = Cmd(String[diff; path(s, 1); path(s, 2); args])
            attach(s, pipeline(ignorestatus(cmd); stdout))
            s1, s2 = s
            ret = f(s1, s2)
        finally
            close(s)
        end
        return ret
    end
end

function diff(x1, x2; stdout=stdout, @nospecialize(options...))
    diff(; stdout, options...) do s1, s2
        print(s1, x1)
        print(s2, x2)
    end
    nothing
end

end
