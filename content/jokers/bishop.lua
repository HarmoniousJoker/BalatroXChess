SMODS.Joker {
    key = "bishop",
    blueprint_compat = true,
    rarity = 2,
    cost = 4,
    atlas = "joker",
    pos = { x = 0, y = 0 },
    config = { extra = { money = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, "m_gold") then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                ease_dollars(card.ability.extra.money)
                return {
                    message = localize { type = "variable", key = "a_ch_money", vars = { card.ability.extra.money } },
                    message_card = context.other_card,
                    colour = G.C.GOLD
                }
            end
        end
    end,
}
