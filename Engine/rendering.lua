engine = engine or {}
engine.rendering = engine.rendering or {}
engine.rendering.shaders = {}
engine.rendering.defaultShader = love.graphics.newShader(table.concat(file.read("Engine/Shaders/default.glsl"), "\n"))

local BASE_SPEED = 15
local MAX_ZOOM = 2
local MIN_ZOOM = 0.5

-- love.graphics.setLineStyle('rough')
-- love.graphics.setDefaultFilter("nearest", "nearest")

-- -------------------------------------------------------------------------- --
--                                   Shader                                   --
-- -------------------------------------------------------------------------- --

function engine.rendering.registerShader(name)
	-- We create the shader in the registry, but with default shader.
	-- We will loop and load everything in it's own dedicated loading segment.
	engine.rendering.shaders[name] = engine.rendering.defaultShader
end	

function engine.rendering.newShader(name)
	local path = "Game/Code/Shaders/" .. name .. ".glsl"
	local perlin = love.filesystem.read("Engine/Shaders/perlin2d.glsl")
	if not file.exists(path) then
		engine.Log("[Rendering] Shader failed to load: " .. path .. "\nReason: File not found.")
		engine.rendering.shaders[name] = engine.rendering.defaultShader
		return engine.rendering.defaultShader
	end

	local success, result = pcall(love.graphics.newShader, perlin .. table.concat(file.read(path), "\n"))
	if not success then
		engine.Log("[Rendering] Shader failed to load: " .. path .. "\nReason: Failed to compile shader code.\nError:\n" .. tostring(result))
		engine.rendering.shaders[name] = engine.rendering.defaultShader
		return engine.rendering.defaultShader
	end
	
	engine.rendering.shaders[name] = result
	hooks.Fire("OnShaderCreate")
	return engine.rendering.shaders[name]
end

function engine.rendering.sendShader(shader, variable, value)
	if value == nil then return end
	if shader:hasUniform(variable) then shader:send(variable, value) end
end

function engine.rendering.reloadShaders()
	engine.Log("[Rendering] Reloading shaders...")
	for name, shader in pairs(engine.rendering.shaders) do
		engine.routines.yields.LoadingYield("Loading Shaders... " .. name)
		engine.Log("[Rendering] Shader " .. name .. " has been reloaded.")
		engine.rendering.newShader(name)
	end
end

function engine.rendering.getShader(name) return (engine.rendering.shaders[name] or engine.rendering.newShader(name)) end

hooks.Add("OnEngineUpdate", function ()
	for _, shader in pairs(engine.rendering.shaders) do
		engine.rendering.sendShader(shader, "time", CurTime())
		engine.rendering.sendShader(shader, "screenX", ScreenX())
		engine.rendering.sendShader(shader, "screenY", ScreenY())
	end
end)

hooks.Add("PostGameLoad", function()
	engine.rendering.reloadShaders()
end)

hooks.Add("OnKeyPressed", function (keycode, scancode)
	if keycode == "f7" and not engine.loading then
		engine.routines.New("ReloadShaders", function()
			engine.loading = true
			engine.rendering.reloadShaders()
			engine.loading = false
		end)
	end
end)