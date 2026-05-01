--automatically stack non-consumables
local oldcardareaemplace = CardArea.emplace
function CardArea:emplace(card, ...)
    if card.ability.yorick_dont_emplace then return end
    oldcardareaemplace(self, card, ...)
    if (self ~= G.jokers and self ~= G.hand and self ~= G.play) or Yorick.is_blacklisted(card) or not G.jokers then
        if card.children.yorick_ui then
            card.children.yorick_ui:remove()
            card.children.yorick_ui = nil
        end
    elseif card.ability.split then
        if to_big(card.ability.immutable.yorick_amount) >= to_big(2) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    card:create_yorick_ui()
                    return true
                end
            }))
        end
    elseif self ~= G.play then
        local v = Yorick.can_merge(card, nil, nil, self)
        if v then
            card.states.visible = false
            self:remove_card(card)
            Yorick.merge(v, card)
        end
        if to_big(card.ability.immutable.yorick_amount) >= to_big(2) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    card:create_yorick_ui()
                    return true
                end
            }))
        end
    end
end

local oldcopycard = copy_card
function copy_card(other, ...)
    local dont_reset_qty = G.yorick_dont_reset_qty
    local newer_card = oldcopycard(other, ...)
    if (other.area == G.jokers or (other.area == G.hand and Yorick.config.can_stack_playing_cards)) and Yorick.can_merge(other, newer_card, nil, dont_reset_qty) and not Yorick.is_blacklisted(other) then
        if not dont_reset_qty then
            newer_card.ability.split = nil
            newer_card.ability.immutable.yorick_amount = 1
            newer_card.ability.immutable.yorick_amount_text = ""
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    newer_card:create_yorick_ui()
                    other:create_yorick_ui()
                    return true
                end
            }))
            return newer_card
        else
            Yorick.set_amount(newer_card, other.ability.immutable.yorick_amount)
            newer_card.states.visible = false
            Yorick.merge(other, newer_card)
            return newer_card
        end
    else
        newer_card.ability.immutable.yorick_amount = 1
        newer_card.ability.immutable.yorick_amount_text = ""
        return newer_card
    end
end

--[[
local oldinitgameobject = Game.init_game_object
function Game:init_game_object()
    local ret = oldinitgameobject(self)
    ret.yorick_colours = {}
    for k, v in pairs(G.P_CENTERS) do
        if v.set == "Joker" then
            ret.yorick_colours[v.key] = Yorick.get_joker_prominent_colour(v.key)
        end
    end
    return ret
end
]]

local oldcardsetcost = Card.set_cost
function Card:set_cost()
	local g = oldcardsetcost(self)
	self.sell_cost = self.sell_cost * self.ability.immutable.yorick_amount
    self.sell_cost_label = (self.facing == 'back' and '?') or self.sell_cost
    return g
end

local oldgamestartrun = Game.start_run
function Game:start_run(args)
    local g = oldgamestartrun(self, args)
    self.yorick_sort_jokers = UIBox {
        definition = {
            n = G.UIT.ROOT,
            config = {
                align = "cm",
                minw = 1,
                minh = 0.3,
                padding = 0.15,
                r = 0.1,
                colour = G.C.CLEAR
            },
            nodes = {
                {
                    n = G.UIT.C,
                    config = {
                        align = "tm",
                        minw = 2,
                        padding = 0.1,
                        r = 0.1,
                        hover = true,
                        colour = G.C.RED,
                        shadow = true,
                        button = 'sort_jokers',
                        func = 'can_sort_jokers',
                    },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "bcm", padding = 0 },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = "Sort Jokers",
                                        scale = 0.35,
                                        colour = G.C.UI.TEXT_LIGHT
                                    }
                                }
                            }
                        },
                    }
                },
            }
        },
        config = {
            align = "cardarea_add_to_highlighted_ref",
            offset = { x = 3, y = -0.75 },
            major = G.jokers,
            bond = 'Weak'
        }
    }
    return g
end

local oldcardsetability = Card.set_ability
function Card:set_ability(center, initial, ...)
    local changed = not initial and self.config.center ~= center
    if changed and to_big(self.ability.immutable.yorick_amount) >= to_big(2) then
        Yorick.split(self, self.ability.immutable.yorick_amount-1)
    end
    local g = oldcardsetability(self, center, initial, ...)
    if not self.ability.immutable or not self.ability.immutable.yorick_amount then
        self.ability.immutable = self.ability.immutable or {}
        self.ability.immutable.yorick_amount = 1
    end
    if changed and self.area then
        local v = Yorick.can_merge(self)
        if v then
            Yorick.merge(v, self)
        end
    end
    return g
end

