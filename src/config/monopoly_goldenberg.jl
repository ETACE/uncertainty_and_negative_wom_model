using Statistics

# Sim properties
folder = "../data/monopoly_goldenberg/"
iterations = 500
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "goldenberg" => Dict(:consumer_type => GOLDENBERG),
)

# Data Collection
include("data_collection_monopoly.jl")