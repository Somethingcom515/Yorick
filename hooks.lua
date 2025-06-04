--automatically stack consumables
local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    if (self.area ~= G.jokers and self.area ~= G.hand) or card.ability.split or Yorick.is_blacklisted(card) or not G.jokers then
        emplace_ref(self, card, ...)
        if card.children.yorick_ui then
            card.children.yorick_ui:remove()
            card.children.yorick_ui = nil 
        end
    else
        if not card.ability.immutable then card.ability.immutable = {} end
        if Yorick.config.only_stack_negatives then
            if not card.edition or card.edition.key ~= "e_negative" then
                emplace_ref(self, card, ...)
            else
                local v, i = Yorick.TableMatches(self.cards, function(v, i)
                    return v.config.center.key == card.config.center.key and v.edition and v.edition.key == "e_negative" and v ~= self
                end)
                if v then
                    Yorick.set_amount(v, (v.ability.immutable.yorick_amount or 1) + (card.ability.immutable.yorick_amount or 1))
                    card.states.visible = false
                    card.ability.bypass_aleph = true
                    card.ability.dontremovefromdeck = true
                    card:start_dissolve()
                else
                    emplace_ref(self, card, ...)
                end
            end
        else    
            local v, i = Yorick.TableMatches(self.cards, function(v, i)
                if (not v.edition and not card.edition) or (v.edition and card.edition and v.edition.key == card.edition.key) then
                    return v.config.center.key == card.config.center.key and v ~= self
                end
            end)
            if v then
                Yorick.set_amount(v, (v.ability.immutable.yorick_amount or 1) + (card.ability.immutable.yorick_amount or 1))
                card.states.visible = false
                card.ability.bypass_aleph = true
                card.ability.dontremovefromdeck = true
                card:start_dissolve()
            else
                emplace_ref(self, card, ...)
            end
        end
        G.jokers.config.card_count = G.jokers.config.card_count + (card.ability.immutable.yorick_amount or 1)
    end
end

local copy_cardref = copy_card
function copy_card(other, new_card, card_scale, playing_card, strip_edition, dont_reset_qty)
    local new_card2 = copy_cardref(other, new_card, card_scale, playing_card, strip_edition)
    if Yorick.can_merge(other, new_card2, nil, dont_reset_qty) and not Yorick.is_blacklisted(other) then
        if not dont_reset_qty then 
            new_card2.ability.split = nil
            if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
            new_card2.ability.immutable.yorick_amount = 1
            new_card2.ability.immutable.yorick_amount_text = ""
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    new_card2:create_yorick_ui()
                    other:create_yorick_ui()
                    return true
                end
            }))
            return new_card2
        else
            Yorick.set_amount(other, to_big((other.ability.immutable.yorick_amount or 1)) * 2) 
            if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
            new_card2.ability.immutable.yorick_amount = 0
            new_card2.ability.bypass_aleph = true
            new_card2.ability.dontremovefromdeck = true
            new_card2:start_dissolve()
            return new_card2
        end
    else    
        if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
        new_card2.ability.immutable.yorick_amount = 1
        new_card2.ability.immutable.yorick_amount_text = ""
        return new_card2
    end
end

local set_cost_ref = Card.set_cost
function Card:set_cost()
	set_cost_ref(self)
    if not self.ability.immutable then self.ability.immutable = {} end
	self.sell_cost = self.sell_cost * (self.ability.immutable.yorick_amount or 1)
    self.sell_cost_label = self.facing == 'back' and '?' or number_format(self.sell_cost)
end

if not SMODS.Mods.Talisman or not SMODS.Mods.Talisman.can_load then
    to_big = function(num) return num end
    to_number = function(num) return num end
end
