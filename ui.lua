--manage buttons for the non-consumables
function Card:create_yorick_ui()
    if to_big(self.ability.immutable.yorick_amount) >= to_big(2) and self.ability.immutable.yorick_amount_text ~= "" then
        if self.children.yorick_ui then
            self.children.yorick_ui:remove()
            self.children.yorick_ui = nil
        end
        self.ability.immutable.yorick_amount_text = self.ability.immutable.yorick_amount_text or number_format(self.ability.immutable.yorick_amount)
        self.children.yorick_ui = UIBox {
			definition = {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.C, config={ref_table = self, align = "tm",maxw = 1.5, padding = 0.1, r=0.08, minw = 0.45, minh = 0.45, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE}, nodes={
                  {n=G.UIT.T, config={text = "x",colour = G.C.RED, scale = 0.35, shadow = true}},
                  {n=G.UIT.T, config={ref_table = self.ability.immutable, ref_value = 'yorick_amount_text',colour = G.C.WHITE, scale = 0.35, shadow = true}}
                }}
              }
			},
			config = {
				align = "tm",
				bond = 'Strong',
				parent = self
			},
			states = {
				collide = { can = false },
				drag = { can = true }
			}
		}
    else
        if self.children.yorick_ui then
            self.children.yorick_ui:remove()
            self.children.yorick_ui = nil
        end
        self.ability.immutable.yorick_amount = 1
    end
end

local oldcardload = Card.load
function Card:load(...)
	oldcardload(self, ...)
	if self.ability and self.ability.immutable and self.ability.immutable.yorick_amount then
        self:create_yorick_ui()
    else
        self.ability.immutable = self.ability.immutable or {}
        self.ability.immutable.yorick_amount = 1
    end
end

local oldcardhighlight = Card.highlight
function Card:highlight(is_higlighted)
    if (self.area == G.jokers or self.area == G.hand) and is_higlighted and self.ability.immutable.yorick_amount and to_big(self.ability.immutable.yorick_amount) > to_big(1) then
        local y = JokerDisplay and JokerDisplay.config.enabled and 0.5 or 0
        self.children.jokersplit_one = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.3,
                    maxh = 0.5,
                    minw = 0.4,
                    maxw = 4,
                    r = 0.08,
                    padding = 0.1,
                    align = 'cm',
                    colour = G.C.DARK_EDITION,
                    shadow = true,
                    button = 'jokersplit_one',
                    func = 'jokercan_split_one',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_split_one"),
                            scale = 0.3,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = y + 0.5
                },
                bond = 'Strong',
                parent = self
            }
        }
        self.children.jokersplit_half = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.3,
                    maxh = 0.5,
                    minw = 0.4,
                    maxw = 4,
                    r = 0.08,
                    padding = 0.1,
                    align = 'cm',
                    colour = G.C.DARK_EDITION,
                    shadow = true,
                    button = 'jokersplit_half',
                    func = 'jokercan_split_half',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_split_half"),
                            scale = 0.3,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = y + 1
                },
                bond = 'Strong',
                parent = self
            }
        }
        if Yorick.can_merge(self) then
            self.children.jokermerge = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'jokermerge',
                        func = 'jokercan_merge',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = y + 1.5
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
            self.children.jokermerge_all = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'jokermerge_all',
                        func = 'jokercan_merge_all',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge_all"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = y + 2
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        end
    else    
        if is_higlighted and Yorick.can_merge(self) then
            local other_y = JokerDisplay and JokerDisplay.config.enabled and 0.5 or 0
            self.children.jokermerge = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'jokermerge',
                        func = 'jokercan_merge',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = other_y + 0.5
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
            self.children.jokermerge_all = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'jokermerge_all',
                        func = 'jokercan_merge_all',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge_all"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = other_y + 1
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        else
            if self.children.jokersplit_one then 
                self.children.jokersplit_one:remove()
                self.children.jokersplit_one = nil
            end
            if self.children.jokersplit_half then 
                self.children.jokersplit_half:remove()
                self.children.jokersplit_half = nil
            end
            if self.children.jokermerge then 
                self.children.jokermerge:remove()
                self.children.jokermerge = nil
            end
            if self.children.jokermerge_all then 
                self.children.jokermerge_all:remove()
                self.children.jokermerge_all = nil
            end
        end
    end
    oldcardhighlight(self, is_higlighted)
