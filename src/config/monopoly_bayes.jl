using Statistics

# Sim properties
folder = "../data/monopoly_bayes/"
iterations = 1500
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "bayes_normal" => Dict(:consumer_type => BAYES_NORMAL),
)

# Data Collection
include("data_collection_monopoly.jl")