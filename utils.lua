--Function to transform a card
function CH_UTIL.transform_card(old_card, center, edition)
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.15,
        func = function()
            old_card:flip()
            return true
        end,
    }))
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.15,
        func = function()
            if center then
                old_card:set_ability(G.P_CENTERS[center])
            end
            if edition then
                old_card:set_edition(edition)
            end
            play_sound("card1")
            old_card:juice_up(0.3, 0.3)
            return true
        end,
    }))
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.15,
        func = function()
            old_card:flip()
            return true
        end,
    }))
end
