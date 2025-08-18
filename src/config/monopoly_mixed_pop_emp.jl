using Statistics

# Sim properties
folder = "../data/monopoly_mixed_pop_emp/"
iterations = 1500
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly_mixed_pop.jl")

# Define experiments
experiments = Dict(
    "mixed_pop_emp" => Dict(),
)

# Data Collection
include("data_collection_monopoly.jl")