SMODS.Joker {
	key = "knight",
	atlas = "joker",
	pos = { x = 1, y = 0 },
	rarity = 2,
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	config = { extra = { odds = 2 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_steel
	end,
	calculate = function(self, card, context)
		if context.after and context.scoring_name == "Pair" then
			local scored_lookup = {}
			for _, v in ipairs(context.scoring_hand) do
				scored_lookup[v] = true
			end
			local unscored_cards = {}
			for _, v in ipairs(G.play.cards) do
				if not scored_lookup[v] then
					table.insert(unscored_cards, v)
				end
			end
			if #unscored_cards == 1 then
				if pseudorandom("knight") < G.GAME.probabilities.normal / card.ability.extra.odds then
					CH_UTIL.transform_card(unscored_cards[1], "m_steel")
					return {
						message = "Knighted!",
						message_card = unscored_cards[1]
					}
				end
			end
		end
	end
}
