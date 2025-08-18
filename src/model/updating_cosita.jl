using QuadGK

function add_signal(consumer, contact, i, signal, weight, model)
    r = rand(abmrng(model), Normal(0.0, sqrt(0.0000000001)))
    push!(consumer.products[i].cosita_info_set, Info(signal + r, weight))
    if consumer.cosita_v_min == 1
        r = rand(abmrng(model), Normal(0.0, sqrt(0.0000000001)))
        push!(consumer.products[i].cosita_info_set, Info(signal + rand(abmrng(model), Normal(0.0, sqrt(0.0000001))), weight))
    end

    if length(consumer.products[i].cosita_info_set) > model.cosita_window_size
        popfirst!(consumer.products[i].cosita_info_set) # Delete oldest element
    end

    consumer.products[i].received_signal = true

    consumer.last_signal = signal
end

function update_state_cosita(consumer, i, model)    
    consumer.products[i].received_signal = false

    if consumer.products[i].state == POTENTIAL_ADOPTER
        has_adopted_something_else = false

        for j in 1:length(consumer.products)
            if consumer.products[j].state == POSITIVE_ADOPTER || consumer.products[j].state == NEGATIVE_ADOPTER
                has_adopted_something_else = true
            end
        end

        # Advertising
        affected_by_ad = false
        if rand(abmrng(model)) < model.p && !has_adopted_something_else
            affected_by_ad = true
        end

        # Strong ties
        for contact in consumer.strong_ties
            if contact.products[i].state == POSITIVE_ADOPTER
                if rand(abmrng(model)) < model.q_s
                    add_signal(consumer, contact, i, contact.products[i].quality_obtained, model.cosita_w_strong, model)
                end
            end

            if contact.products[i].state == contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_s
                    add_signal(consumer, contact, i, get_opinion(contact, i, model), model.cosita_w_strong, model)
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER
                if rand(abmrng(model)) < model.m * model.q_s
                    add_signal(consumer, contact, i, contact.products[i].quality_obtained, model.cosita_w_strong, model)
                end
            end

            if contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_s
                    add_signal(consumer, contact, i, get_opinion(contact, i, model), model.cosita_w_strong, model)
                end
            end
        end

        # Weak ties
        for contact in consumer.weak_ties
            if contact.products[i].state == POSITIVE_ADOPTER
                if rand(abmrng(model)) < model.q_w
                    add_signal(consumer, contact, i, contact.products[i].quality_obtained, model.cosita_w_weak, model)
                end
            end

            if contact.products[i].state == contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_w
                    add_signal(consumer, contact, i, get_opinion(contact, i, model), model.cosita_w_weak, model)
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER
                if rand(abmrng(model)) < model.m * model.q_w
                    add_signal(consumer, contact, i, contact.products[i].quality_obtained, model.cosita_w_weak, model)
                end
            end

            if contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_w
                    add_signal(consumer, contact, i, get_opinion(contact, i, model), model.cosita_w_weak, model)
                end
            end
        end

        # Transitions
        s = NONE
        if consumer.products[i].received_signal
            if length(consumer.products[i].cosita_info_set) >= consumer.cosita_v_min

                dominant_mode = find_dominant_mode(consumer.products[i].cosita_info_set, consumer.cosita_h)

                if !isnan(dominant_mode)
                    if dominant_mode >= consumer.cosita_u_min
                        s = ADOPT
                    end
                    if dominant_mode <= consumer.cosita_u_min
                        s = REJECT
                    end
                else
                    tvd = total_variation_distance(consumer.products[i].cosita_info_set)

                    if tvd < consumer.cosita_d
                        kde_mean = info_mean(consumer.products[i].cosita_info_set)

                        if kde_mean > consumer.cosita_u_min
                            s = ADOPT
                        end
        
                        if kde_mean < -consumer.cosita_u_min
                            s = REJECT
                        end
                    end
                end
            end
        end

        if affected_by_ad
            s = ADOPT
        end

        if s == ADOPT && consumer.products[i].state == POTENTIAL_ADOPTER
            if !has_adopted_something_else
                if consumer.products[i].will_be_happy
                    consumer.products[i].state = POSITIVE_ADOPTER
                else
                    consumer.products[i].state = NEGATIVE_ADOPTER
                end

                consumer.product_bought = true
                consumer.quality_bought = consumer.products[i].quality_obtained
            else
                consumer.products[i].state = POSITIVE_INFORMER
            end
        end

        if s == REJECT
            consumer.products[i].state = REJECTER
        end
    end
end

function pdf_kde_infos(infos, x)
    # Silverman's rule of thumb
    data = collect(map(info -> info.a, collect(infos)))
    q25 = quantile(data, 0.25)
    q75 = quantile(data, 0.75)
    iqr = q75 - q25
    sigma = std(data)
    n = length(data)
    b = 0.9 * min(sigma, iqr / 1.34) * n^(-1 / 5)

    # Kernel Density Estimation
    sum_pdf= 0.0
    sum_w = 0.0

    for info in infos
        sum_pdf += info.weight*pdf(Normal(),(x-info.a)/b)
        sum_w += info.weight
    end

    f = sum_pdf * 1 / (sum_w * b)

    return f
end

function find_peaks(infos)
    peaks = Float64[]

    z = 0.01

    for x in -1:z:1
        if pdf_kde_infos(infos, x) > pdf_kde_infos(infos, x-z) && pdf_kde_infos(infos, x) > pdf_kde_infos(infos, x+z)
            push!(peaks, x)
        end
    end

    return peaks
end

function info_mean(infos)
    sum_wa = sum(map(info -> info.weight * info.a, collect(infos)))
    sum_w = sum(map(info -> info.weight, collect(infos)))

    @assert !isnan(sum_wa / sum_w)

    return sum_wa / sum_w
end

function info_variance(infos)
    sum_w = sum(map(info -> info.weight, collect(infos)))
    sum_w2 = sum(map(info -> info.weight^2, collect(infos)))
    mean = info_mean(infos)

    var = sum_w/(sum_w^2-sum_w2)*sum(map(info -> info.weight*(info.a-mean)^2, collect(infos)))

    return var
end

function total_variation_distance(infos)
    mean = info_mean(infos)
    std = sqrt(info_variance(infos))

    tvd, _ = quadgk(x ->  abs(pdf_kde_infos(infos, x) - pdf(Normal(mean,std), x)), -Inf, Inf)

    return 0.5 * tvd
end

function find_dominant_mode(infos, h)
    peaks = find_peaks(infos)

    if length(peaks) == 1 
        return peaks[1]
    end

    for p in peaks
        dom = true
        for p2 in peaks
            if p != p2
                if pdf_kde_infos(infos, p) / pdf_kde_infos(infos, p2) < h
                    dom = false
                end
            end
        end
        if dom
            return p
        end
    end

    return NaN
end

function assert_infosets_good(consumer)
    for product in consumer.products
    
        data = collect(map(info -> info.a, collect(product.cosita_info_set)))

        for d in data
            @assert !isnan(d)
        end
    end
end

function get_opinion_cosita(consumer::Consumer, i, model)
    if consumer.products[i].state == POSITIVE_ADOPTER || consumer.products[i].state == NEGATIVE_ADOPTER
        return consumer.products[i].quality_obtained
    else
        if length(consumer.products[i].cosita_info_set) == 0
            return nothing
        end

        return info_mean(consumer.products[i].cosita_info_set)
    end
end