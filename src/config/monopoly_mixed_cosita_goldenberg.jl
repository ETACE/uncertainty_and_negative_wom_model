using Statistics

# Sim properties
folder = "../data/monopoly_mixed_cosita_goldenberg/"
iterations = 1000
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly_mixed_pop.jl")

# Define experiments
experiments = Dict(
    "0.0" => Dict(:s_goldenberg => 0.0, :s_bayes => 0.0, :s_cosita => 1.0),
    "0.05" => Dict(:s_goldenberg => 0.05, :s_bayes => 0.0, :s_cosita => 0.95),
    "0.1" => Dict(:s_goldenberg => 0.1, :s_bayes => 0.0, :s_cosita => 0.9),
    "0.15" => Dict(:s_goldenberg => 0.15, :s_bayes => 0.0, :s_cosita => 0.85),
    "0.2" => Dict(:s_goldenberg => 0.2, :s_bayes => 0.0, :s_cosita => 0.8),
    "0.25" => Dict(:s_goldenberg => 0.25, :s_bayes => 0.0, :s_cosita => 0.75)
)

# Data Collection
include("data_collection_monopoly.jl")