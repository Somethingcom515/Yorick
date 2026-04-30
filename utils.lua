function Yorick.TableMatches(table, func)
    for _, v in ipairs(table) do
        if func(v) then return v end
    end
end

function Yorick.playingcardissame(card1, card2)
    if card1.config.center == card2.config.center and
    (card1.edition and card1.edition.key or 'base') == (card2.edition and card2.edition.key or 'base') and
    card1.base.nominal == card2.base.nominal and
    card1.config.card == card2.config.card then
        return true
    end
    return false
end

function Yorick.can_merge(self, card, bypass, ignore_area)
    if Yorick.is_blacklisted(self) or Yorick.is_blacklisted(card) or ((self.area ~= G.jokers and self.area ~= G.hand) and not ignore_area) or (self.area == G.hand and not Yorick.config.can_stack_playing_cards) then return end
    if not card then
        local area = CardArea.is(ignore_area, CardArea) and ignore_area or self.area
        if Yorick.config.only_stack_negatives then
            if not self.edition or not self.edition.negative then
                return
            else
                if not self.playing_card then
                    local v = Yorick.TableMatches(area.cards, function(v)
                        return v.config.center_key == self.config.center_key and v.edition and v.edition.negative and (v ~= self or bypass)
                    end)
                    return v
                elseif Yorick.config.can_stack_playing_cards then
                    local v = Yorick.TableMatches(area.cards, function(v)
                        return Yorick.playingcardissame(v, self) and v.edition and v.edition.negative and (v ~= self or bypass)
                    end)
                    return v
                end
            end
        else
            if not self.playing_card then
                local v = Yorick.TableMatches(area.cards, function(v)
                    if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                        return v.config.center_key == self.config.center_key and (v ~= self or bypass)
                    end
                end)
                return v
            elseif Yorick.config.can_stack_playing_cards then
                local v = Yorick.TableMatches(area.cards, function(v)
                    return Yorick.playingcardissame(v, self) and (v ~= self or bypass)
                end)
                return v
            end
        end
    else
        if ((card.area ~= G.jokers and card.area ~= G.hand) and not ignore_area) then return end
        if Yorick.config.only_stack_negatives then
            if not self.edition or not self.edition.negative then
                return
            else 
                if not (card.playing_card and self.playing_card) then
                    return card.config.center_key == self.config.center_key and card.edition and card.edition.negative and (v ~= self or bypass)
                elseif Yorick.config.can_stack_playing_cards then
                    return Yorick.playingcardissame(card, self) and card.edition and card.edition.negative and (v ~= self or bypass)
                end
            end
        else
            if not (card.playing_card and self.playing_card) then
                if (not card.edition and not self.edition) or (card.edition and self.edition and card.edition.key == self.edition.key) then
                    return card.config.center_key == self.config.center_key and (card ~= self or bypass)
                end
            elseif Yorick.config.can_stack_playing_cards then
                return Yorick.playingcardissame(card, self) and (card ~= self or bypass)
            end
        end
    end
end

local return_values = {
    mult = {"mult", "h_mult", "mult_mod"},
    chips = {"chips", "h_chips", "chip_mod"},
    xmult = {"x_mult", "x_mult_mod", "xmult", "xmult_mod", "Xmult", "Xmult_mod"},
    xchips = {"x_chips", "x_chip_mod", "xchips", "xchip_mod", "Xchips", "Xchip_mod"},
    emult = {"e_mult", "e_mult_mod", "emult", "emult_mod", "Emult", "Emult_mod"},
    echips = {"e_chips", "e_chip_mod", "echips", "echip_mod", "Echips", "Echip_mod"},
    eemult = {"ee_mult", "ee_mult_mod", "eemult", "eemult_mod", "EEmult", "EEmult_mod"},
    eechips = {"ee_chips", "ee_chip_mod", "eechips", "eechip_mod", "EEchips", "EEchip_mod"},
    eeemult = {"eee_mult", "eee_mult_mod", "eeemult", "eeemult_mod", "EEEmult", "EEEmult_mod"},
    eeechips = {"eee_chips", "eee_chip_mod", "eeechips", "eeechip_mod", "EEEchips", "EEEchip_mod"},
    hypermult = {"hyper_mult", "hyper_mult_mod", "hypermult", "hypermult_mod", "Hypermult", "Hypermult_mod"},
    hyperchips = {"hyper_chips", "hyper_chip_mod", "hyperchips", "hyperchip_mod", "Hyperchips", "Hyperchip_mod"},
}

