CH_UTIL = {}

SMODS.load_file("utils.lua")()
config = SMODS.current_mod.config

SMODS.Atlas {
	key = "joker",
	path = "joker.png",
	px = 71,
	py = 95
}

-- File loading
local files = {
    jokers = {
        list = {
            "pawn",
            "knight",
            "bishop",
            "rook"
        },
        directory = "content/jokers"
    },
    elo = {
        list = {
            "elo",
            "draggable_container",
            "elo_ui",
        },
        directory = "content/elo"
    }
}

-- ELO System
CH_UTIL.load_files(files.elo.list, files.elo.directory)


local game_main_menu_ref = Game.main_menu
function Game:main_menu(change_context)
	local ret = game_main_menu_ref(self, change_context)
	elo_ui.reset()
	return ret
end

local game_start_run_ref = Game.start_run
function Game:start_run(args)
	local ret = game_start_run_ref(self, args)
	elo_ui.reset()
	return ret
end

local g_funcs_set_Trance_font_ref = G.FUNCS.set_Trance_font
function G.FUNCS.set_Trance_font(...)
	if g_funcs_set_Trance_font_ref then
		local ret = { g_funcs_set_Trance_font_ref(...) }
		elo_ui.reset()
		return unpack(ret)
	end
end

-- Jokers
CH_UTIL.load_files(files.jokers.list, files.jokers.directory)