local oldsmodsscorecard = SMODS.score_card
function SMODS.score_card(card, context)
    G.yorick_from_smods_score_card = card
    local old_properties = {
        seal = card.seal,
        edition = card.edition,
        stickers = {},
        ability = card.ability
    }
    for _, v in ipairs(SMODS.Sticker.obj_buffer) do
        if card.ability[v] then
            old_properties.stickers[#old_properties.stickers+1] = v
        end
    end
    local applied = false
    card.yorick_stored_properties = card.ability.immutable.yorick_stored_properties
    for i=1, card.ability.immutable.yorick_amount do
        if card.yorick_stored_properties and card.yorick_stored_properties[i-1] then
            Yorick.apply_properties(card, card.yorick_stored_properties[i-1])
            applied = true
        end
        oldsmodsscorecard(card, context)
    end
    if applied then
        Yorick.apply_properties(card, old_properties)
    end
    G.yorick_from_smods_score_card = nil
end

local oldevalcard = eval_card
function eval_card(card, context)
    if context.extra_enhancement then return oldevalcard(card, context) end
    local eval, post, eval_table, post_table = nil, nil, {}, {}
    if G.yorick_from_smods_score_card == card then
        eval, post = oldevalcard(card, context)
    elseif to_big(card.ability.immutable.yorick_amount) < to_big(2) then
        if context.other_main then
            for _=1, context.other_main.ability.immutable.yorick_amount do
                eval, post = oldevalcard(card, context)
                for k, v in pairs(eval) do
                    eval_table[k] = eval_table[k] or {}
                    eval_table[k][#eval_table[k]+1] = v
                end
                post_table[#post_table+1] = post
            end
        else
            eval, post = oldevalcard(card, context)
        end
    else
        local old_properties = {
            seal = card.seal,
            edition = card.edition,
            stickers = {},
            ability = card.ability
        }
        for _, v in ipairs(SMODS.Sticker.obj_buffer) do
            if card.ability[v] then
                old_properties.stickers[#old_properties.stickers+1] = v
            end
        end
        local applied = false
        card.yorick_stored_properties = card.ability.immutable.yorick_stored_properties
        for i=1, card.ability.immutable.yorick_amount do
            if card.yorick_stored_properties and card.yorick_stored_properties[i-1] then
                Yorick.apply_properties(card, card.yorick_stored_properties[i-1])
                applied = true
            end
            if context.other_main then
                for _=1, context.other_main.ability.immutable.yorick_amount do
                    eval, post = oldevalcard(card, context)
                    for k, v in pairs(eval) do
                        eval_table[k] = eval_table[k] or {}
                        eval_table[k][#eval_table[k]+1] = v
                    end
                    post_table[#post_table+1] = post
                end
            else
                eval, post = oldevalcard(card, context)
                for k, v in pairs(eval) do
                    eval_table[k] = eval_table[k] or {}
                    eval_table[k][#eval_table[k]+1] = v
                end
                post_table[#post_table+1] = post
            end
        end
        if applied then
            Yorick.apply_properties(card, old_properties)
        end
    end
    if next(eval_table) then
        eval = {}
        for k, v in pairs(eval_table) do
            eval[k] = Yorick.merge_returns(v, context.retrigger_joker)
        end
    end
    if post_table[1] then
        post = {}
        for _, v in ipairs(post_table) do
            for _, vv in ipairs(v) do
                post[#post+1] = vv
            end
        end
    end
    return eval, post
end

local oldstartdissolve = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    if not self.ability.yorick_merging and not G.CONTROLLER.locks.selling_card and to_big(self.ability.immutable.yorick_amount) >= to_big(2) then
        Yorick.split(self, 1, true)
        self.getting_sliced = nil
        return
    end
    return oldstartdissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
end

local oldsmodsfindcard = SMODS.find_card
function SMODS.find_card(key, count_debuffed)
    if not G.jokers or not G.jokers.cards then return {} end
    local g = oldsmodsfindcard(key, count_debuffed)
    local jokers = SMODS.shallow_copy(g)
    for i=1, #jokers do
        local v = jokers[i]
        for _=1, v.ability.immutable.yorick_amount-1 do
            table.insert(g, i+1, v)
        end
    end
    return g
end

if Yorick.config.fix_random then
    local oldpseudorandomelement = pseudorandom_element
    function pseudorandom_element(_t, seed, args)
        if not G.deck then return oldpseudorandomelement(_t, seed, args) end
        local t = SMODS.shallow_copy(_t)
        for k, v in pairs(_t) do
            if Card.is(v, Card) then
                for i=1, v.ability.immutable.yorick_amount-1 do
                    if type(k) == 'number' then
                        table.insert(t, k+1, v)
                    elseif type(k) == 'string' then
                        t['yorick_'..k..'_extra_'..i] = v
                    elseif type(k) == 'table' then
                        t[SMODS.shallow_copy(k)] = v
                    elseif type(k) == 'function' then
                        t[function(...) return k(...) end] = v
                    end
                end
            end
        end
        return oldpseudorandomelement(t, seed, args)
    end
end