local function find_matching_tables(effect, return_values)
    local matching_tables, values = {}, {}
    if type(effect) == 'table' then
        for key, value in pairs(effect) do
            for table_name, sub_table in pairs(return_values) do
                for _, sub_value in pairs(sub_table) do
                    if key == sub_value then
                        values[table_name] = value
                        matching_tables[#matching_tables+1] = table_name
                    end
                end
            end
        end
    end
    return matching_tables, values
end

function table.contains(table, element)
    if table and type(table) == "table" then
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
        return false
    end
end

local function get_priority(matching_tables)
    if table.contains(matching_tables, "hypermult") then
        return 100
    elseif table.contains(matching_tables, "hyperchips") then
        return 99
    elseif table.contains(matching_tables, "eeemult") then
        return 98
    elseif table.contains(matching_tables, "eeechips") then
        return 97
    elseif table.contains(matching_tables, "eemult") then
        return 96
    elseif table.contains(matching_tables, "eechips") then
        return 95
    elseif table.contains(matching_tables, "emult") then
        return 94
    elseif table.contains(matching_tables, "echips") then
        return 93
    elseif table.contains(matching_tables, "xmult") then
        return 92
    elseif table.contains(matching_tables, "xchips") then
        return 91
    elseif table.contains(matching_tables, "mult") then
        return 90
    elseif table.contains(matching_tables, "chips") then
        return 89
    end
end

local order = {"dollars", "chips", "mult", "xchips", "xmult", "echips", "emult", "eechips", "eemult", "eeechips", "eeemult", "hyperchips", "hypermult"}
function Yorick:calculate(context)
    if context.post_trigger and context.other_ret.jokers then
        local matching_tables, values = find_matching_tables(context.other_ret.jokers, return_values)
        local priority = get_priority(matching_tables)
        context.other_card.ability.immutable.yorick_priority = priority or context.other_card.ability.immutable.yorick_priority
        for _, v in ipairs(order) do
            for k, vv in pairs(values) do
                if k == v then
                    context.other_card.ability.immutable.yorick_mostimportantvalue = vv
                    break
                end
            end
        end
    end
end

local oldcalcedition = Card.calculate_edition
function Card:calculate_edition(context)
    local g = oldcalcedition(self, context)
    if g then
        local matching_tables, values = find_matching_tables(g, return_values)
        if (self.ability.immutable.yorick_priority or 0) < (get_priority(matching_tables) or 0) then
            self.ability.immutable.yorick_priority = get_priority(matching_tables)
            for _, v in ipairs(order) do
                for k, vv in pairs(values) do
                    if k == v then
                        self.ability.immutable.yorick_mostimportantvalue = vv
                        break
                    end
                end
            end
        end
    end
    return g
end

G.FUNCS.can_sort_jokers = function(e)
    local count, passed
    for _, v in ipairs(G.jokers.cards) do
        if v.ability.immutable and v.ability.immutable.yorick_priority then
            count = (count or 0) + 1
            if count >= 2 then
                passed = true
                break
            end
        end
    end
    if passed then
        e.config.colour = G.C.RED
        e.config.button = 'sort_jokers'
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
	end
end

G.FUNCS.sort_jokers = function()
    Yorick.sort_optimal(G.jokers)
end

function Yorick.sort_optimal(area)
    table.sort(area.cards, function(a, b)
        return (a.ability.immutable.yorick_priority or 0) < (b.ability.immutable.yorick_priority or 0) or
               (a.ability.immutable.yorick_priority or 0) == (b.ability.immutable.yorick_priority or 0) and
               (a.ability.immutable.yorick_mostimportantvalue or 0) < (b.ability.immutable.yorick_mostimportantvalue or 0)
    end)
end

--[[
function Yorick.get_joker_prominent_colour(key)
    local center = G.P_CENTERS[key]
    if center.set ~= "Joker" then return G.C.SECONDARY_SET[center.set] end
    local atlas = center.original_mod and G.ASSET_ATLAS[center.atlas] or G.ASSET_ATLAS["Joker"]
    local results = {}
    local image = atlas.image_data
    local pos = {x = (center.pos.x * (atlas.px * G.SETTINGS.GRAPHICS.texture_scaling)) + 1, y = (center.pos.y * (atlas.py * G.SETTINGS.GRAPHICS.texture_scaling)) + 1}
    local width, height = atlas.px * G.SETTINGS.GRAPHICS.texture_scaling, atlas.py * G.SETTINGS.GRAPHICS.texture_scaling
    for i=pos.y, pos.y + height - 1 do
        for j=pos.x, pos.x + width - 1 do
            local r, g, b, _ = image:getPixel(j, i)
            local hex = string.upper(string.format("%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)))
            if hex ~= "000000" and hex ~= "FFFFFF" then
                results[hex] = (results[hex] or 0) + 1
            end
        end
    end
    local most_common = nil
    local most_common_count = 0
    for k, v in pairs(results) do
        if v > most_common_count then
            most_common = k
            most_common_count = v
        end
    end
    return most_common and HEX(most_common) or G.C.SECONDARY_SET["Joker"]
end
]]

function Yorick.merge(card, card2)
    card.ability.immutable.yorick_stored_properties = card.ability.immutable.yorick_stored_properties or {}
    local other_yorick_stored_properties = card2.ability.immutable.yorick_stored_properties
    card2.ability.immutable.yorick_stored_properties = nil
    local yorick_stored_properties = {
        enhancement = card2.ability.set == 'Enhanced' and card2.config.center_key or nil,
        seal = card2.seal,
        edition = card2.edition,
        stickers = {},
        ability = copy_table(card2.ability)
    }
    for _, v in ipairs(SMODS.Sticker.obj_buffer) do
        if card2.ability[v] then
            yorick_stored_properties.stickers[#yorick_stored_properties.stickers+1] = v
        end
    end
    card.ability.immutable.yorick_stored_properties[#card.ability.immutable.yorick_stored_properties+1] = yorick_stored_properties
    if other_yorick_stored_properties and other_yorick_stored_properties[1] then
        for _, v in ipairs(other_yorick_stored_properties) do
            card.ability.immutable.yorick_stored_properties[#card.ability.immutable.yorick_stored_properties+1] = copy_table(v)
        end
    end
    Yorick.set_amount(card, card.ability.immutable.yorick_amount + card2.ability.immutable.yorick_amount)
    card2.ability.bypass_aleph = true
    card2.ability.dontremovefromdeck = true
    card2.ability.yorick_merging = true
    card2.ability.yorick_dont_emplace = true
    card2:start_dissolve()
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        func = function()
            card:create_yorick_ui()
            return true
        end
    }))
end

function Yorick.apply_properties(card, properties)
    if not card or not properties then return end
    card.seal = nil
    if properties.enhancement then card:set_ability(properties.enhancement) end
    if properties.ability then card.ability = properties.ability end
    card:set_seal(properties.seal, true, true)
    if properties.edition then
        card:set_edition(properties.edition.key, true, true)
        card.edition = properties.edition
    else
        card:set_edition(nil, true, true)
    end
    if properties.stickers and properties.stickers[1] then
        for _, v in ipairs(properties.stickers) do
            card:add_sticker(v, true)
        end
    end
end

function Yorick.split(card, amount, destroy)
    if not card or not amount or amount < 1 then return end
    if card.playing_card then G.playing_card = (G.playing_card or 0) + 1 end
    local new_card
    if destroy then
        new_card = {ability = {}}
    else
        new_card = copy_card(card, nil, nil, card.playing_card and G.playing_card or nil)
    end
    if card.ability.immutable.yorick_stored_properties then
        if amount >= 2 then
            new_card.ability.immutable.yorick_stored_properties = {}
            for i=card.ability.immutable.yorick_amount-amount, #card.ability.immutable.yorick_stored_properties do
                new_card.ability.immutable.yorick_stored_properties[#new_card.ability.immutable.yorick_stored_properties+1] = copy_table(card.ability.immutable.yorick_stored_properties[i+1])
                card.ability.immutable.yorick_stored_properties[i] = nil
            end
        else
            new_card.ability.immutable.yorick_stored_properties = nil
            local yorick_stored_properties = card.ability.immutable.yorick_stored_properties[#card.ability.immutable.yorick_stored_properties]
            card.ability.immutable.yorick_stored_properties[#card.ability.immutable.yorick_stored_properties] = nil
            if not destroy then
                Yorick.apply_properties(new_card, yorick_stored_properties)
            end
        end
    end
    if destroy then
        Yorick.set_amount(card, card.ability.immutable.yorick_amount - amount)
        return
    end
    Yorick.set_amount(new_card, amount)
    Yorick.set_amount(card, card.ability.immutable.yorick_amount - amount)
    new_card:add_to_deck()
    new_card.ability.split = true
    if card.playing_card then
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        G.playing_cards[#G.playing_cards+1] = new_card
    end
    card.area:emplace(new_card)
    new_card:create_yorick_ui()
end

function Yorick.set_amount(card, amount)
    if not card then return end
    amount = amount or 1
    local add
    if to_big(amount) < to_big(1e100) then
        amount = to_number(amount)
    end
    add = amount - card.ability.immutable.yorick_amount
    card.ability.immutable.yorick_amount = amount
    if to_big(card.ability.immutable.yorick_amount) < to_big(1e100) then
        card.ability.immutable.yorick_amount = to_number(card.ability.immutable.yorick_amount)
    end
    if Yorick.config.fix_slots and not (card.edition and card.edition.negative) then
        card.ability.extra_slots_used = (card.ability.extra_slots_used or 0) + to_number(add)
    end
    card.ability.immutable.yorick_amount_text = number_format(amount)
    card:set_cost()
    card:create_yorick_ui()
end

function Yorick.perform_checks(table1, op, table2, mod)
    for _, v in ipairs(table1) do
        for _, vv in ipairs(table2) do
            if op == '==' and v == vv then return true end
            if op == '~=' and v ~= vv then return true end
            if op == '>' and v > vv then return true end
            if op == '>=' and v >= vv then return true end
            if op == '<' and v < vv then return true end
            if op == '<=' and v <= vv then return true end
            if op == 'mod' and v % vv == mod then return true end
            if type(op) == 'function' and op(v, vv) then return true end
        end
    end
    return false
end

local function return_check(entry, type)
    if type == 'chips' then
        return Yorick.perform_checks({entry}, '==', {'chips', 'h_chips', 'chip_mod'})
    elseif type == 'mult' then
        return Yorick.perform_checks({entry}, '==', {'mult', 'h_mult', 'mult_mod'})
    elseif type == 'xchips' then
        return Yorick.perform_checks({entry}, '==', {'x_chips', 'xchips', 'Xchip_mod'})
    elseif type == 'xmult' then
        return Yorick.perform_checks({entry}, '==', {'x_mult', 'Xmult', 'xmult', 'x_mult_mod', 'Xmult_mod'})
    elseif type == 'dollars' then
        return Yorick.perform_checks({entry}, '==', {'p_dollars', 'dollars', 'h_dollars'})
    elseif type == 'echips' then
        return Yorick.perform_checks({entry}, '==', {'e_chips', 'echips', 'Echip_mod'})
    elseif type == 'emult' then
        return Yorick.perform_checks({entry}, '==', {'e_mult', 'emult', 'Emult_mod'})
    elseif type == 'eechips' then
        return Yorick.perform_checks({entry}, '==', {'ee_chips', 'eechips', 'EEchip_mod'})
    elseif type == 'eemult' then
        return Yorick.perform_checks({entry}, '==', {'ee_mult', 'eemult', 'EEmult_mod'})
    elseif type == 'eeechips' then
        return Yorick.perform_checks({entry}, '==', {'eee_chips', 'eeechips', 'EEEchip_mod'})
    elseif type == 'eeemult' then
        return Yorick.perform_checks({entry}, '==', {'eee_mult', 'eeemult', 'EEEmult_mod'})
    elseif type == 'hyperchips' then
        return Yorick.perform_checks({entry}, '==', {'hyper_chips', 'hyperchips', 'hyperchip_mod'})
    elseif type == 'hypermult' then
        return Yorick.perform_checks({entry}, '==', {'hyper_mult', 'hypermult', 'hypermult_mod'})
    end
end

function Yorick.merge_returns(effects, retrigger)
    if not retrigger and Yorick.config.merge_scoring_effects then
        local effect = effects[1]
        local true_effects = {effect}
        for i=2, #effects do
            local true_passed
            local v = effects[i]
            for k, vv in pairs(v) do
                if effect[k] then
                    if Talisman and type(effect[k]) == 'number' and effect[k] >= 1e100 then effect[k] = to_big(effect[k]) end
                    if return_check(k, 'chips') or return_check(k, 'mult') or return_check(k, 'dollars') then
                        effect[k] = effect[k] + vv
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find('+'..vv) then
                                effect.message = localize({type = 'variable', key = 'a_'..(k:find('chip') and 'chips' or 'mult'), vars = {effect[k]}})
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif return_check(k, 'xchips') or return_check(k, 'xmult') then
                        effect[k] = effect[k] * vv
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find('X'..vv) then
                                effect.message = localize({type = 'variable', key = 'a_x'..(k:find('chip') and 'chips' or 'mult'), vars = {effect[k]}})
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif return_check(k, 'echips') or return_check(k, 'emult') then
                        effect[k] = to_big(effect[k]) ^ to_big(vv)
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find('^'..vv) then
                                effect.message = '^'..effect[k]..(k:find('chip') and '' or (' '..localize('k_mult')))
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif return_check(k, 'eechips') or return_check(k, 'eemult') then
                        effect[k] = to_big(effect[k]):arrow(2, to_big(vv))
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find('^^'..vv) then
                                effect.message = '^^'..effect[k]..(k:find('chip') and '' or (' '..localize('k_mult')))
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif return_check(k, 'eeechips') or return_check(k, 'eeemult') then
                        effect[k] = to_big(effect[k]):arrow(3, to_big(vv))
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find('^^'..vv) then
                                effect.message = '^^^'..effect[k]..(k:find('chip') and '' or (' '..localize('k_mult')))
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif return_check(k, 'hyperchips') or return_check(k, 'hypermult') then
                        effect[k][2] = to_big(effect[k][2]):arrow(vv[1], to_big(vv[2]))
                        v[k] = nil
                        if v.message and k:find('_mod') then
                            if v.message:find((effect[k][1] > 5 and ('{'..effect[k][1]..'}') or string.rep('^', effect[k][1]))..vv) then
                                effect.message = (effect[k][1] > 5 and ('{'..effect[k][1]..'}') or string.rep('^', effect[k][1]))..effect[k][2]..(k:find('chip') and '' or (' '..localize('k_mult')))
                                v.message = nil
                            else
                                effect.message = v.message
                                v.message = nil
                            end
                        end
                    elseif k == 'level_up' then
                        effect[k] = (type(effect[k]) == 'number' and effect[k] or 1) + (type(vv) == 'number' and vv or 1)
                        v[k] = nil
                        if v.message then
                            effect.message = v.message
                            v.message = nil
                        end
                    end
                end
                if v[k] and not true_passed then
                    if k ~= 'card' and k ~= 'message_card' and k ~= 'juice_card' and k ~= 'focus' and k ~= 'other_card' then
                        true_passed = true
                    end
                end
            end
            if true_passed then true_effects[#true_effects+1] = v end
        end
        return SMODS.merge_effects(true_effects)
    else
        return SMODS.merge_effects(effects)
    end
end

function Yorick.is_blacklisted(card)
    if not card then return false end
    return Yorick.blacklist[card.config.center_key]
end

function Yorick.get_total_count(area)
    local total = 0
    for i, v in ipairs(area.cards) do
        total = total + (v and v.ability and v.ability.immutable and v.ability.immutable.yorick_amount or 1)
    end
    return total
end