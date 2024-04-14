# LatticeArrays

LatticeArrays.jl is a Julia package designed to provide efficient and easy-to-use data
structures for storing and manipulating arrays that live on a lattice. This package is ideal
for applications that require spatially structured data storage and operations, such as
simulations in physics.


[![Build Status](https://github.com/lkdvos/LatticeArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lkdvos/LatticeArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)


## Installation

You can install `LatticeArrays.jl` using Julia's built-in package manager. Open the Julia REPL and type `]` to enter the Pkg prompt. Then run the command:

```julia-repl
pkg> add LatticeArrays
```

Or you can install it from the Julia REPL directly through the following command:

```julia
import Pkg
Pkg.add("LatticeArrays")
```

## Features

- **Customizable lattices**: Wide range of supported lattices in 1, 2, and 3 dimensions.
- **Easy access**: Access elements using linear, Cartesian or hexagonal coordinates.
- **Iterators**: Iterators for all sites, neighbors, and more.
- **Customizable boundary conditions**: Periodic, open, or custom boundary conditions.

## Basic Usage

To create a lattice array, simply specify the lattice type and the size of the lattice:

```julia
using LatticeArrays

# Create a 2D square lattice
lat_array = fill!(1.0, SquareArray{Float64}(8, 8))
```

Elements can be accessed and modified using standard indexing conventions.

```julia
# Access an element
value = lat_array[1, 1]

# Modify an element
lat_array[2, 3] = 2.0
```

## Documentation

For more details on usage and APIs, please refer to the full [documentation](https://lkdvos.github.io/LatticeArrays.jl/dev/).

## License

LatticeArrays.jl is MIT licensed. See the LICENSE file for details.