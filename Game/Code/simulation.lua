sim = {}
sim.cautionImage = love.graphics.newImage("Game/Assets/caution.png")
local SCREEN_COLOR = Color(0.8,0.85,0.8)
engine.rendering.registerShader("water")

sim.decter = {}
sim.decter.display = true
sim.decter.canvas = love.graphics.newCanvas(200, 150)
sim.decter.font = love.graphics.newFont("Game/Assets/Fonts/PixelVerdana.ttf")
sim.decter.status = "Inicializando..."
sim.decter.timer = 0
sim.decter.logs = {}
sim.decter.image = love.graphics.newImage("Game/Assets/decter.png")

sim.server = {}
sim.server.notices = {}
sim.server.display = true
sim.server.canvas = love.graphics.newCanvas(600,300)
sim.server.image = love.graphics.newImage("Game/Assets/server.png")

sim.water = {}
sim.water.condition = {
    ["bacteria"] = 0,
    ["rads"] = 0,
    ["ph"] = 7,
    ["oxygen"] = 100,
    ["oil"] = 0,
    ["temperature"] = 25,
}
sim.water.nominal = table.deepCopy(sim.water.condition)
-- Active events
sim.water.events = {} 

-- ---------------------------- Event Definitions --------------------------- --

-- name = display name
-- desc = display description
-- weight = chance of occcurence
-- duration = min and max duration of this event in seconds

local HOURS = 60
local DAYS = 24 * HOURS

-- Possible events
sim.events = {
    ["contaminant"] = {
        ["name"] = "Contaminantes",
        ["desc"] = "Contaminantes foram postos na água e agora ela está cheia de bactérias.",
        ["weight"] = 70,
        ["duration"] = {2*HOURS, 3*HOURS},
        ["bacteria"] = 90,
    },
    ["debris"] = {
        ["name"] = "Destroços",
        ["desc"] = "Detritos de equipamentos hospitalares foram jogados ao rio e agora estão afetando a condição da água.",
        ["weight"] = 1,
        ["duration"] = {3*DAYS, 6*DAYS},
        ["rads"] = 200,
        ["ph"] = 7.8,
    },
    ["acid_rain"] = {
        ["name"] = "Chuva Ácida",
        ["desc"] = "Chuva ácida causada pela poluição industrial está alterando o pH do rio.",
        ["weight"] = 1,
        ["duration"] = {2*HOURS, 5*HOURS},
        ["ph"] = 5.2,
    },
    ["algae_bloom"] = {
        ["name"] = "Proliferação de Algas",
        ["desc"] = "Um crescimento excessivo de algas está consumindo o oxigênio da água.",
        ["weight"] = 20,
        ["duration"] = {2*DAYS, 30*DAYS},
        ["bacteria"] = 60,
    },
    ["oil_spill"] = {
        ["name"] = "Derramamento de Óleo",
        ["desc"] = "Um derramamento de óleo industrial afetou a qualidade da água.",
        ["weight"] = 5,
        ["duration"] = {2*HOURS, 5*HOURS},
        ["oil"] = 100,
    },
    ["drought"] = {
        ["name"] = "Seca",
        ["desc"] = "Um período de seca na região está reduzindo o volume do rio e aumentando a concentração de contaminantes.",
        ["weight"] = 1,
        ["duration"] = {2*DAYS, 10*DAYS},
        ["water_level"] = -50,
        ["concentration"] = 80,
    },
    ["thermal_pollution"] = {
        ["name"] = "Poluição Térmica",
        ["desc"] = "Água quente de uma planta industrial está alterando a temperatura do rio, afetando a fauna local.",
        ["weight"] = 5,
        ["duration"] = {2*DAYS, 5*DAYS},
        ["temperature"] = 35,
        ["oxygen"] = 50,
    },
}

-- -------------------------------------------------------------------------- --
--                              Drawing Apparatus                             --
-- -------------------------------------------------------------------------- --

