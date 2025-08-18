function update_state_original_paper_simulated(consumer, i, model)
    if consumer.products[i].state == POTENTIAL_ADOPTER
        has_adopted_something_else = false

        for j in 1:length(consumer.products)
            if consumer.products[j].state == POSITIVE_ADOPTER || consumer.products[j].state == NEGATIVE_ADOPTER
                has_adopted_something_else = true
            end
        end

        pos_signals = 0
        neg_signals = 0

        # Advertising
        affected_by_ad = false
        if rand(abmrng(model)) < model.p && !has_adopted_something_else
            affected_by_ad = true
        end

        # Strong ties
        for contact in consumer.strong_ties
            if contact.products[i].state == POSITIVE_ADOPTER || contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_s
                    pos_signals += 1
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER || contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_s
                    neg_signals += 1
                end
            end
        end

        # Weak ties
        for contact in consumer.weak_ties
            if contact.products[i].state == POSITIVE_ADOPTER || contact.products[i].state == POSITIVE_INFORMER
                if rand(abmrng(model)) < model.q_w
                    pos_signals += 1
                end
            end

            if contact.products[i].state == NEGATIVE_ADOPTER || contact.products[i].state == REJECTER
                if rand(abmrng(model)) < model.m * model.q_w
                    neg_signals += 1
                end
            end
        end

        # Transitions
        if pos_signals == 0 && neg_signals == 0
            s = NONE
        end

        if pos_signals > 0 && neg_signals == 0
            s = ADOPT
        end

        if pos_signals == 0 && neg_signals > 0
            s = REJECT
        end

        if pos_signals > 0 && neg_signals > 0
            alpha = pos_signals/(pos_signals + neg_signals)

            if rand(abmrng(model)) < alpha
                s = ADOPT
            else
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

function get_opinion_original_paper_simulated(consumer::Consumer, i, model)
    if consumer.products[i].state == POSITIVE_ADOPTER || consumer.products[i].state == NEGATIVE_ADOPTER
        return consumer.products[i].quality_obtained
    else
        if consumer.products[i].state == POSITIVE_INFORMER
            return 0.5
        end

        if consumer.products[i].state == REJECTER
            return -0.5
        end
    end

    return nothing
end