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
    love.graphics.push()
    love.graphics.scale(ScreenX() / 1600, ScreenY() / 900)
    hooks.Fire("OnDrawSky")
    hooks.Fire("OnDrawTerrain")
    hooks.Fire("OnDrawApparratus")
    hooks.Fire("OnDrawUI")
    love.graphics.pop()
end)

hooks.Add("OnGameUpdate", function()

end)

