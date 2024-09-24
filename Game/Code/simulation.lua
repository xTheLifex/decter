sim = {}
sim.decter = {}
sim.server = {}
sim.water = {}
sim.rand = love.math.newRandomGenerator()

sim.water.condition = {
    ["bacteria"] = 0,
    ["rads"] = 0,
    ["ph"] = 7,
    ["oxygen"] = 100,
    ["oil"] = 0,
    ["temperature"] = 25,
}

-- Event definitions

-- name = display name
-- desc = display description
-- weight = chance of occcurence
-- duration = duration of this event in seconds

local MINUTES = 60
local HOURS = 60 * MINUTES
local DAYS = 24 * HOURS

sim.events = {
    ["contaminant"] = {
        ["name"] = "Contaminantes",
        ["desc"] = "Contaminantes foram postos na água e agora ela está cheia de bactérias.",
        ["weight"] = 70,
        ["duration"] = 2*HOURS,
        ["bacteria"] = 90,
    },
    ["debris"] = {
        ["name"] = "Destroços",
        ["desc"] = "Detritos de equipamentos hospitalares foram jogados ao rio e agora estão afetando a condição da água.",
        ["weight"] = 1,
        ["duration"] = 3*DAYS,
        ["rads"] = 200,
        ["ph"] = 7.8,
    },
    ["acid_rain"] = {
        ["name"] = "Chuva Ácida",
        ["desc"] = "Chuva ácida causada pela poluição industrial está alterando o pH do rio.",
        ["weight"] = 1,
        ["ph"] = 5.2,
    },
    ["algae_bloom"] = {
        ["name"] = "Proliferação de Algas",
        ["desc"] = "Um crescimento excessivo de algas está consumindo o oxigênio da água.",
        ["weight"] = 20,
        ["bacteria"] = 60,
    },
    ["oil_spill"] = {
        ["name"] = "Derramamento de Óleo",
        ["desc"] = "Um derramamento de óleo industrial afetou a qualidade da água.",
        ["weight"] = 5,
        ["oil"] = 100,
    },
    ["drought"] = {
        ["name"] = "Seca",
        ["desc"] = "Um período de seca na região está reduzindo o volume do rio e aumentando a concentração de contaminantes.",
        ["weight"] = 1,
        ["water_level"] = -50,
        ["concentration"] = 80,
    },
    ["thermal_pollution"] = {
        ["name"] = "Poluição Térmica",
        ["desc"] = "Água quente de uma planta industrial está alterando a temperatura do rio, afetando a fauna local.",
        ["weight"] = 5,
        ["temperature"] = 35,
        ["oxygen"] = 50,
    },
}


-- Active events
sim.water.events = {} 

hooks.Add("OnGameUpdate", function (dt)
    local color = Color(1,1,1)

    for id, event in pairs(sim.water.events) do

    end 
end)