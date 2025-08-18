using Statistics

# Sim properties
folder = "../data/monopoly_cosita/"
iterations = 1200
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "cosita" => Dict(:consumer_type => COSITA),
)

# Data Collection
include("data_collection_monopoly.jl")