function CH_UTIL.calculate_initial_elo(progress)

    -- Initialize ELO to a baseline value
    local elo = 1500

    -- Collection progress: +2 points per 1%
    if progress.discovered and progress.discovered.of > 0 then
        local collection_pct = (progress.discovered.tally / progress.discovered.of) * 100
        elo = elo + 2 * collection_pct
    end

    -- Deck stakes: +3 points per 1%
    if progress.deck_stakes and progress.deck_stakes.of > 0 then
        local stake_pct = (progress.deck_stakes.tally / progress.deck_stakes.of) * 100
        elo = elo + 3 * stake_pct
    end

    -- Joker stickers: +5 points per 1%
    if progress.joker_stickers and progress.joker_stickers.of > 0 then
        local sticker_pct = (progress.joker_stickers.tally / progress.joker_stickers.of) * 100
        elo = elo + 5 * sticker_pct
    end

    -- Challenges completed: +50 per challenge beat
    if progress.challenges then
        local completed = progress.challenges.tally
        elo = elo + (completed * 50)
    end

    -- Store the tally values for future computation of ELO
    if not G.PROFILES[G.SETTINGS.profile].chess then
        G.PROFILES[G.SETTINGS.profile].chess = {}
    end
    G.PROFILES[G.SETTINGS.profile].chess.elo = math.floor(elo + 0.5)
    G.PROFILES[G.SETTINGS.profile].chess.baseline_progress = {
        joker_stickers = G.PROFILES[G.SETTINGS.profile].progress.joker_stickers.tally,
        deck_stakes = G.PROFILES[G.SETTINGS.profile].progress.deck_stakes.tally,
        discovered = G.PROFILES[G.SETTINGS.profile].progress.discovered.tally,
        challenges = G.PROFILES[G.SETTINGS.profile].progress.challenges.tally
    }
end

function CH_UTIL.update_elo_from_progress(profile)
    local progress = profile.progress
    local baseline = profile.chess.baseline_progress or {}
    local old_elo = profile.chess.elo or 1500
    local elo_delta = 0

    -- Joker Stickers (% difference × 5)
    if progress.joker_stickers and progress.joker_stickers.of > 0 then
        local delta = progress.joker_stickers.tally - (baseline.joker_stickers or 0)
        local percent_delta = (delta / progress.joker_stickers.of) * 100
        elo_delta = elo_delta + (5 * percent_delta)
        baseline.joker_stickers = progress.joker_stickers.tally
    end

    -- Deck Stakes (% difference × 3)
    if progress.deck_stakes and progress.deck_stakes.of > 0 then
        local delta = progress.deck_stakes.tally - (baseline.deck_stakes or 0)
        local percent_delta = (delta / progress.deck_stakes.of) * 100
        elo_delta = elo_delta + (3 * percent_delta)
        baseline.deck_stakes = progress.deck_stakes.tally
    end

    -- Discovered Collection (% difference × 2)
    if progress.discovered and progress.discovered.of > 0 then
        local delta = progress.discovered.tally - (baseline.discovered or 0)
        local percent_delta = (delta / progress.discovered.of) * 100
        elo_delta = elo_delta + (2 * percent_delta)
        baseline.discovered = progress.discovered.tally
    end

    -- Challenges completed (× 50 each new one)
    local delta_challenges = progress.challenges.tally - (baseline.challenges or 0)
    if delta_challenges > 0 then
        elo_delta = elo_delta + (delta_challenges * 50)
        baseline.challenges = progress.challenges.tally
    end

    elo_delta = math.floor(elo_delta + 0.5)
    print("ELO gain for game progress: " .. elo_delta)
    profile.chess.elo = old_elo + elo_delta
end

