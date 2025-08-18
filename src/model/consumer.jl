using StatsBase
using DataStructures

const POTENTIAL_ADOPTER = 0
const POSITIVE_ADOPTER = 1
const NEGATIVE_ADOPTER = -1
const REJECTER = -2
const POSITIVE_INFORMER = 3
const UNDECIDED_FOREVER = 9

const NONE = 0
const ADOPT = 1
const REJECT = 2

struct Info
    a::Float64
    weight::Float64
end

mutable struct ProductData
    state::Int64
    quality_obtained::Float64
    will_be_happy::Bool
    belief_quality_mean::Float64
    belief_quality_variance::Float64
    information_received::OrderedSet{Float64}
    cosita_info_set::OrderedSet{Info}
    received_signal::Bool
end

@agent struct Consumer(NoSpaceAgent)
    clique_id::Int64 = 0
    pos_x::Float64 = 0.0
    pos_y::Float64 = 0.0
    type::Int64 = GOLDENBERG
    strong_ties::OrderedSet{Consumer} = OrderedSet{Consumer}()
    weak_ties::OrderedSet{Consumer} = OrderedSet{Consumer}()
    products::Array{ProductData} = Array{ProductData, 1}()
    cosita_u_min::Float64 = 0.1
    cosita_v_min::Int64 = 3
    cosita_h::Float64 = 2.0
    cosita_d::Float64 = 0.15
    product_bought::Bool = false
    quality_bought::Float64 = 0.0
    number_neg_signals::Int64 = 0
    number_pos_signals::Int64 = 0
    number_neutral_signals::Int64 = 0
    last_signal::Float64 = 0.0
end

function update(consumer::Consumer, model)
    for i in 1:length(consumer.products)
        if consumer.type == GOLDENBERG
            update_original_paper_simulated(consumer, i, model)
        end

        if consumer.type == BAYES_NORMAL
            update_bayes_normal(consumer, i, model)
        end

        if consumer.type == COSITA
            update_cosita(consumer, i, model)
        end
    end
end

function update_original_paper_simulated(consumer::Consumer, i, model)
    update_state_original_paper_simulated(consumer, i, model)
end

function update_bayes_normal(consumer::Consumer, i, model)
    update_state_bayes_normal(consumer, i, model)
end


function update_cosita(consumer::Consumer, i, model)
    update_state_cosita(consumer, i, model)
end

function get_opinion(consumer::Consumer, i, model)
    if consumer.type == GOLDENBERG
        return get_opinion_original_paper_simulated(consumer, i, model)
    end

    if consumer.type == BAYES_NORMAL
        return get_opinion_bayes_normal(consumer, i, model)
    end

    if consumer.type == COSITA
        return get_opinion_cosita(consumer, i, model)
    end
end