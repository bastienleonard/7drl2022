local BaseView = require('ui.base_view')
local make_class = require('make_class')
local Text = require('text')
local utils = require('utils')

local class = make_class(
    'TextView',
    {
        _parent = BaseView
    }
)

local function split_text_into_rows(text, text_length, max_width, max_height)
    if text_length <= max_width then
        return { text }
    end

    local function split(s)
        local words = {}
        local current_word = Text.EMPTY

        for i = 1, s:length() do
            local char = s:text_at(i)

            if char.lua_string == ' ' then
                if current_word:length() > 0 then
                    table.insert(words, current_word)
                end

                current_word = Text.EMPTY
            else
                current_word = current_word .. char
            end
        end

        if current_word:length() > 0 then
            table.insert(words, current_word)
        end

        return words
    end

    local rows = {}
    local current_row = Text.EMPTY

    for _, word in ipairs(split(text)) do
        local insert_space_char = current_row:length() > 0
        local required_space = word:length()

        if insert_space_char then
            required_space = 1 + word:length()
        else
            required_space = word:length()
        end

        if current_row:length() + required_space <= max_width then
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

    if current_row:length() > 0 then
        table.insert(rows, current_row)
    end

    return rows
end

function class._init(self, options)
    class.parent._init(self, options)
    self.text = utils.require_key(options, 'text')

    if type(self.text) == 'string' then
        self.text = Text.new(self.text)
    end

    assert(self.text:is(Text))
    self.text_color = options.text_color
end

function class:measure(options)
    options = options or {}
    local width
    local height

    if options.width then
        width = options.width
    else
        width = self.text:length()

        if options.max_width then
            width = math.min(width, options.max_width)
        end
    end

    if width < self.text:length() then
        local max_height = options.max_height or options.height
        height = #split_text_into_rows(
            self.text,
            self.text:length(),
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
        or self.text:length() == 0 then
        return
    end

    local rows = split_text_into_rows(
        self.text,
        self.text:length(),
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
