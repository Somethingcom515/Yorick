function Yorick.TableMatches(table, func)
    for i, v in ipairs(table) do
        if func(v, i) then return v, i end
    end
end

function Yorick.can_merge(self, card, bypass, ignore_area)
    if Yorick.is_blacklisted(self) or Yorick.is_blacklisted(card) or (self.area ~= G.jokers and not ignore_area) then return end
    if not card then
        if Yorick.config.only_stack_negatives then
            if not self.edition or self.edition.key ~= "e_negative" then
                return 
            else    
                local v, i = Yorick.TableMatches(self.area.cards, function(v, i)
                    return v.config.center.key == self.config.center.key and v.edition and v.edition.key == "e_negative" and (v ~= self or bypass)
                end)
                return v
            end
        else
            local v, i = Yorick.TableMatches(self.area.cards, function(v, i)
                if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                    return v.config.center.key == self.config.center.key and (v ~= self or bypass)
                end
            end)
            return v
        end
    else
        if (card.area ~= G.jokers and not ignore_area) then return end
        if Yorick.config.only_stack_negatives then
            if not self.edition or self.edition.key ~= "e_negative" then
                return 
            else 
                return card.config.center.key == self.config.center.key and card.edition and card.edition.key == "e_negative" and (v ~= self or bypass)
            end
        else
            if (not card.edition and not self.edition) or (card.edition and self.edition and card.edition.key == self.edition.key) then
                return card.config.center.key == self.config.center.key and (card ~= self or bypass)
            end
        end
    end
end

function Yorick.set_amount(card, amount)
    if card then
        if to_big(amount) < to_big(1e100) then
            amount = to_number(amount)
        end
        if not card.ability.immutable then card.ability.immutable = {} end
        card.ability.immutable.yorick_amount = amount
        if to_big(card.ability.immutable.yorick_amount) < to_big(1e100) then
            card.ability.immutable.yorick_amount = to_number(card.ability.immutable.yorick_amount)
        end
        card.ability.immutable.yorick_amount_text = amount and number_format(amount) or "s"
        card:set_cost()
        card:create_yorick_ui()
    end
end

function Yorick.weighted_random(pool, pseudoseed)
    local poolsize = 0
    for k,v in pairs(pool) do
       poolsize = poolsize + v[1]
    end
    local selection = pseudorandom(pseudoseed, 1, poolsize)
    for k,v in pairs(pool) do
       selection = selection - v[1] 
       if (selection <= 0) then
          return v[2]
       end
    end
end

function Yorick.is_blacklisted(card)
    if not card then return false end
    return Yorick.blacklist[card.config.center.key] or Yorick.blacklist[card.config.center.set] or (card.base and card.base.suit)
end

function CardArea:get_total_count()
    local total = 0
    for i, v in ipairs(self.cards) do
        total = total + (v and v.ability and v.ability.immutable and v.ability.immutable.yorick_amount or 1)
    end
    return total
end