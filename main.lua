CH_UTIL = {}

SMODS.Atlas {
	key = 'joker',
	path = 'joker.png',
	px = 71,
	py = 95
}

-- file loading
local files = {
    jokers = {
        list = {
            "pawn",
        },
        directory = "content/jokers"
    },
}

-- load everything
function CH_UTIL.load_files(items, path)
    for i = 1, #items do
        assert(SMODS.load_file(path .. "/" .. items[i] .. '.lua'))()
    end
end

CH_UTIL.load_files(files.jokers.list, files.jokers.directory)
