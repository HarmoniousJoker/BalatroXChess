SMODS.Joker {
    key = "rook",
    blueprint_compat = true,
    rarity = 3,
    cost = 5,
    atlas = "joker",
    pos = { x = 0, y = 0 },
    config = { extra = { mult = 5, mult_mod = 5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, "m_stone") then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
        if context.before and not context.blueprint then
            local flag = true
            for _, v in ipairs(context.full_hand) do
                if not SMODS.has_enhancement(v, "m_stone") then
                    flag = false
                end
            end
            if flag then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT
                }
            end
        end
    end,
}
