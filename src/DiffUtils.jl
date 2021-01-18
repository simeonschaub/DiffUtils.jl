module DiffUtils

using diffutils_jll
using FIFOStreams

@noinline function check_argtype(name::Symbol, val, T::Type)
    @nospecialize
    val isa T || throw(ArgumentError(
        "expected option `$name` to be of type `$T`, but got $val::$(typeof(val)) instead.",
    ))
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
    for arg in _INTEGER_ARGS
)

function parse_options(options::Dict{Symbol,Any})
    args = String[]
    for (name, val) in pairs(options)
        if haskey(BOOLEAN_ARGS, name)
            check_argtype(name, val, Bool)
            val && push!(args, BOOLEAN_ARGS[name])
        elseif haskey(INTEGER_ARGS, name)
            check_argtype(name, val, Int)
            argname = INTEGER_ARGS[name]
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

"""
    DiffUtils.diff(f::Function; stdout=stdout, side_by_side=true, color=true, options...)

Takes a function `f` which gets passed two output streams and may write to them. The resulting
contents are then passed to `diff`.

Optionally, `stdout` specifies the stream which the output of `diff` gets written to.

```jldoctest
julia> DiffUtils.diff() do s1, s2
           println(s1, "foo")
           println(s2, "bar")
       end
foo							      |	bar
```

## Supported Options

See the [`diff` man page](https://www.man7.org/linux/man-pages/man1/diff.1.html) for further
reference.

### Boolean Arguments

$(join(string.("`", keys(BOOLEAN_ARGS), "`"), ", "))

### Integer Arguments

$(join(string.("`", keys(INTEGER_ARGS), "`"), ", "))

### Other

$(join(string.("`", [:color, :labels], "`"), ", "))
"""
function diff(f::Function; stdout=stdout, @nospecialize(options...))
    _diff() do diff
        s = FIFOStreamCollection(2)
        local ret
        try
            args = parse_options(merge(DEFAULT_OPTIONS, Dict{Symbol, Any}(pairs(options))))
            cmd = Cmd(String[diff; path(s, 1); path(s, 2); args])
            attach(s, pipeline(ignorestatus(cmd); stdout=stdout))
            s1, s2 = s
            ret = f(s1, s2)
        finally
            close(s)
        end
        return ret
    end
end

"""
    DiffUtils.diff(x1, x2; stdout=stdout, side_by_side=true, color=true, options...)

Prints the diff of the string representations of `x1` and `x2`.

Optionally, `stdout` specifies the stream which the output of `diff` gets written to.

```jldoctest
julia> DiffUtils.diff("foo", "bar")
foo							      |	bar
```

For further details on the supported options, see [`diff(::Function)`](@ref).
"""
function diff(x1, x2; stdout=stdout, @nospecialize(options...))
    diff(; stdout=stdout, options...) do s1, s2
        print(s1, x1)
        println(s1)
        print(s2, x2)
        println(s2)
    end
    nothing
end

end