hooks.Add("OnDrawApparratus", function ()
    love.graphics.setColor(colormix(Color(0.75,0.75,0.75), sky.lastColor, 0.55))
    love.graphics.draw(sim.decter.image, 200, 650, 0, 0.125, 0.125)
    love.graphics.draw(sim.server.image, 1142, 462, 0, 0.25, 0.25)
end)

-- -------------------------------------------------------------------------- --
--                               Water Condition                              --
-- -------------------------------------------------------------------------- --

local function TrySpawningEvents()
    -- 1% Chance of spawning an event.
    if not prob(1) then return end

    -- Gather a list of possible event ids and their weight.
    local list = {}
    for id, event in pairs(sim.events) do
        list[id] = event.weight or 0
    end

    -- Remove active events from possibility list.
    for id, event in pairs(sim.water.events) do
        list[id] = nil 
    end

    -- Apply.
    local chosen = pick(list)
    if not chosen then return end

    local event = sim.events[chosen]
    if not event then return end

    event.timer = math.random(event["duration"][1], event["duration"][2]) -- The timer variable on the event.

    engine.Log("Causing event " .. chosen)
    sim.water.events[chosen] = event
end

local function HandleEvents(passed)
    local progress = math.clamp(DeltaTime() * passed,0.05, 1)
    local recovery = progress * 0.01
    for id, event in pairs(sim.water.events) do
        -- If the event is still in effect...
        if event.timer > 0 then
            -- Apply event effects
            
            if event.bacteria and (sim.water.condition["bacteria"] < event.bacteria) then
                sim.water.condition["bacteria"] = math.lerp(sim.water.condition["bacteria"], event.bacteria, progress)
            end
            if event.rads and (sim.water.condition["rads"] < event.rads) then
                sim.water.condition["rads"] = math.lerp(sim.water.condition["rads"], event.rads, progress)
            end
            if event.ph then
                sim.water.condition["ph"] = math.lerp(sim.water.condition["ph"], event.ph, progress)
            end
            if event.oxygen and (sim.water.condition["oxygen"] > event.oxygen) then
                sim.water.condition["oxygen"] = math.lerp(sim.water.condition["oxygen"], event.oxygen, progress)
            end
            if event.oil and (sim.water.condition["oil"] < event.oil) then
                sim.water.condition["oil"] = math.lerp(sim.water.condition["oil"], event.oil, progress)
            end
            if event.temperature and (sim.water.condition["temperature"] < event.temperature) then
                sim.water.condition["temperature"] = math.lerp(sim.water.condition["temperature"], event.temperature, progress)
            end

            event.timer = event.timer - passed
        else
            engine.Log("Ending event " .. id)
            sim.water.events[id] = nil -- Remove event.
        end
    end
    -- Normalization
    sim.water.condition["bacteria"] = math.lerp(sim.water.condition["bacteria"], sim.water.nominal["bacteria"], recovery)
    sim.water.condition["rads"] = math.lerp(sim.water.condition["rads"], sim.water.nominal["rads"], recovery)
    sim.water.condition["ph"] = math.lerp(sim.water.condition["ph"], sim.water.nominal["ph"], recovery)
    sim.water.condition["oxygen"] = math.lerp(sim.water.condition["oxygen"], sim.water.nominal["oxygen"], recovery)
    sim.water.condition["oil"] = math.lerp(sim.water.condition["oil"], sim.water.nominal["oil"], recovery)
    sim.water.condition["temperature"] = math.lerp(sim.water.condition["temperature"], sim.water.nominal["temperature"], recovery)
end

local COLOR_OIL = Color(0,0,0)
local COLOR_RAD = Color(0,1,0)

local function HandleWaterColor(passed)
    local color = Color(1,1,1)

    if sim.water.condition["oil"] > 0 then
        color = colormix(color, COLOR_OIL, utils.midpercent(sim.water.condition["oil"], 0, 50))
    end

    if sim.water.condition["rads"] > 0 then
        color = colormix(color, COLOR_RAD, utils.midpercent(sim.water.condition["rads"], 0, 100))
    end

    terrain.water.color = color
