terrain = {}
terrain.water = {}
terrain.water.min = {0, ScreenY() - 164}
terrain.water.max = {ScreenX(),ScreenY()}

sky = sky or {}

engine.rendering.newShader("water")

hooks.Add("OnDrawTerrain", function ()
    local shader = engine.rendering.shaders["water"]
    if sky.lastColor and shader then
        local c = sky.lastColor
        local r,g,b = c.r,c.g,c.b
        r = (r * .5) + 0.1
        g = (g * .5) + 0.1
        b = (b * .5) + 0.1
        love.graphics.setColor(r,g,b,1)
        love.graphics.setShader(shader)
        love.graphics.rectangle("fill", terrain.water.min[1], terrain.water.min[2], terrain.water.max[1], terrain.water.max[2])
        love.graphics.setShader()
    end
end)