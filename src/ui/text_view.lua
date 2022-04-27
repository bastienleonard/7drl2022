local utf8 = require('utf8')

local BaseView = require('ui.base_view')
local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'TextView',
    {
        _parent = BaseView
    }
)

local function init(self, options)
    self.text = utils.require_key(options, 'text')
    self.text_length = utf8.len(self.text)
    self.text_color = options.text_color
end

local function split_text_into_rows(text, text_length, max_width, max_height)
    if text_length <= max_width then
        return { text }
    end

    local function split(s)
        local words = {}
        local current_word = ''

        for i = 1, utf8.len(s) do
            local char = s:sub(utf8.offset(s, i), utf8.offset(s, i))

            if char == ' ' then
                if #current_word > 0 then
                    table.insert(words, current_word)
                end

                current_word = ''
            else
                current_word = current_word .. char
            end
        end

        if utf8.len(current_word) > 0 then
            table.insert(words, current_word)
        end

        return words
    end

    local rows = {}
    local current_row = ''

    for _, word in ipairs(split(text)) do
        local insert_space_char = utf8.len(current_row) > 0
        local required_space = utf8.len(word)

        if insert_space_char then
            required_space = 1 + utf8.len(word)
        else
            required_space = utf8.len(word)
        end

        if utf8.len(current_row) + required_space <= max_width then
            if insert_space_char then
                current_row = current_row .. ' ' .. word
            else
                current_row = word
            end
        else
            table.insert(rows, current_row)
            current_row = word

            if max_height and #rows >= max_height then
                break
            end
        end
    end

    if utf8.len(current_row) > 0 then
        table.insert(rows, current_row)
    end

    return rows
end

function class.new(options)
    local self = {}
    class.parent._init(self, options)
    init(self, options)
    return setmetatable(self, class)
end

function class:measure(options)
    options = options or {}
    local width
    local height

    if options.width then
        width = options.width
    else
        width = self.text_length

        if options.max_width then
            width = math.min(width, options.max_width)
        end
    end

    if width < self.text_length then
        local max_height = options.max_height or options.height
        height = #split_text_into_rows(
            self.text,
            self.text_length,
            width,
            max_height
        )
    end

    if options.height then
        height = options.height
    else
        height = height or 1

        if options.max_height then
            height = math.min(height, options.max_height)
        end
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    class.parent.draw(self, x, y)

    if self.measured_width == 0
        or self.measured_height == 0
        or self.text_length == 0 then
        return
    end

    local rows = split_text_into_rows(
        self.text,
        self.text_length,
        self.measured_width,
        self.measured_height
    )

    for i, row in ipairs(rows) do
        self:draw_text(
            row,
            x,
            y + i - 1,
            {
                max_width = self.measured_width,
                text_color = self.text_color
            }
        )
    end
end

return class