end

hooks.Add("ClockMinutesPassed", function (passed)
    HandleWaterColor(passed)
    HandleEvents(passed)
    TrySpawningEvents()
end)

hooks.Add("OnGameDraw", function ()
    local text = string.format(
    "Bacteria:%s\nRads:%s\nPH:%s\nOxygen:%s\nOil:%s\nTemperature:%s\n",
    sim.water.condition["bacteria"],
    sim.water.condition["rads"],
    sim.water.condition["ph"],
    sim.water.condition["oxygen"],
    sim.water.condition["oil"],
    sim.water.condition["temperature"])
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text, 8, (ScreenY()/2))
end)

-- -------------------------------------------------------------------------- --
--                                   Decter                                   --
-- -------------------------------------------------------------------------- --

hooks.Add("ClockMinutesPassed", function (passed)
    -- Update decter status.
    if sim.decter.timer > 0 then
        sim.decter.timer = sim.decter.timer - passed
        return
    end

    table.insert(sim.decter.logs, {
        ["bacteria"] = sim.water.condition["bacteria"],
        ["rads"] = sim.water.condition["rads"],
        ["ph"] = sim.water.condition["ph"],
        ["oxygen"] = sim.water.condition["oxygen"],
        ["oil"] = sim.water.condition["oil"],
        ["temperature"] = sim.water.condition["temperature"]
    })

    local text = string.format(
    "Nível de Bacteria: %.1f\nRadiação: %.1f rads\nPH: %.1f\nOxigênio: %.1f\nOléo: %.1f\nTemperatura: %.1f C",
    sim.water.condition["bacteria"],
    sim.water.condition["rads"],
    sim.water.condition["ph"],
    sim.water.condition["oxygen"],
    sim.water.condition["oil"],
    sim.water.condition["temperature"])

    sim.decter.status = text
    sim.decter.timer = 5
end)

hooks.Add("OnDrawUI", function ()
    if not sim.decter.status then return end
    if not sim.decter.display then return end
    local font = love.graphics.getFont() -- Save original font
    love.graphics.setCanvas(sim.decter.canvas) -- Set to decter's display canvas.
    -- --------------------------------- Canvas --------------------------------- --
    love.graphics.clear() -- Clear the decter display canvas 
    love.graphics.setColor(1,1,1,1) -- White color
    love.graphics.rectangle("fill", 0,0, ScreenX(), ScreenY()) -- Draw background
    love.graphics.setFont(sim.decter.font) -- Set display font
    love.graphics.setColor(0,0,0,1) -- Black color
    love.graphics.print(sim.decter.status, 0, 0, 0, 0.75, 0.75) -- Display text.
    -- ------------------------------------ - ----------------------------------- --
    love.graphics.setCanvas() -- Return to default rendering
    love.graphics.setFont(font) -- Restore original font
    love.graphics.setColor(0,0,0,1) -- Set color to black
    love.graphics.rectangle("fill", 110, 128, 204, 154) -- Draw a black frame
    love.graphics.setColor(SCREEN_COLOR) -- Screen Color
    love.graphics.setShader(engine.rendering.getShader("screen")) -- Get screen shader
    love.graphics.draw(sim.decter.canvas, 112, 130, 0) -- Draw the decter's UI canvas.
    love.graphics.setShader() -- Clear shader.
end)


-- -------------------------------------------------------------------------- --
--                                   Server                                   --
-- -------------------------------------------------------------------------- --

