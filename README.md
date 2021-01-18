# DiffUtils

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://simeonschaub.github.io/DiffUtils.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://simeonschaub.github.io/DiffUtils.jl/dev)
[![Build Status](https://github.com/simeonschaub/DiffUtils.jl/workflows/CI/badge.svg)](https://github.com/simeonschaub/DiffUtils.jl/actions)
[![Coverage](https://codecov.io/gh/simeonschaub/DiffUtils.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/simeonschaub/DiffUtils.jl)

## Example

For more details, please read [the docs](https://simeonschaub.github.io/DiffUtils.jl/dev).

```jldoctest
julia> using DiffUtils

julia> DiffUtils.diff(code_lowered(cos, Tuple{Float64}), code_lowered(sin, Tuple{Float64}))
Core.CodeInfo[CodeInfo(                                         Core.CodeInfo[CodeInfo(
1 ──       Core.NewvarNode(:(@_3))                              1 ──       Core.NewvarNode(:(@_3))
│          Core.NewvarNode(:(y))                                │          Core.NewvarNode(:(y))
│          Core.NewvarNode(:(n))                                │          Core.NewvarNode(:(n))
│          absx = Base.Math.abs(x)                              │          absx = Base.Math.abs(x)
│    %5  = absx                                                 │    %5  = absx
│    %6  = ($(Expr(:static_parameter, 1)))(Base.Math.pi)        │    %6  = ($(Expr(:static_parameter, 1)))(Base.Math.pi)
│    %7  = %6 / 4                                               │    %7  = %6 / 4
│    %8  = %5 < %7                                              │    %8  = %5 < %7
└───       goto #5 if not %8                                    └───       goto #5 if not %8
2 ── %10 = absx                                                 2 ── %10 = absx
│    %11 = Base.Math.eps($(Expr(:static_parameter, 1)))         │    %11 = Base.Math.eps($(Expr(:static_parameter, 1)))
│    %12 = ($(Expr(:static_parameter, 1)))(2.0)               | │    %12 = Base.Math.sqrt(%11)
│    %13 = %11 / %12                                          | │    %13 = %10 < %12
│    %14 = Base.Math.sqrt(%13)                                | └───       goto #4 if not %13
│    %15 = %10 < %14                                          | 3 ──       return x
└───       goto #4 if not %15                                 | 4 ── %16 = Base.Math.sin_kernel(x)
3 ── %17 = ($(Expr(:static_parameter, 1)))(1.0)               | └───       return %16
└───       return %17                                         | 5 ── %18 = Base.Math.isnan(x)
4 ── %19 = Base.Math.cos_kernel(x)                            | └───       goto #7 if not %18
└───       return %19                                         | 6 ── %20 = ($(Expr(:static_parameter, 1)))(Base.Math.NaN)
5 ── %21 = Base.Math.isnan(x)                                 | └───       return %20
└───       goto #7 if not %21                                 | 7 ── %22 = Base.Math.isinf(x)
6 ── %23 = ($(Expr(:static_parameter, 1)))(Base.Math.NaN)     | └───       goto #9 if not %22
└───       return %23                                         | 8 ──       Base.Math.sin_domain_error(x)
7 ── %25 = Base.Math.isinf(x)                                 | 9 ┄─ %25 = Base.Math.rem_pio2_kernel(x)
└───       goto #9 if not %25                                 | │    %26 = Base.indexed_iterate(%25, 1)
8 ── %27 = Base.Math.cos_domain_error(x)                      | │          n = Core.getfield(%26, 1)
└───       return %27                                         | │          @_3 = Core.getfield(%26, 2)
9 ── %29 = Base.Math.rem_pio2_kernel(x)                       | │    %29 = Base.indexed_iterate(%25, 2, @_3)
│    %30 = Base.indexed_iterate(%29, 1)                       | │          y = Core.getfield(%29, 1)
│          n = Core.getfield(%30, 1)                          <
│          @_3 = Core.getfield(%30, 2)                        <
│    %33 = Base.indexed_iterate(%29, 2, @_3)                  <
│          y = Core.getfield(%33, 1)                          <
│          n = n & 3                                            │          n = n & 3
│    %36 = n == 0                                             | │    %32 = n == 0
└───       goto #11 if not %36                                | └───       goto #11 if not %32
10 ─ %38 = Base.Math.cos_kernel(y)                            | 10 ─ %34 = Base.Math.sin_kernel(y)
                                                              > └───       return %34
                                                              > 11 ─ %36 = n == 1
                                                              > └───       goto #13 if not %36
                                                              > 12 ─ %38 = Base.Math.cos_kernel(y)
└───       return %38                                           └───       return %38
11 ─ %40 = n == 1                                             | 13 ─ %40 = n == 2
└───       goto #13 if not %40                                | └───       goto #15 if not %40
12 ─ %42 = Base.Math.sin_kernel(y)                            | 14 ─ %42 = Base.Math.sin_kernel(y)
│    %43 = -%42                                                 │    %43 = -%42
└───       return %43                                           └───       return %43
13 ─ %45 = n == 2                                             | 15 ─ %45 = Base.Math.cos_kernel(y)
└───       goto #15 if not %45                                | │    %46 = -%45
14 ─ %47 = Base.Math.cos_kernel(y)                            | └───       return %46
│    %48 = -%47                                               <
└───       return %48                                         <
15 ─ %50 = Base.Math.sin_kernel(y)                            <
└───       return %50                                         <
)]                                                              )]
```
