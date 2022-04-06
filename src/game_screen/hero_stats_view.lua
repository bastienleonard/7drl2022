local array_utils = require('array_utils')
local ColumnView = require('ui.column_view')
local TextView = require('ui.text_view')

local parent = ColumnView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function init(self, options)
    local hero = globals.screens:current().hero
    local rows = {
        string.format('Level %s', hero.level),
        string.format('%s/%s HP', hero.hp, hero:max_hp()),
        string.format('%s/%s XP', hero.xp, hero.next_level_xp),
        string.format('%s strength', hero:strength()),
        string.format('%s dexterity', hero:dexterity()),
        string.format('Weapon: %s', hero:equipped_weapon().name)
    }
    options.children = array_utils.map(
        rows,
        function(row)
            return TextView.new({
                    text = row
            })
        end
    )
    parent._init(self, options)
end

function class.new(options)
    local self = {}
    init(self, options)
    return setmetatable(self, class)
end

function class:__tostring()
    return 'HeroStatsView'
end

return class