local array_utils = require('array_utils')
local BaseScreen = require('base_screen')
local ColumnView = require('ui.column_view')
local DamageType = require('damage_type')
local DeathScreen = require('death_screen')
local generate_level = require('game_screen.generate_level')
local melee_damage = require('melee_damage')
local MeleeDamageType = require('melee_damage_type')
local MovementDirection = require('game_screen.movement_direction')
local random = require('random')
local PlayerInput = require('player_input')
local RootView = require('game_screen.root_view')
local RowView = require('ui.row_view')
local ScrollView = require('ui.scroll_view')
local tagged_union = require('tagged_union')
local UnitKind = require('game_screen.units.unit_kind')
local utils = require('utils')
local Vec2 = require('vec2')

local parent = BaseScreen
local class = setmetatable({}, { __index = parent })
class.__index = class

-- Contains function that cannot be declared as local because that would cause
-- circular references.
local locals = {}

local UnitAction = tagged_union({
        Rest = {},
        Move = { 'direction' }
})

local function add_message(self, message)
    table.insert(self.messages, message)
    ScrollView.scroll_to_bottom(RootView.ID_MESSAGES_SCROLL_VIEW)
end

local function is_walkable(self, position)
    local tile = self.map:get_or_nil(position)

    if not tile then
        return false
    end

    if self:unit_at(position) then
        return false
    end

    return tile.kind ~= tile.Kind.WALL
end

local function move_unit_by(self, unit, direction)
    unit.position = unit.position + direction
    assert(self.map:contains(unit.position))
end

local function area(map, position, radius)
    local result = {}

    for x = position.x - radius, position.x + radius do
        for y = position.y - radius, position.y + radius do
            table.insert(result, { x, y })
        end
    end

    return result
end

local function update_fov(self)
    local function is_visible_to_hero(map, x, y, hero, first_call)
        if first_call == nil then
            first_call = true
        end

        if not first_call and map:get(x, y):blocks_sight() then
            return false
        end

        if hero.position.x == x and hero.position.y == y then
            return true
        end

        local neighbor_x = x
        local neighbor_y = y

        if neighbor_x < hero.position.x then
            neighbor_x = neighbor_x + 1
        elseif neighbor_x > hero.position.x then
            neighbor_x = neighbor_x - 1
        end

        if neighbor_y < hero.position.y then
            neighbor_y = neighbor_y + 1
        elseif neighbor_y > hero.position.y then
            neighbor_y = neighbor_y - 1
        end

        return is_visible_to_hero(map, neighbor_x, neighbor_y, hero, false)
    end

    local map = self.map

    for x = 0, map.width - 1 do
        for y = 0, map.height - 1 do
            local tile = map:get(x, y)

            if tile.fov_status == tile.FovStatus.IN_SIGHT then
                tile.fov_status = tile.FovStatus.EXPLORED
            end
        end
    end

    for _, coords in ipairs(area(map, self.hero.position, 7)) do
        local x = coords[1]
        local y = coords[2]
        local tile = map:get_or_nil(x, y)

        if tile and is_visible_to_hero(map, x, y, self.hero) then
            tile.fov_status = tile.FovStatus.IN_SIGHT
            local unit = self:unit_at(x, y)

            if unit and unit.kind ~= UnitKind.HERO then
                if not unit.seen then
                    local enemy_name

                    if unit.kind == UnitKind.RAT then
                        enemy_name = 'rat'
                    elseif unit.kind == UnitKind.KNIGHT then
                        enemy_name = 'knight'
                    elseif unit.kind == UnitKind.DEMON then
                        enemy_name = 'demon'
                    else
                        error(
                            string.format(
                                'Unhandled unit kind %s',
                                unit.kind
                            )
                        )
                    end

                    add_message(self, string.format('A %s appears', enemy_name))
                end

                unit.seen = true
            end
        end
    end
end

local function go_to_next_level(self)
    self.level_count = self.level_count + 1
    self.map, self.units, self.hero = generate_level(
        self.level_count,
        self.hero
    )
    update_fov(self)
end

