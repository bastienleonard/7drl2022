local tagged_union = require('tagged_union')

return tagged_union({
        Character = { 'char' },
        Nothing = {},
        Wall = {},
        Items = {},
        Stairs = {},
        Hero = {},
        Rat = {},
        Knight = {},
        Demon = {}
})
