local DamageType = require('damage_type')
local Demon = require('game_screen.units.demon')
local enum = require('enum')
local Hero = require('game_screen.units.hero')
local Knight = require('game_screen.units.knight')
local Map = require('game_screen.map')
local MeleeDamageType = require('melee_damage_type')
local random = require('random')
local Rat = require('game_screen.units.rat')
local table_utils = require('table_utils')
local Tile = require('game_screen.tile')
local utils = require('utils')
local Vec2 = require('vec2')
local weapons = require('weapons')

local RoomExpansionDirection = enum('LEFT', 'RIGHT', 'UP', 'DOWN')

local function unit_at(x, y, units)
    assert(x)
    assert(y)
    assert(units)
    local position = x

    if y then
        position = Vec2.new(x, y)
    end

    for _, unit in ipairs(units) do
        if unit.position == position then
            return unit
        end
    end

    return nil
end

local function put_wall(map, x, y)
    map:get(x, y).kind = Tile.Kind.WALL
end

local function put_walls_for_room(map, room)
    for x = room.x, room.x + room.width - 1 do
        put_wall(map, x, room.y)
        put_wall(map, x, room.y + room.height - 1)
    end

    for y = room.y, room.y + room.height - 1 do
        put_wall(map, room.x, y)
        put_wall(map, room.x + room.width - 1, y)
    end
end

local function connect_rooms_horizontally(a, b, map)
    if b.x < a.x then
        a, b = b, a
    end

    for x = a.x + a.width - 1, b.x do
        local y = a.y + math.floor(a.height / 2)
        put_wall(map, x, y - 1)
        map:get(x, y).kind = Tile.Kind.NOTHING
        put_wall(map, x, y + 1)
    end
end

local function connect_rooms_vertically(a, b, map)
    if b.y < a.y then
        a, b = b, a
    end

    for y = a.y + a.height - 1, b.y do
        local x = a.x + math.floor(a.width / 2)
        put_wall(map, x - 1, y)
        map:get(x, y).kind = Tile.Kind.NOTHING
        put_wall(map, x + 1, y)
    end
end

local function room_is_valid(room, other_room, map)
    for x = room.x, room.x + room.width - 1 do
        for y = room.y, room.y + room.height - 1 do
            local tile = map:get_or_nil(x, y)

            if not tile then
                return false
            end

            if tile.kind ~= tile.Kind.NOTHING then
                return false
            end
        end
    end

    return true
end

local function generate_rooms(map, rooms_count)
    local rooms = {}
    local previous_room = nil

    for _ = 1, rooms_count do
        local room = {
            width = love.math.random(6, 8),
            height = love.math.random(6, 8)
        }
        local direction = -1

        if previous_room then
            local i = 0

            while true do
                i = i + 1

                if i == 100 then
                    print(
                        string.format(
                            'Giving up generating room after %s attempts',
                            i
                        )
                    )
                    return rooms
                end

                direction = random.choice(RoomExpansionDirection.all)
                local hall_length = love.math.random(4, 6)

                if direction == RoomExpansionDirection.RIGHT then
                    room.x = previous_room.x
                        + previous_room.width
                        - 1
                        + hall_length
                    room.y = previous_room.y
                elseif direction == RoomExpansionDirection.LEFT then
                    room.x = previous_room.x - hall_length - room.width
                    room.y = previous_room.y
                elseif direction == RoomExpansionDirection.DOWN then
                    room.x = previous_room.x
                    room.y = previous_room.y
                        + previous_room.height
                        - 1
                        + hall_length
                elseif direction == RoomExpansionDirection.UP then
                    room.x = previous_room.x
                    room.y = previous_room.y - hall_length - room.height
                else
                    error('Unreachable')
                end

                local valid = room_is_valid(room, previous_room, map)

                if valid then
                    break
                end
            end
        else
            room.x = math.floor(map.width / 2)
            room.y = math.floor(map.height / 2)
        end

        put_walls_for_room(map, room)

        if previous_room then
            if direction == RoomExpansionDirection.LEFT
                or direction == RoomExpansionDirection.RIGHT then
                connect_rooms_horizontally(previous_room, room, map)
            elseif direction == RoomExpansionDirection.UP
                or direction == RoomExpansionDirection.DOWN then
                connect_rooms_vertically(previous_room, room, map)
            else
                error('Unreachable')
            end
        end

        table.insert(rooms, room)
        previous_room = room
    end

    return rooms
end

local function random_room_coords(room, padding)
    padding = padding or 0
    local x = love.math.random(
        room.x + 1 + padding,
        room.x + room.width - 2 - padding
    )
    local y = love.math.random(
        room.y + 1 + padding,
        room.y + room.height - 2 - padding
    )
    return x, y
end

local function place_stairs(map, rooms)
    local room = random.choice(rooms)
    local x, y = random_room_coords(room, 1)
    map:get(x, y).kind = Tile.Kind.STAIRS
end

local function place_hero(map, rooms, hero, units)
    while true do
        local room = random.choice(rooms)
        local x, y = random_room_coords(room)
        local tile = map:get(x, y)

        if tile.kind == tile.Kind.NOTHING then
            local new_hero_position = Vec2.new(x, y)

            if hero then
                hero.position = new_hero_position
            else
                hero = Hero.new(new_hero_position)
            end

            table.insert(units, hero)
            break
        end
    end

    return hero
end

local function place_enemies(map, rooms, units, enemies_count, level_count)
    for _ = 1, enemies_count do
        while true do
            local room = random.choice(rooms)
            local x, y = random_room_coords(room)

            if not unit_at(x, y, units) then
                local enemy
                local position = Vec2.new(x, y)

                if level_count <= 3 then
                    enemy = Rat.new(position)
                elseif level_count <= 7 then
                    enemy = Knight.new(position)
                else
                    enemy = Demon.new(position)
                end

                table.insert(units, enemy)
                break
            end
        end
    end
end

local function place_items(map, rooms, units, hero)
    local item
    local hero_weapon = hero:equipped_weapon()

    if random.coin_flip() and weapons.has_upgrade(hero_weapon) then
        item = weapons.next_weapon(hero_weapon)
    else
        item = 'potion'
    end

    local room = random.choice(rooms)

    while true do
        local x, y = random_room_coords(room)
        local tile = map:get(x, y)

        if tile.kind == tile.Kind.NOTHING and not unit_at(x, y, units) then
            table.insert(tile.items, item)
            break
        end
    end
end

return function(level_count, hero)
    local map = Map.new({
            width = 80,
            height = 30,
            make_tile = function()
                return Tile.new(Tile.Kind.NOTHING)
            end
    })
    local rooms_count = utils.clamp(
        level_count + love.math.random(1, 2),
        1,
        10
    )
    local rooms = generate_rooms(map, rooms_count)
    print(string.format('Generated %s rooms', #rooms))
    local units = {}
    place_stairs(map, rooms)
    hero = place_hero(map, rooms, hero, units)
    local enemies_count = math.max(2, rooms_count)
    place_enemies(map, rooms, units, enemies_count, level_count)
    place_items(map, rooms, units, hero)
    return map, units, hero
end
