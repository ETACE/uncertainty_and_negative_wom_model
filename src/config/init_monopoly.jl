using Random
using DataStructures
using Distributions
using Plots

const GOLDENBERG = 1
const BAYES_NORMAL = 2
const COSITA = 3

const NETWORK_GOLDENBERG = 1
const NETWORK_BARABASI_ALBERT = 2
const NETWORK_WATTS_STROGATZ = 3
const NETWORK_ERDOS_RENYI = 4

# Baseline properties
baseline_properties = Dict(
    :n => 3000,                     # number of consumers
    :n_strong => 8,                 # number of strong links 
    :n_weak => 8,                   # number of weak links
    :consumer_type => GOLDENBERG,   # default consumer type
    :network => NETWORK_GOLDENBERG, # network type
    :network_fixed => false,        # use fixed network
    :network_fixed_pool => true,    # use fixed pool of networks
    :d => 0.15,                     # percentage of low-quality units
    :p => 0.005,                    # inital advertisement probability
    :q_s => 0.04,                   # strong-tie interaction probability
    :q_w => 0.001,                  # weak-tie interaction probability
    :m => 2,                        # multiplier negative WoM
    :quality_std => 0.1,            # standard deviation quality
    :bayes_theta_adopt => 0.76,     # Bayes: probability threshold adopt
    :bayes_theta_reject => 0.81,    # Bayes: probability threshold reject
    :bayes_init_var => 10.0,        # Bayes: initial belief variance
    :bayes_init_mean => 0.0,        # Bayes: initial belief mean
    :comm_var_strong_ties => 0.5,   # Bayes: communication variance strong ties
    :comm_var_weak_ties => 1.0,     # Bayes: communication variance weak ties
    :cosita_w_weak => 0.5,          # Cosita: weight weak tie signals
    :cosita_w_strong => 1.0,        # Cosita: weight strong tie signals
    :cosita_u_min => 0.0,           # Cosita: minimum utility for adoption
    :cosita_v_min => 4,             # Cosita: minimum information points for decision
    :cosita_h => 5.0,               # Cosita: height difference threshold for dominant mode
    :cosita_d => 0.15,              # Cosita: TVD threshold for closeness to normal distribution
    :cosita_window_size => 50,      # Cosita: size of signal storage
    :consumers => Array{Consumer},
)

