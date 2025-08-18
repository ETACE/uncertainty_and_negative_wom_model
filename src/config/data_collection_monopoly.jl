when_collect(model, s) = true

positive_adopters(m) = sum(map(c -> c.products[1].state == POSITIVE_ADOPTER, m.consumers))
negative_adopters(m) = sum(map(c -> c.products[1].state == NEGATIVE_ADOPTER, m.consumers))
adopters1(m) = sum(map(c -> c.products[1].state == POSITIVE_ADOPTER || c.products[1].state == NEGATIVE_ADOPTER, m.consumers))
rejecters1(m) = sum(map(c -> c.products[1].state == REJECTER, m.consumers))
undecided1(m) = sum(map(c -> c.products[1].state == POTENTIAL_ADOPTER, m.consumers))

adopters1_cosita(m) = sum(map(c -> (c.type == COSITA && (c.products[1].state == POSITIVE_ADOPTER || c.products[1].state == NEGATIVE_ADOPTER)), m.consumers))
adopters1_bayes(m) = sum(map(c -> (c.type == BAYES_NORMAL && (c.products[1].state == POSITIVE_ADOPTER || c.products[1].state == NEGATIVE_ADOPTER)), m.consumers))
adopters1_goldenberg(m) = sum(map(c -> (c.type == GOLDENBERG && (c.products[1].state == POSITIVE_ADOPTER || c.products[1].state == NEGATIVE_ADOPTER)), m.consumers))

rejecters1_cosita(m) = sum(map(c -> (c.type == COSITA && (c.products[1].state == REJECTER)), m.consumers))
rejecters1_bayes(m) = sum(map(c -> (c.type == BAYES_NORMAL && (c.products[1].state == REJECTER)), m.consumers))
rejecters1_goldenberg(m) = sum(map(c -> (c.type == GOLDENBERG && (c.products[1].state == REJECTER)), m.consumers))

avg_quality(m) = get_avg_quality_bought(m)
avg_quality_goldenberg(m) = get_avg_quality_bought_by_type(m, GOLDENBERG)
avg_quality_bayes(m) = get_avg_quality_bought_by_type(m, BAYES_NORMAL)
avg_quality_cosita(m) = get_avg_quality_bought_by_type(m, COSITA)

mdata = [positive_adopters, negative_adopters, adopters1, rejecters1, undecided1,
adopters1_cosita, adopters1_bayes, adopters1_goldenberg,
rejecters1_cosita, rejecters1_bayes, rejecters1_goldenberg, 
avg_quality, avg_quality_goldenberg, avg_quality_bayes, avg_quality_cosita]
adata = nothing

function get_avg_quality_bought(m)
    sum_q = 0
    n = 0

    for c in m.consumers
        if c.product_bought
            sum_q+=c.quality_bought
            n+=1
        end
    end

    if n>0
        return sum_q/n
    end

    return 0.0
end

function get_avg_quality_bought_by_type(m, type)
    sum_q = 0
    n = 0

    for c in m.consumers
        if c.product_bought && c.type == type
            sum_q+=c.quality_bought
            n+=1
        end
    end

    if n>0
        return sum_q/n
    end

    return 0.0
end