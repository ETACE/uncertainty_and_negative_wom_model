using Statistics

# Sim properties
folder = "../data/monopoly_ws/"
iterations = 1500
burn_in = 0
no_runs = 100
run_aggregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "goldenberg_ws" => Dict(:consumer_type => GOLDENBERG, :network => NETWORK_WATTS_STROGATZ),
    "bayes_ws" => Dict(:consumer_type => BAYES_NORMAL, :network => NETWORK_WATTS_STROGATZ),
    "cosita_ws" => Dict(:consumer_type => COSITA, :network => NETWORK_WATTS_STROGATZ),
)

# Data Collection
include("data_collection_monopoly.jl")