hooks.Add("ClockHoursPassed", function(passed)
    -- Retrieve everything from decter and compile an average.
    local total_bacteria = 0
    local total_rads = 0
    local total_ph = 0
    local total_oxygen = 0
    local total_oil = 0
    local total_temperature = 0

    for _, event in ipairs(sim.decter.logs) do
        total_bacteria = total_bacteria + (event["bacteria"] or 0)
        total_rads = total_rads + (event["rads"] or 0)
        total_ph = total_ph + (event["ph"] or 0)
        total_oxygen = total_oxygen + (event["oxygen"] or 0)
        total_oil = total_oil + (event["oil"] or 0)
        total_temperature = total_temperature + (event["temperature"] or 0)
    end

    local average_bacteria = math.floor(total_bacteria / #sim.decter.logs)
    local average_rads = math.floor(total_rads / #sim.decter.logs)
    local average_ph = math.floor(total_ph / #sim.decter.logs)
    local average_oxygen = math.floor(total_oxygen / #sim.decter.logs)
    local average_oil = math.floor(total_oil / #sim.decter.logs)
    local average_temperature = math.floor(total_temperature / #sim.decter.logs)

    -- Produce warnings

    local icon = sim.cautionImage -- TODO: More icons
    local clock = game.clock.get()

    if (average_bacteria > 30) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Níveis de bacteria fora do esperado!",
            ["icon"] = icon,
            ["color"] = Color(1,0,1)
        })
    end
    if (average_rads > 5) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Níveis de radiação excedem limite tolerável!",
            ["icon"] = icon,
            ["color"] = Color(0,1,0)
        })
    end
    if (average_ph > 7.5) or (average_ph < 6.5) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Níveis de pH fora do esperado!",
            ["icon"] = icon,
            ["color"] = Color(0,0,1)
        })
    end
    if (average_oxygen < 100) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Níveis de oxigênio fora do esperado!",
            ["icon"] = icon,
            ["color"] = Color(1,0,0)
        })
    end
    if (average_oil > 15) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Foi detectado petroléo na água!",
            ["icon"] = icon,
            ["color"] = Color(0,1,1)
        })
    end
    if (average_temperature > 30) or (average_temperature < 20) then
        table.insert(sim.server.notices, {
            ["clock"] = clock,
            ["message"] = "Temperaturas fora do padrão esperado!",
            ["icon"] = icon,
            ["color"] = Color(1,1,0)
        })
    end

    sim.decter.logs = {} -- Clear logs.

    -- Trim the first 30 notices if the total exceeds 50
    if #sim.server.notices > 50 then
        for i = 1, 30 do
            table.remove(sim.server.notices, 1) -- Remove the first (oldest) notice
        end
    end

end)

hooks.Add("OnDrawUI", function()
    if not sim.server.display then return end
    love.graphics.setCanvas(sim.server.canvas)
    local font = love.graphics.getFont()
    -- ------------------------------ Server Canvas ----------------------------- --
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", 0,0, ScreenX(), ScreenY())
    love.graphics.setFont(sim.decter.font)
    -- Draw events in list of most recent
    local height = 32

    local numNotices = #sim.server.notices
    for i=numNotices, 1, -1 do
        local y = (numNotices - i) * height  -- This places the latest notice at the bottom
        local notice = sim.server.notices[i]
        if notice and notice.message then
            -- Background
            love.graphics.setColor(colormix(Color(1,1,1), notice.color, 0.25))
            love.graphics.rectangle("fill", 0, y, 600, height)
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(notice.icon or sim.cautionImage, 0, y, 0, 0.05, 0.05)
            love.graphics.setColor(0,0,0,1)
            love.graphics.print(notice.message, 42, y, 0, 0.70)
        end
    end
    
    -- ------------------------------------ - ----------------------------------- --
    love.graphics.setCanvas()
    love.graphics.setFont(font)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", 873, 126, 604, 304)
    love.graphics.setColor(SCREEN_COLOR) -- Screen Color
    love.graphics.setShader(engine.rendering.getShader("screen")) -- Get screen shader
    love.graphics.draw(sim.server.canvas, 875, 128)
    love.graphics.setShader() -- Clear shader

end)

-- -------------------------------------------------------------------------- --
--                                  Controls                                  --
-- -------------------------------------------------------------------------- --

hooks.Add("OnKeyPressed", function(key, scancode)
    if (key == "z") then sim.decter.display = not sim.decter.display end
    if (key == "x") then sim.server.display = not sim.server.display end
end)
