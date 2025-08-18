using Statistics

# Sim properties
folder = "../data/monopoly_er/"
iterations = 1500
burn_in = 0
no_runs = 100
run_consumer_typeregation = [mean]

# include baseline
include("init_monopoly.jl")

# Define experiments
experiments = Dict(
    "goldenberg_er" => Dict(:consumer_type => GOLDENBERG, :network => NETWORK_ERDOS_RENYI),
    "bayes_er" => Dict(:consumer_type => BAYES_NORMAL, :network => NETWORK_ERDOS_RENYI),
    "cosita_er" => Dict(:consumer_type => COSITA, :network => NETWORK_ERDOS_RENYI),
)

# Data Collection
include("data_collection_monopoly.jl")