sim = {}
sim.decter = {}
sim.server = {}
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

-- Event definitions

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