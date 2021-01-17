using DiffUtils
using Test

@testset "DiffUtils.diff" begin
    # different line endings not only change the line endings themselves in the output,
    # but can also affect the number of tabs
    diff_ab = read(Sys.iswindows() ? "diff_ab_windows" : "diff_ab", String)

    out = sprint() do io
        DiffUtils.diff(; stdout=io) do s1, s2
            f1, f2 = open("a"), open("b")
            write(s1, f1)
            write(s2, f2)
            close(f1)
            close(f2)
        end
    end
    if Sys.iswindows()
        @test_broken out == diff_ab
    else
        @test out == diff_ab
    end

    a = read("a", String) |> strip
    b = read("b", String) |> strip
    out = sprint() do io
        DiffUtils.diff(a, b; stdout=io)
    end
    @test out == diff_ab
end

@testset "options" begin
    @testset "$options" for (i, _) in DiffUtils.BOOLEAN_ARGS, options in NamedTuple{(i,)}.(false:true)
        (haskey(options, :l) || haskey(options, :paginate)) && continue
        out = sprint() do io
            DiffUtils.diff(
                "foo", "bar"; stdout=io,
                side_by_side=false, color=false, options...,
            )
        end
        @test !occursin("unrecognized option", out)
    end

    for (i, _) in DiffUtils.INTEGER_ARGS
        options = NamedTuple{(i,)}(rand(5:20))
        @testset "$options" begin
            out = sprint() do io
                DiffUtils.diff(
                    "foo", "bar"; stdout=io,
                    side_by_side=false, color=false, options...,
                )
            end
            @test !occursin("unrecognized option", out)
        end
    end
end
