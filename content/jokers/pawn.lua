SMODS.Joker {
    key = "pawn",
    blueprint_compat = true,
    perishable_compat = false,
    rarity = 1,
    cost = 4,
    atlas = "joker",
    pos = { x = 0, y = 0 },
    config = { extra = { hand_add = 10, discard_sub = 5, chips = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hand_add, card.ability.extra.discard_sub, card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint and context.other_card == context.full_hand[#context.full_hand] then
            local prev_mult = card.ability.extra.chips
            card.ability.extra.chips = math.max(0, card.ability.extra.chips - card.ability.extra.discard_sub)
            if card.ability.extra.chips ~= prev_mult then
                return {
                    message = localize { type = 'variable', key = 'a_chips_minus', vars = { card.ability.extra.discard_sub } },
                    colour = G.C.BLUE
                }
            end
        end
        if context.before and context.main_eval and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.hand_add
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.hand_add } },
                colour = G.C.BLUE
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}
