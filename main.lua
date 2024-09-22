-- The main engine reference 
engine = {}
engine.quitReady = false
engine.loading = false -- If the engine is currently doing loading process.
engine.version = 0
love.filesystem.setIdentity("RexEngine")

local intro = false

-- -------------------------------------------------------------------------- --
--                                   Loading                                  --
-- -------------------------------------------------------------------------- --

function love.load()
	-- ---------------------------------- Utils --------------------------------- --
	require("Engine/utils")
	
	-- --------------------------------- Modules -------------------------------- --
	require("Engine/logging")
	engine.Log("[Core] " .. os.date("Logging started for: %d/%m/%y"))
	require("Engine/hooks")
	engine.Log("[Core] Loaded hook module.")
	require("Engine/cvars")
	engine.Log("[Core] Loaded cvar module.")
	require("Engine/time")
	engine.Log("[Core] Loaded time module.")
	require("Engine/files")
	engine.Log("[Core] Loaded file module.")
	require("Engine/routines")
	engine.Log("[Core] Loaded routines module.")
	require("Engine/interface")
	engine.Log("[Core] Loaded interface module.")
	require("Engine/rendering")
	engine.Log("[Core] Loaded rendering module.")
	require("Engine/misc")
	engine.Log("[Core] Loaded misc engine features.")

	if (intro) then
		require("Engine/Intro/intro")
		engine.Log("[Core] Loaded intro module.")
	end

	engine.Log("[Core] Finished loading engine modules.")
	
	math.randomseed( CurTime() )
	
---@diagnostic disable-next-line: param-type-mismatch
	engine.Log("[Core] Applied seed to random generator: " .. os.time(os.date("!*t")))

	-- ---------------------------------- Setup --------------------------------- --
	engine.Log("[Core] Final engine setup...")
	-- ------------------------------ Game Loading ------------------------------ --
	-- This was made async for loading screens.
	engine.loading = true
	engine.routines.New("EngineLoad", function ()
		hooks.Fire("OnEngineSetup")
		engine.Log("[Core] Engine loaded!")
		hooks.Fire("PostEngineLoad")
		engine.quitReady = true
	
		if (not intro) then
			engine.Log("[Core] Loading game...")
			hooks.Fire("PreGameLoad")
			require("Game.game")
			hooks.Fire("OnGameLoad")
			hooks.Fire("PostGameLoad")
		end

		engine.loading = false
	end)
	-- -------------------------------------------------------------------------- --
end

-- -------------------------------------------------------------------------- --
--                             Method Abstraction                             --
-- -------------------------------------------------------------------------- --

function love.keypressed(key, scancode, isrepeat)
	if engine.loading then return end
	hooks.Fire("OnKeyPressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
	if engine.loading then return end
	hooks.Fire("OnKeyReleased", key, scancode, isrepeat)	
end

function love.textinput(text)
	if engine.loading then return end
	hooks.Fire("OnTextInput", text)
end

function love.mousepressed(x, y, button)
	if engine.loading then return end
	hooks.Fire("OnMousePress", x, y, button)
end

function love.mousereleased(x, y, button)
	if engine.loading then return end
	hooks.Fire("OnMouseRelease", x, y, button)
end

function love.update(deltaTime)
	if engine.loading == true then hooks.Fire("EngineLoadingScreenUpdate") end

	hooks.Fire("PreEngineUpdate", deltaTime)
	hooks.Fire("OnEngineUpdate", deltaTime)
	hooks.Fire("PostEngineUpdate", deltaTime)
	
	hooks.Fire("PreGameUpdate", deltaTime)
	hooks.Fire("OnGameUpdate", deltaTime)
	hooks.Fire("PostGameUpdate", deltaTime)
end

function love.wheelmoved(x, y)
	if engine.loading then return end
	hooks.Fire("OnMouseWheel", x, y)
    if y > 0 then
        -- mouse wheel moved up
		hooks.Fire("OnMouseWheelUp", y)
    elseif y < 0 then
        -- mouse wheel moved down
		hooks.Fire("OnMouseWheelDown", y)
    end
end

function love.resize(w,h)
	hooks.Fire("OnScreenResize", w,h)
end

-- -------------------------------------------------------------------------- --
--                                   Drawing                                  --
-- -------------------------------------------------------------------------- --

function love.draw()
	if engine.loading == true then hooks.Fire("EngineLoadingScreenDraw") return end


	hooks.Fire("PreDraw")
	
	hooks.Fire("OnCameraAttach")
	hooks.Fire("PreGameDraw")
	hooks.Fire("OnGameDraw")
	hooks.Fire("PostGameDraw")
	hooks.Fire("OnCameraDetach")
	
	hooks.Fire("PreInterfaceDraw")
	hooks.Fire("OnInterfaceDraw")
	hooks.Fire("PostInterfaceDraw")

	hooks.Fire("PreEngineDraw")
	hooks.Fire("OnEngineDraw")
	hooks.Fire("PostEngineDraw")
	
	hooks.Fire("PostDraw")

	love.graphics.setBlendMode('alpha')
	love.graphics.setLineStyle('rough')
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("Decter - Spartan Team - Rex Engine", 0, ScreenY()-love.graphics.getFont():getHeight())
end

-- -------------------------------------------------------------------------- --
--                                  Quitting                                  --
-- -------------------------------------------------------------------------- --

function love.quit()
	if (not engine.quitReady) then
		engine.Log("[Core] An attempt was made to shutdown, but the engine isn't ready to shutdown yet. Ignoring...")
		return true
	else
		engine.Log("[Core] Preparing for shutdown...")
		hooks.Fire("OnEngineShutdown")
		engine.Log("[Core] Shutting down...")
		return false
	end
end

