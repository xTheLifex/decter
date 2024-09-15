game = game or {}
game.time = 0

require("Game.Code.clock")
require("Game.Code.sky")

hooks.Add("OnGameLoad", function ()
    game.clock.years = 2025
    game.clock.months = 2
    game.clock.days = 2
    game.clock.hours = 1
end)

hooks.Add("OnGameDraw", function()

end)

hooks.Add("OnGameUpdate", function()

end)