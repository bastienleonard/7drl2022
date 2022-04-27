local array_utils = require('array_utils')
local ColumnView = require('ui.column_view')
local make_class = require('make_class')
local TextView = require('ui.text_view')

local class = make_class(
    'HeroStatsView',
    {
        _parent = ColumnView
    }
)

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
    class.parent._init(self, options)
end

function class.new(options)
    local self = {}
    init(self, options)
    return setmetatable(self, class)
end

return class
