using Statistics

# Sim properties
folder = "../data/monopoly_ba/"
iterations = 1500
burn_in = 0
no_runs = 100
run_consumer_typeregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "goldenberg_ba" => Dict(:consumer_type => GOLDENBERG, :network => NETWORK_BARABASI_ALBERT),
    "bayes_ba" => Dict(:consumer_type => BAYES_NORMAL, :network => NETWORK_BARABASI_ALBERT),
    "cosita_ba" => Dict(:consumer_type => COSITA, :network => NETWORK_BARABASI_ALBERT),
)

# Data Collection
include("data_collection_monopoly.jl")