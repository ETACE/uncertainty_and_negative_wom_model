using Agents
using Random
using Dates

include("consumer.jl")

include("updating_goldenberg.jl")
include("updating_bayes_normal.jl")
include("updating_cosita.jl")

function comsumer_scheduler_randomly(model::ABM)
    return shuffle!(abmrng(model), collect(keys(model.consumers)))
end

function consumers(f, model::ABM)
    for id in comsumer_scheduler_randomly(model)
        f(model.consumers[id], model)
    end
end

# Implements model_step! function from Agents.jl framework.
function model_step!(model)
    if abmtime(model) % 100 == 0      
        println("[$(now())]\t", abmtime(model))

        flush(stdout)
    end

    change_weak_ties(model)
    
    consumers(model) do consumer, model
        update(consumer, model)
    end

    # Advertisement probability
    model.p = model.p * 0.9
end

function change_weak_ties(model)
    avail_cons = OrderedSet{Consumer}()

    for c in model.consumers
        c.weak_ties = OrderedSet{Consumer}()
        push!(avail_cons, c)
    end

    for c in shuffle(abmrng(model), model.consumers)
        zzz = 1
        while length(c.weak_ties) < model.n_weak && length(avail_cons) > 0 && zzz < model.n_weak*10
            crand = rand(abmrng(model), collect(avail_cons))
            zzz +=1
            if crand.id != c.id && !(crand in c.weak_ties) && !(crand in c.strong_ties)
                push!(c.weak_ties, crand)
                push!(crand.weak_ties, c)
                if length(crand.weak_ties) == model.n_weak
                    delete!(avail_cons, crand)
                end
            end
        end
        if length(c.weak_ties) == model.n_weak
            delete!(avail_cons, c)
        end
    end
end