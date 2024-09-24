terrain = {}
terrain.water = {}
terrain.water.min = {0, ScreenY() - 256}
terrain.water.max = {ScreenX(),ScreenY()}
terrain.land = love.graphics.newImage("Game/Assets/terrain.png")
terrain.water.color = Color(1,1,1)

sky = sky or {}

engine.rendering.registerShader("water")

hooks.Add("OnDrawTerrain", function ()
    local shader = engine.rendering.shaders["water"]
    if sky.lastColor and shader then
        local c = sky.lastColor
        local t = terrain.water.color
        local r,g,b = c.r,c.g,c.b
        r = math.clamp((r * .5) + (t.r - r) * 0.45, 0, 0.5)
        g = math.clamp((g * .5) + (t.g - g) * 0.45, 0, 0.5)
        b = math.clamp((b * .5) + (t.b - b) * 0.45, 0, 0.5)
        love.graphics.setColor(r,g,b,1)
        love.graphics.setShader(shader)
        love.graphics.rectangle("fill", terrain.water.min[1], terrain.water.min[2], terrain.water.max[1], terrain.water.max[2])
        love.graphics.setShader()
        r = math.clamp((c.r * 0.2) + (0.5), 0.2, 1)
        g = math.clamp((c.g * 0.2) + (0.5), 0.2, 1)
        b = math.clamp((c.b * 0.2) + (0.5), 0.2, 1)
        love.graphics.setColor(r,g,b)
        love.graphics.draw(terrain.land)        
    end

end)