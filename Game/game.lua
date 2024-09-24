game = game or {}
game.time = 0

require("Game.Code.clock")
require("Game.Code.sky")
require("Game.Code.terrain")
require("Game.Code.simulation")

hooks.Add("OnGameLoad", function ()
    game.clock.years = 2025
    game.clock.months = 2
    game.clock.days = 2
    game.clock.hours = 1
end)

hooks.Add("OnGameDraw", function()
    hooks.Fire("OnDrawSky")
    hooks.Fire("OnDrawTerrain")
end)

hooks.Add("OnGameUpdate", function()

end)