# Function to set up the initial state of the model
function initialize(properties)
    model = StandardABM(Consumer, model_step! = model_step!, properties = properties, warn = false)

    actual_mean_quality_bad = -0.5
    actual_mean_quality_good = 0.5

    model.consumers = Array{Consumer, 1}()
    for i in 1:model.n
        consumer = add_agent!(Consumer, model)

        consumer.type = model.consumer_type

        push!(consumer.products, ProductData(POTENTIAL_ADOPTER, 0.0, true, 0.0,0.0,OrderedSet{Float64}(),OrderedSet{Float64}(),false))

        consumer.products[1].belief_quality_mean = model.bayes_init_mean
        consumer.products[1].belief_quality_variance = model.bayes_init_var

        consumer.cosita_u_min = model.cosita_u_min
        consumer.cosita_v_min = model.cosita_v_min
        consumer.cosita_d = model.cosita_d
        consumer.cosita_h = model.cosita_h

        consumer.pos_x = rand()
        consumer.pos_y = rand()

        if rand(abmrng(model)) < model.d
            consumer.products[1].quality_obtained = rand(abmrng(model), Normal(actual_mean_quality_bad, model.quality_std))
        else
            consumer.products[1].quality_obtained = rand(abmrng(model), Normal(actual_mean_quality_good, model.quality_std))
        end

        if consumer.products[1].quality_obtained > 0.0
            consumer.products[1].will_be_happy = true
        else
            consumer.products[1].will_be_happy = false
        end

        push!(model.consumers, consumer)
    end

    # Network

    total_edges = 0;

    if !model.network_fixed_pool && !model.network_fixed
        if model.network == NETWORK_GOLDENBERG
            for x in 1:Int(ceil(model.n / (model.n_strong+1)))
                a = 1 + (x-1) * (model.n_strong+1)
                b = min(length(model.consumers), x * (model.n_strong+1))

                for i in a:b
                    model.consumers[i].clique_id = x
                    
                    for j in a:b
                        if i != j
                            push!(model.consumers[i].strong_ties, model.consumers[j])

                            total_edges+=1
                        end
                    end
                end
            end

            total_edges = total_edges / 2
        end

        if model.network == NETWORK_WATTS_STROGATZ
            k = 8    # Each node is connected to k nearest neighbors
            p = 0.1  # Rewiring probability

            for i in 1:model.n
                for j in 1:Int(k/2)
                    neighbor = mod1(i + j, model.n)
                    push!(model.consumers[i].strong_ties, model.consumers[neighbor])
                    push!(model.consumers[neighbor].strong_ties, model.consumers[i])

                    total_edges+=1
                end
            end

            # Rewire edges with probability p
            for i in 1:model.n
                for j in 1:Int(k/2)
                    neighbor = mod1(i + j, model.n)
                    if rand() < p
                        new_neighbor = rand(abmrng(model), setdiff(1:model.n, [i, neighbor]))  # Avoid self-loops

                        delete!(model.consumers[i].strong_ties, model.consumers[neighbor])
                        delete!(model.consumers[neighbor].strong_ties, model.consumers[i])

                        push!(model.consumers[i].strong_ties, model.consumers[new_neighbor])
                        push!(model.consumers[new_neighbor].strong_ties, model.consumers[i])
                    end
                end
            end
        end

        if model.network == NETWORK_BARABASI_ALBERT
            n_link = 3
            alpha = -5
            beta = 1

            # Barabasi-Albert network
            for id in 1:n_link+1
                for id2 in 1:n_link+1
                    if id != id2
                        push!(model.consumers[id].strong_ties, model.consumers[id2])
                        push!(model.consumers[id2].strong_ties, model.consumers[id])

                        total_edges+=1
                    end
                end
            end


            for id in (n_link+2):model.n
                total_score = 0
                scores = zeros(id-1)
                for id2 in 1:id-1
                    scores[id2] = length(model.consumers[id2].strong_ties)^beta*distance(model.consumers[id],model.consumers[id2])^alpha
                    total_score += scores[id2]
                end

                weights = map(s -> s/total_score, scores)

                friends_sample = sample(1:id-1, Weights(weights), n_link, replace=false, ordered=false)

                for fid in friends_sample
                    push!(model.consumers[fid].strong_ties, model.consumers[id])
                    push!(model.consumers[id].strong_ties, model.consumers[fid])

                    total_edges+=1
                end
            end
        end

        if model.network == NETWORK_ERDOS_RENYI
            p = 0.0025  # Connection probability
        
            for i in 1:model.n
                for j in (i+1):model.n  # Only consider each pair once
                    if rand(abmrng(model)) < p
                        push!(model.consumers[i].strong_ties, model.consumers[j])
                        push!(model.consumers[j].strong_ties, model.consumers[i])

                        total_edges+=1
                    end
                end
            end
        end
    else
        if model.network_fixed
            load_network(model, 1)
        else
            if model.network_fixed_pool
                load_network(model, model.run_id)
            end
        end
    end

    return model
end

function get_network_path(type)
    if type==NETWORK_ERDOS_RENYI
        path = "../data/networks/erdos_renyi/"
    end

    if type==NETWORK_BARABASI_ALBERT
        path = "../data/networks/barabasi_albert/"
    end

    if type==NETWORK_WATTS_STROGATZ
        path = "../data/networks/watts_strogatz/"
    end

    if type==NETWORK_GOLDENBERG
        path = "../data/networks/goldenberg/"
    end

    return path
end

function load_network(model,number)
    path = get_network_path(model.network)

    total_edges=0
    for line in eachline("$path/$number.csv")
        i_str, j_str = split(line, ',')
        i = parse(Int, i_str)
        j = parse(Int, j_str)
    
        push!(model.consumers[i].strong_ties, model.consumers[j])
        push!(model.consumers[j].strong_ties, model.consumers[i])
        total_edges+=1
    end
end

function save_network(model,number)
    path = get_network_path(model.network)
    mkpath(path)

    open("$path/$number.csv", "w") do io
        for i in 1:model.n
            for neighbor in model.consumers[i].strong_ties
                j = neighbor.id  
                if i < j  # avoid duplicates (assuming undirected)
                    println(io, "$i,$j")
                end
            end
        end
    end
end

function distance(c1::Consumer, c2::Consumer)
    return sqrt((c1.pos_x-c2.pos_x)^2+(c1.pos_y-c2.pos_y)^2)
end

function clustering_coefficient(model)
    total_C = 0.0
    n = model.n

    for consumer in model.consumers
        neighbors = consumer.strong_ties
        k = length(neighbors)
        if k < 2
            continue  # Clustering coefficient is 0 if fewer than 2 neighbors
        end

        # Count links between neighbors
        links = 0
        neighbor_list = collect(neighbors)

        for i in 1:k-1
            for j in i+1:k
                if neighbor_list[j] in neighbor_list[i].strong_ties
                    links += 1
                end
            end
        end

        max_links = k * (k - 1) / 2
        total_C += links / max_links
    end

    return total_C / n
end