local function give_xp(self, hero, victim)
    assert(hero:is_hero())
    hero.xp = hero.xp + victim.xp_bounty

    while hero.xp >= hero.next_level_xp do
        hero.xp = hero.xp - hero.next_level_xp
        hero.level = hero.level + 1
        hero.next_level_xp = hero.class.next_level_xp(hero.level)

        if random.coin_flip() and not hero:has_max_strength() then
            hero.base_attrs:inc_strength()
            add_message(self, 'Your strength increases')
        elseif not hero:has_max_dexterity() then
            hero.base_attrs:inc_dexterity()
            add_message(self, 'Your dexterity increases')
        end

        hero:heal(utils.round(hero:max_hp() / 2))
    end
end

local function unit_damage(unit)
    assert(unit)
    local weapon = unit:equipped_weapon()
    local result = melee_damage.roll_for_melee_damage_type(
        weapon.melee_damage_type,
        unit:strength()
    ) + weapon.modifier

    if weapon.damage_type == DamageType.SMALL_PIERCING then
        result = utils.round(result / 2)
    elseif weapon.damage_type == DamageType.CUTTING
        or weapon.damage_type == DamageType.LARGE_PIERCING then
        result = result + utils.round(result / 2)
    elseif weapon.damage_type == DamageType.IMPALING then
        result = result * 2
    end

    return math.max(0, result)
end

local function attack_roll(attacker)
    assert(attacker)
    local effective_skill = attacker:dexterity()
    local roll = random.roll_thrice()

    if roll == 3 or roll == 4 then
        print('Critical hit')
        return true
    end

    if roll == 5 and effective_skill >= 15 then
        print('Critical success')
        return true
    end

    if roll == 6 and effective_skill >= 16 then
        print('Critical success')
        return true
    end

    if roll == 17 then
        if effective_skill <= 15 then
            print('Critical failure')
        end

        return false
    end

    if roll == 18 then
        print('Critical failure')
        return false
    end

    if roll >= effective_skill + 10 then
        print('Critical failure')
        return false
    end

    return roll <= effective_skill
end

local function attack(self, attacker, victim)
    if not attack_roll(attacker) then
        local message

        if attacker:is_hero() then
            message = 'You fail your attack'
        else
            message = 'Enemy fails his attack'
        end

        add_message(self, message)
        return
    end

    local damage = unit_damage(attacker)
    local message

    if attacker:is_hero() then
        message = string.format('You deal %s damage', damage)
    else
        message = string.format('Enemy deals %s damage', damage)
    end

    add_message(self, message)
    victim.hp = victim.hp - damage

    if victim.hp <= 0 then
        if victim:is_hero() then
            globals.screens:replace_top(DeathScreen.new())
        else
            array_utils.remove(self.units, victim)
            give_xp(self, attacker, victim)
        end
    end
end

local function pickup_item(self, item)
    if item == 'potion' then
        self.hero:heal(5)
        add_message(self, 'You find a healing potion')
    else
        if item ~= self.hero:equipped_weapon() then
            add_message(self, string.format('You find a %s', item.name))
        end

        self.hero:equip(item)
    end
end

local function on_hero_move(self)
    local tile = self.map:get(self.hero.position)

    for _, item in ipairs(tile.items) do
        pickup_item(self, item)
    end

    tile.items = {}

    if tile.kind == tile.Kind.STAIRS then
        go_to_next_level(self)
        return false
    else
        update_fov(self)
        return true
    end
end

local function handle_unit_action(self, unit, action)
    local do_enemy_turns = false

    if action:is(UnitAction.Rest) then
        do_enemy_turns = true
    elseif action:is(UnitAction.Move) then
        local direction = action.direction

        if is_walkable(self, unit.position + direction) then
            move_unit_by(self, unit, direction)

            if unit:is_hero() then
                if on_hero_move(self) then
                    do_enemy_turns = true
                end
            else
                do_enemy_turns = true
            end
        else
            local destination = unit.position + direction
            local destination_unit = self:unit_at(destination)

            if destination_unit then
                local may_attack =
                    (unit:is_hero() and not destination_unit:is_hero())
                    or (not unit:is_hero() and destination_unit:is_hero())
                if may_attack then
                    attack(self, unit, destination_unit)
                    do_enemy_turns = true
                end
            end
        end
    else
        error(string.format('Unhandled unit action %s', action))
    end

    if do_enemy_turns and unit:is_hero() then
        locals.play_enemy_turns(self)
    end