end

G.FUNCS.jokercan_split_one = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.immutable.yorick_amount) > to_big(1) then
        e.config.colour = (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.C.SUITS[card.base.suit] or G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'jokersplit_one'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.jokersplit_one = function(e)
	Yorick.split(e.config.ref_table, 1)
end

G.FUNCS.jokercan_merge = function(e)
	local card = e.config.ref_table
	if Yorick.can_merge(card) then
        e.config.colour = (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.C.SUITS[card.base.suit] or G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'jokermerge'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.jokermerge = function(e)
	local card = e.config.ref_table
    local v = Yorick.can_merge(card)
    if v then
        Yorick.merge(card, v)
    end
end

G.FUNCS.jokercan_split_half = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.immutable.yorick_amount) > to_big(1) then
        e.config.colour = (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.C.SUITS[card.base.suit] or G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'jokersplit_half'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.jokersplit_half = function(e)
    local card = e.config.ref_table
    Yorick.split(card, math.floor(card.ability.immutable.yorick_amount/2))
end

G.FUNCS.jokercan_merge_all = function(e)
	local card = e.config.ref_table
    local count = 0
    for _, v in ipairs(card.area.cards) do
        if v ~= card and v.config.center_key == card.config.center_key then count = count + 1 end
    end
	if Yorick.can_merge(card) and count > 1 then
        e.config.colour = (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.C.SUITS[card.base.suit] or G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'jokermerge_all'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.jokermerge_all = function(e)
	local card = e.config.ref_table
    for _, v in ipairs(card.area.cards) do
        if card ~= v and Yorick.can_merge(v, card) then
            Yorick.merge(card, v)
        end
    end
end

local yorickConfigTab = function()
	yorc_nodes = {}
	left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	config = { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = { left_settings, right_settings } }
	yorc_nodes[#yorc_nodes+1] = config
	yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize("k_can_stack_playing_cards"),
		active_colour = HEX("40c76d"),
		ref_table = Yorick.config,
		ref_value = "can_stack_playing_cards",
		callback = function()
        end,
	})
    --[[
	yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize("k_joker_buttons_are_most_prominent_colour"),
		active_colour = HEX("40c76d"),
		ref_table = Yorick.config,
		ref_value = "joker_buttons_are_most_prominent_colour",
		callback = function()
        end,
	})
    ]]
	yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize("k_only_stack_negatives"),
		active_colour = HEX("40c76d"),
		ref_table = Yorick.config,
		ref_value = "only_stack_negatives",
		callback = function()
        end,
	})
    yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize('k_fix_slots'),
		active_colour = HEX('40c76d'),
		ref_table = Yorick.config,
		ref_value = 'fix_slots',
		callback = function()
            if not G.jokers or not G.hand then return end
            for _, v in ipairs({G.jokers, G.hand}) do
                for _, vv in ipairs(v.cards) do
                    vv.ability.extra_slots_used = vv.ability.extra_slots_used + ((Yorick.config.fix_slots and 1 or -1)*(vv.ability.immutable.yorick_amount-1))
                end
            end
        end,
	})
    yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize('k_fix_random'),
		active_colour = HEX('40c76d'),
		ref_table = Yorick.config,
		ref_value = 'fix_random',
		callback = function()
        end,
	})
    yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize('k_merge_scoring_effects'),
		active_colour = HEX('40c76d'),
		ref_table = Yorick.config,
		ref_value = 'merge_scoring_effects',
		callback = function()
        end,
	})
    yorc_nodes[#yorc_nodes+1] = create_toggle({
		label = localize('k_dont_save_values'),
		active_colour = HEX('40c76d'),
		ref_table = Yorick.config,
		ref_value = 'dont_save_values',
		callback = function()
        end,
	})
	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = yorc_nodes,
	}
end

Yorick.config_tab = yorickConfigTab