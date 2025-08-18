function update_state_bayes_normal(consumer, i, model)

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
                    signal_mean = contact.products[i].quality_obtained
                    signal_variance = model.comm_var_strong_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_s
                    signal_mean = get_opinion(contact, i, model)
                    signal_variance = model.comm_var_strong_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER
                if rand(abmrng(model)) < model.m * model.q_s
                    signal_mean = contact.products[i].quality_obtained
                    signal_variance = model.comm_var_strong_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_s
                    signal_mean = get_opinion(contact, i, model)

                    signal_variance = model.comm_var_strong_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end
        end

        # Weak ties
        for contact in consumer.weak_ties
            if contact.products[i].state == POSITIVE_ADOPTER
                if rand(abmrng(model)) < model.q_w
                    signal_mean = contact.products[i].quality_obtained
                    signal_variance = model.comm_var_weak_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_w
                    signal_mean = get_opinion(contact, i, model)
                    signal_variance = model.comm_var_weak_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER
                if rand(abmrng(model)) < model.m * model.q_w
                    signal_mean = contact.products[i].quality_obtained
                    signal_variance = model.comm_var_weak_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end

            if contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_w
                    signal_mean = get_opinion(contact, i, model)
                    signal_variance = model.comm_var_weak_ties
        
                    update_belief(consumer, contact, i, signal_mean, signal_variance, model)
                end
            end
        end

        # Transitions
        s = NONE

        if 1 - cdf(Normal(consumer.products[i].belief_quality_mean, sqrt(consumer.products[i].belief_quality_variance)), 0) > model.bayes_theta_adopt
            s = ADOPT
        else
            if cdf(Normal(consumer.products[i].belief_quality_mean, sqrt(consumer.products[i].belief_quality_variance)), 0) > model.bayes_theta_reject
                s = REJECT
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

function update_belief(consumer, contact, i, signal_mean, signal_variance, model)
    if signal_mean < -0.1
        consumer.number_neg_signals += 1
    else
        if signal_mean > 0.1
            consumer.number_neg_signals += 1
        else
            consumer.number_neutral_signals += 1
        end
    end

    if consumer.products[i].belief_quality_variance > 0.0 # If current belief has no variance -> no update
        if signal_variance > 0.0
            tau_perf = 1 / consumer.products[i].belief_quality_variance
            tau_s = 1 / signal_variance

            post_mean = (tau_perf * consumer.products[i].belief_quality_mean + tau_s * signal_mean) / (tau_perf + tau_s)
            post_variance = 1 / (tau_perf + tau_s)

            consumer.products[i].belief_quality_mean = post_mean
            consumer.products[i].belief_quality_variance = post_variance
        else
            consumer.products[i].belief_quality_mean = signal
            consumer.products[i].belief_quality_variance = 0.0
        end
    end
end

function update(belief_mean, belief_variance, signal_mean, signal_variance)
    tau_perf = 1 / belief_variance
    tau_s = 1 / signal_variance

    post_mean = (tau_perf * belief_mean + tau_s * signal_mean) / (tau_perf + tau_s)
    post_variance = 1 / (tau_perf + tau_s)

    return post_mean, post_variance
end


function get_opinion_bayes_normal(consumer::Consumer, i, model)
    if consumer.products[i].state == POSITIVE_ADOPTER || consumer.products[i].state == NEGATIVE_ADOPTER
        return consumer.products[i].quality_obtained
    else
        return consumer.products[i].belief_quality_mean
    end
end