end

local function direction_toward(unit, target)
    local directions = array_utils.map_not_nil(
        MovementDirection.all,
        function(direction)
            local distance_before_move =
                utils.distance(unit.position, target.position)
            local distance_after_move =
                utils.distance(
                    unit.position + direction:as_vec(),
                    target.position
                )

            if distance_after_move >= distance_before_move then
                return nil
            else
                return { direction, distance_after_move }
            end
        end
    )
    table.sort(
        directions,
        function(a, b)
            return a[2] < b[2]
        end
    )
    local shortest_distance = -1
    local remove_from = -1

    for i, item in ipairs(directions) do
        local direction = item[1]
        local distance_after_move = item[2]

        if shortest_distance == -1 then
            shortest_distance = distance_after_move
        else
            if distance_after_move > shortest_distance then
                remove_from = i
                break
            end
        end
    end

    if remove_from ~= -1 then
        for i = #directions, remove_from, -1 do
            table.remove(directions, i)
        end
    end

    return random.choice(directions)[1]
end

local function play_enemy_turn(self, unit)
    local can_see_hero = utils.distance(unit.position, self.hero.position) < 5

    if can_see_hero then
        local direction = direction_toward(unit, self.hero):as_vec()
        handle_unit_action(self, unit, UnitAction.Move.new(direction))
    end
end

function locals.play_enemy_turns(self)
    for _, unit in ipairs(self.units) do
        if not unit:is_hero() then
            play_enemy_turn(self, unit)
        end
    end
end

local function handle_input(self, input)
    local action = nil

    if input == PlayerInput.REST then
        action = UnitAction.Rest.new()
    elseif input == PlayerInput.MOVE_LEFT then
        action = UnitAction.Move.new(Vec2.LEFT)
    elseif input == PlayerInput.MOVE_RIGHT then
        action = UnitAction.Move.new(Vec2.RIGHT)
    elseif input == PlayerInput.MOVE_UP then
        action = UnitAction.Move.new(Vec2.UP)
    elseif input == PlayerInput.MOVE_DOWN then
        action = UnitAction.Move.new(Vec2.DOWN)
    elseif input == PlayerInput.MOVE_LEFT_AND_UP then
        action = UnitAction.Move.new(Vec2.LEFT_AND_UP)
    elseif input == PlayerInput.MOVE_LEFT_AND_DOWN then
        action = UnitAction.Move.new(Vec2.LEFT_AND_DOWN)
    elseif input == PlayerInput.MOVE_RIGHT_AND_UP then
        action = UnitAction.Move.new(Vec2.RIGHT_AND_UP)
    elseif input == PlayerInput.MOVE_RIGHT_AND_DOWN then
        action = UnitAction.Move.new(Vec2.RIGHT_AND_DOWN)
    elseif input == PlayerInput.SCROLL_DOWN then
        ScrollView.scroll_down(RootView.ID_MESSAGES_SCROLL_VIEW)
    elseif input == PlayerInput.SCROLL_UP then
        ScrollView.scroll_up(RootView.ID_MESSAGES_SCROLL_VIEW)
    end

    if action then
        handle_unit_action(self, self.hero, action)
    end
end

local function init(self)
    self.messages = {}
    add_message(
        self,
        'Welcome! Your goal is to go as deep as possible into the dungeon'
        .. ', for an unspecified reason.'
    )
    self.level_count = 0
    go_to_next_level(self)
end

function class.new()
    local self = {}
    parent._init(self)
    self = setmetatable(self, class)
    init(self)
    return self
end

function class:__tostring()
    return 'GameScreen'
end

function class:draw()
    local root_view = RootView.new({})
    root_view:measure({
            width = globals.terminal.width,
            height = globals.terminal.height
    })
    root_view:draw(0, 0)
end

function class:on_key_pressed(key, scancode, is_repeat)
    local input = PlayerInput.from_scancode(scancode)

    if input then
        handle_input(self, input)
    end
end

function class:unit_at(x, y, units)
    if not units then
        units = self.units
    end

    local position = x

    if y then
        position = Vec2.new(x, y)
    end

    for _, unit in ipairs(self.units) do
        if unit.position == position then
            return unit
        end
    end

    return nil
end

return class
