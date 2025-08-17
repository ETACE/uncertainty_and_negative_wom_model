# Uncertainty and Negative Word-of-Mouth Model

Version: Aug 2025

This repository contains the Julia implementation of a model used to study the role of consumer uncertainty for NWoM’s impact on adoption dynamics.

## Getting Started

These instructions will allow you to run the model on your system.

### System Requirements and Installation

To run this code, you need to install **[Julia](https://julialang.org/)** (version 1.11.2 recommended). 

The following Julia packages are required (specific versions recommended for compatibility):

* [Agents](https://juliadynamics.github.io/Agents.jl/stable/) - Version 6.1.10
* [ArgParse](https://argparsejl.readthedocs.io/en/latest/argparse.html) - Version 1.2.0
* [CSV](https://csv.juliadata.org/stable/) - Version 0.10.15
* [DataFrames](https://juliadata.github.io/) - Version 1.7.0
* [DataStructures](https://juliacollections.github.io/DataStructures.jl/latest/) - Version 0.18.20
* [Distributions](https://github.com/JuliaStats/Distributions.jl) - Version 0.25.112
* [Plots](https://docs.juliaplots.org/) - Version 1.40.8
* [QuadGK](https://juliamath.github.io/QuadGK.jl/stable/) - Version 2.11.1
* [StatsBase](https://juliastats.org/StatsBase.jl/stable/) - Version 0.34.3
* [StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) - Version 0.15.7
* [TensorCast](https://github.com/mcabbott/TensorCast.jl) - Version 0.4.8

To install the required packages, start *Julia* and run:

```
using Pkg; Pkg.add("<package name>")
```

Alternatively, if the *Project.toml* is included, you can install all dependencies exactly as used in development:

```
using Pkg
Pkg.instantiate()
```

### Model Structure and Execution

The core implementation of the model is located in the *src/model/* directory. To run the model, an initial state must be defined. The baseline initialization is provided in *src/config/init_monopoly.jl*. The subset of data collected during a simulation run is configured via *src/config/data_collection_monopoly.jl*.

To run an experiment (i.e. multiple parallel simulation batches), execute *run_exp.jl*. Each experiment must be defined in a configuration file - see *experiments/monopoly_goldenberg.jl* for an example. Use the following command:

```
julia -p <no_cpus> run_exp.jl <name-of-config-file> [--chunk <i>] [--no_chunks <n>]
```

- *-p <no_cpus>* : number of CPU cores to use in parallel
- *--chunk* and *--no_chunk*: optional parameters to split the experiment into chunks, useful for distributed execution across multiple machines

## Replication

To reproduce the results from the paper by re-simulating the model, use the following commands:

```
julia -p <no_cpus> run_exp.jl monopoly_goldenberg
julia -p <no_cpus> run_exp.jl monopoly_bayes
julia -p <no_cpus> run_exp.jl monopoly_cosita
julia -p <no_cpus> run_exp.jl monopoly_ws
julia -p <no_cpus> run_exp.jl monopoly_ba
julia -p <no_cpus> run_exp.jl monopoly_er
julia -p <no_cpus> run_exp.jl monopoly_mixed_cosita_bayes
julia -p <no_cpus> run_exp.jl monopoly_mixed_cosita_goldenberg
julia -p <no_cpus> run_exp.jl monopoly_mixed_emp
```

The resulting data will be stored in *data/*, which by default contains the data used to create the plots in the paper. 

In order to recreate all plots from the paper, run:

```
julia plots_paper.jl
```

## Empirical Data

We conducted a survey among German consumers. The original survey data (in xlsx file format) can be found in the *data/* folder.

## Authors

Herbert Dawid, Dirk Kohlweyer, Melina Schleef, Christian Stummer, Frederik Tolkmitt

## Further Links

* [ETACE](https://www.uni-bielefeld.de/fakultaeten/wirtschaftswissenschaften/lehrbereiche/etace/) - Economic Theory and Computational Economics, Bielefeld University
* [ITM](https://www.uni-bielefeld.de/fakultaeten/wirtschaftswissenschaften/lehrbereiche/itm/index.xml) - Innovation and Technology Management, Bielefeld University