function CH_UTIL.get_rating_change(rating, stake_name, did_win)
    if stake_name == "Unknown" then
        print("Error: Unknown stake name provided.")
        return 0
    end

    local stakes = {
        stake_white = {gain = 50, loss = -50},
        stake_red = {gain = 75, loss = -45},
        stake_green = {gain = 125, loss = -35},
        stake_black = {gain = 150, loss = -30},
        stake_blue = {gain = 200, loss = -20},
        stake_purple = {gain = 250, loss = -15},
        stake_orange = {gain = 275, loss = -10},
        stake_gold = {gain = 350, loss = -5},
    }

    local categories = {
        {upper = 1000},  -- Novice
        {upper = 1199},  -- Class E
        {upper = 1399},  -- Class D
        {upper = 1599},  -- Class C
        {upper = 1799},  -- Class B
        {upper = 1999},  -- Class A
        {upper = 2199},  -- Expert
        {upper = 2299},  -- Candidate Master
        {upper = 2399},  -- FIDE Master
        {upper = 2499},  -- International Master
        {upper = 2599},  -- Grandmaster
        {upper = math.huge}  -- Super GM
    }

    -- Get the category index
    local cat_index = 1
    for i, cat in ipairs(categories) do
        if rating <= cat.upper then
            cat_index = i
            break
        end
    end

    local base = stakes[stake_name]
    if not base then return 0 end

    -- Scaling logic
    local level = cat_index - 1
    local gain_mult = math.max(0.4, 1 - 0.08 * (level ^ 1.2))
    local loss_mult = 1 + 0.06 * (level ^ 1.1)

    local gain = math.floor(base.gain * gain_mult + 0.5)
    local loss = math.floor(base.loss * loss_mult + 0.5)

    -- Cap loss for low ratings
    if cat_index <= 4 and math.abs(loss) > gain then
        loss = -gain
    end

    if did_win then
        print("ELO gain for " .. stake_name .. ": " .. gain)
        return gain
    else
        print("ELO loss for " .. stake_name .. ": " .. loss)
        return loss
    end
end

-- Initial ELO calculation
if not G.PROFILES[G.SETTINGS.profile].chess then
    CH_UTIL.calculate_initial_elo(G.PROFILES[G.SETTINGS.profile].progress)
end

-- Hook for game start
local base_game_start = Game.start_run
function Game:start_run(args)
    base_game_start(self, args)
    print("Starting game with ELO: " .. G.PROFILES[G.SETTINGS.profile].chess.elo)
    G.PROFILES[G.SETTINGS.profile].chess.current_stake = SMODS.stake_from_index(G.GAME.stake)
    G.PROFILES[G.SETTINGS.profile].chess.elo_update = false
end

-- Hooks for end of run
local base_win_game = win_game
local base_game_over = Game.update_game_over
function win_game()
    if not G.PROFILES[G.SETTINGS.profile].chess.elo_update then
        G.PROFILES[G.SETTINGS.profile].chess.elo = G.PROFILES[G.SETTINGS.profile].chess.elo + CH_UTIL.get_rating_change(G.PROFILES[G.SETTINGS.profile].chess.elo,G.PROFILES[G.SETTINGS.profile].chess.current_stake,true)
        CH_UTIL.update_elo_from_progress(G.PROFILES[G.SETTINGS.profile])
        print("ELO updated to: " .. G.PROFILES[G.SETTINGS.profile].chess.elo)
        G.PROFILES[G.SETTINGS.profile].chess.elo_update = true
    end
    base_win_game()
end

function Game:update_game_over(dt)
    if not G.PROFILES[G.SETTINGS.profile].chess.elo_update then
        if G.GAME.round_resets.ante <= G.GAME.win_ante then
            if not G.GAME.seeded and not G.GAME.challenge then
                G.PROFILES[G.SETTINGS.profile].chess.elo = G.PROFILES[G.SETTINGS.profile].chess.elo + CH_UTIL.get_rating_change(G.PROFILES[G.SETTINGS.profile].chess.elo,G.PROFILES[G.SETTINGS.profile].chess.current_stake,false)
                CH_UTIL.update_elo_from_progress(G.PROFILES[G.SETTINGS.profile])
            end
        end
        print("ELO updated to: " .. G.PROFILES[G.SETTINGS.profile].chess.elo)
        G.PROFILES[G.SETTINGS.profile].chess.elo_update = true
    end
    base_game_over(self, dt)
end
