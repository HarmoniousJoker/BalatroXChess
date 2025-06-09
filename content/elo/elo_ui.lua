elo_ui = {}
ELO = {}

local draggable_container = require('elo.draggablecontainer')

elo_ui.has_dynamic_shadow_colour = false

elo_ui.style = {
        shadow_colour_ref = 'shadow',
        outer_colour_ref = 'back',
        inner_colour = G.C.DYN_UI.BOSS_DARK,
        outer_width = 1.45,
        outer_height = 1.15,
        outer_padding = 0.01,
        inner_width = 1.2,
        inner_height = 0.7,
        emboss_amount = 0.05,
        heading_text = 'ELO',
        text_shadow = true,
        position = {
            x = 2.936,
            y = 10.394
        }
}

local function calculate_max_text_width()
    local font = G.LANG.font
    local width = 0
    local string = G.PROFILES[G.SETTINGS.profile].chess.elo
    for _, c in utf8.chars(string) do
        local dx = font.FONT:getWidth(c) * 0.6 * G.TILESCALE * font.FONTSCALE
        dx = dx + 3 * G.TILESCALE * font.FONTSCALE
        dx = dx / (G.TILESIZE * G.TILESCALE)
        width = width + dx
    end
    return width
end

local function create_elo_DynaText(text_size, colours, shadow, float, silent)
    local dynaText = DynaText({
        string = { {
            ref_table = G.PROFILES[G.SETTINGS.profile].chess,
            ref_value = "elo"
        } },
        colours = colours,
        scale = text_size,
        shadow = shadow,
        pop_in_rate = 9999999,
        float = float,
        silent = silent,
    })

    return {
        n = G.UIT.O,
        config = {
            align = 'cm',
            id = 'elo_text',
            object = dynaText
        }
    }
end


local function create_elo_UIBox(style_name, text_size, float)
    style_name = style_name or 'simple'
    text_size = text_size or 1

    local colours = {text = G.C.WHITE, back = G.C.BLACK, shadow = darken(G.C.BLACK, 0.3)}

    local style = elo_ui.style or {}

    elo_ui.has_dynamic_shadow_colour = style.shadow_colour_ref == 'shadow'

    local panel_outer_colour = style.outer_colour or style.outer_colour_ref and colours[style.outer_colour_ref] or G.C.CLEAR
    local panel_inner_colour = style.inner_colour or style.inner_colour_ref and colours[style.inner_colour_ref] or G.C.CLEAR
    local panel_shadow_colour = style.shadow_colour or style.shadow_colour_ref and colours[style.shadow_colour_ref] or G.C.CLEAR
    local text_colours = style.text_colours or (style.text_colour and { style.text_colour }) or (style.text_colour_ref and { colours[style.text_colour_ref] }) or { colours.text }

    local text_width = math.max(style.inner_width or 0)
    return {
        n = G.UIT.ROOT,
        config = {
            align = 'tm',
            colour = panel_shadow_colour,
            padding = style.shadow_padding,
            minw = 0.1,
            r = 0.1
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = 'cm',
                    colour = panel_outer_colour,
                    padding = style.outer_padding,
                    minh = style.outer_height,
                    minw = style.outer_width,
                    r = 0.1
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { padding = style.outer_padding },
                        nodes = {
                            style.heading_text and {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    padding = 0.02
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = 'ELO',
                                            minh = 1,
                                            scale = 0.85 * 0.4,
                                            colour = G.C.UI.TEXT_LIGHT,
                                            shadow = style.text_shadow
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {
                                    align = 'cm',
                                    colour = panel_inner_colour,
                                    padding = style.inner_padding,
                                    minh = style.inner_height,
                                    minw = style.inner_width,
                                    r = 0.1,
                                },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = {
                                            align = 'cm',
                                            padding = style.text_padding,
                                            minw = text_width,
                                            r = 0.1
                                        },
                                        nodes = { create_elo_DynaText(text_size, text_colours, style.text_shadow, float, true) }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { minh = style.emboss_amount }
            }
        }
    }
end

local function create_UIBox_position_sliders()
	return {
		n = G.UIT.ROOT,
		config = { align = 'cm', colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = 'tm' },
				nodes = {
					create_slider({
						label = locale.translate('elo_x_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = elo_ui.style.position,
						ref_value = 'x',
						w = 4,
						min = -4,
						max = 22,
						step = 0.01,
						decimal_places = 2,
						callback = 'elo_slider_clock_position_x'
					})
				}
			},
			{
				n = G.UIT.R,
				config = { minh = 0.22 },
			},
			{
				n = G.UIT.R,
				config = { align = 'bm' },
				nodes = {
					create_slider({
						label = locale.translate('elo_y_position_setting'),
						scale = 0.8,
						label_scale = 0.8 * 0.5,
						ref_table = elo_ui.style.position,
						ref_value = 'y',
						w = 4,
						min = -3,
						max = 13,
						step = 0.01,
						decimal_places = 2,
						callback = 'elo_slider_clock_position_y'
					})
				}
			}
		}
	}
end

local function rebuild_UIBox_element(uie_id, build_func, juice)
	if not G.OVERLAY_MENU or not config_ui.is_open then return end
	local ui_element = G.OVERLAY_MENU:get_UIE_by_ID(uie_id)
	if not ui_element then
		return
	end

	ui_element.config.object:remove()
	ui_element.config.object = UIBox {
		config = { offset = { x = 0, y = 0 }, parent = ui_element },
		definition = build_func()
	}
	ui_element.UIBox:recalculate()
	ui_element.config.object:set_role {
		role_type = 'Major',
		major = nil
	}

	if juice then ui_element.config.object:juice_up(0.05, 0.03) end
	return ui_element
end

function elo_ui.update_position_sliders(juice)
	rebuild_UIBox_element('elo_config_position_sliders', create_UIBox_position_sliders, juice)
end

function elo_ui.set_position(pos)
	elo_ui.style.position = pos
	elo_ui.update_position_sliders()
end


function elo_ui.reset(juice)
    local prev_pos
    if G.HUD_elo then
        prev_pos = { x = G.HUD_elo.T.x, y = G.HUD_elo.T.y }
        G.HUD_elo:remove()
    end
    if config.elo_visible then
        local position = elo_ui.style.position
        prev_pos = prev_pos or position


        G.HUD_elo = draggable_container(
            {
                T = { x = position.x, y = position.y },
                VT = { x = prev_pos.x, y = prev_pos.y },
                config = {
                    major = G,
                    bond = 'Weak',
                    instance_type = ELO.draw_as_popup and 'POPUP',
                },
                definition = create_elo_UIBox(
                    'throwback',
                    0.6,
                    true
                ),
                zoom = true,
                can_drag = config.elo_allow_drag
            }
        )

        local temporary_drag = false

        G.HUD_elo.drag = function(self)
            if not config.elo_allow_drag then
                temporary_drag = true
                ELO.set_draggable(true, true)
            end
            draggable_container.drag(self)
        end

        G.HUD_elo.stop_drag = function(self)
            draggable_container.stop_drag(self)
            elo_ui.set_position({ x = self.T.x, y = self.T.y })
            if temporary_drag then
                ELO.set_draggable(false, true)
                temporary_drag = false
            end
        end

        if juice then G.HUD_elo:juice_up(0.1, 0.1) end
    end
end

return elo_ui
