sky            = {}
sky.stars      = {}

sky.colors     = {}
sky.colors[0]  = rgb(0, 0, 0)      -- Dark night
sky.colors[1]  = rgb(0, 0, 15)      -- Deep night
sky.colors[2]  = rgb(0, 0, 25)      -- Pre-dawn
sky.colors[3]  = rgb(10, 10, 25)    -- Slight light
sky.colors[4]  = rgb(20, 20, 90)
sky.colors[5]  = rgb(50, 50, 120)
sky.colors[6]  = rgb(80, 80, 140)   -- Dawn
sky.colors[7]  = rgb(120, 160, 200) -- Morning
sky.colors[8]  = rgb(135, 206, 235) -- Clear sky
sky.colors[9]  = rgb(135, 206, 235)
sky.colors[10] = rgb(135, 206, 235) -- Midday
sky.colors[11] = rgb(135, 206, 235)
sky.colors[12] = rgb(135, 206, 235) -- Noon
sky.colors[13] = rgb(135, 206, 235)
sky.colors[14] = rgb(135, 206, 235) -- Early afternoon
sky.colors[15] = rgb(135, 206, 235)
sky.colors[16] = rgb(135, 206, 235)
sky.colors[17] = rgb(250, 150, 100) -- Late afternoon (warm tones)
sky.colors[18] = rgb(255, 130, 70)  -- Sunset
sky.colors[19] = rgb(200, 100, 50)  -- Dusk
sky.colors[20] = rgb(100, 25, 50)  -- Evening
sky.colors[21] = rgb(50, 0, 50)   -- Late night
sky.colors[22] = rgb(15, 0, 15)     -- Deep night   
sky.colors[23] = rgb(0, 0, 0)      -- Midnight

function loadTransparent(imagePath, transR, transG, transB)
	imageData = love.image.newImageData( imagePath )
	function mapFunction(x, y, r, g, b, a)
		if r == transR and g == transG and b == transB then a = 0 end
		return r,g,b,a
	end
	imageData:mapPixel( mapFunction )
	return love.graphics.newImage( imageData )
end


-- Landscape image
do
    imgdata = love.image.newImageData("Game/Assets/landscape.png")
    local function map(x,y,r,g,b,a)
        return r,r,r,1-r
    end
    imgdata:mapPixel(map)
    sky.landscape = love.graphics.newImage(imgdata)
end

sky.mask = love.image.newImageData("Game/Assets/skymask.png")

local HOUR = 3600

-- Star: {position, glow}

-- Spawn stars
do
    local origin = Vector(ScreenX() / 2, ScreenY())
    for x = -1000, 1000 do
        for y = -1000, 1000 do
            if (prob(1) and prob(15)) then
                local star = {}
                star.pos = Vector(origin.x + x, origin.y + y)
                star.glow = 1
                if (prob(1)) then
                    star.glow = Rand(3, 4)
                elseif prob(15) then
                    star.glow = Rand(2, 3)
                end
                table.insert(sky.stars, star)
            end
        end
    end
end

local function drawSky()
    -- Current time in the game
    local currentHour = game.clock.hours
    local nextHour = (currentHour + 1) % 24 -- Wrap around after 23:00

    -- Calculate progress on seconds
    local seconds = game.clock.minutes * 60 + game.clock.seconds
    
    -- The percentage progress we are between the two hours.
    local percent = utils.midpercent(seconds, 0, 3600)

    -- Get the two sky colors to blend between
    local colorA = Color(sky.colors[currentHour])
    local colorB = Color(sky.colors[nextHour])

    -- Blend the colors
    local blended = Color(
        utils.lerp(colorA.r, colorB.r, percent),
        utils.lerp(colorA.g, colorB.g, percent),
        utils.lerp(colorA.b, colorB.b, percent)
    )

    love.graphics.setBackgroundColor(blended.r,blended.g,blended.b)
end


local function drawStars(strength)
    if (strength <= 0) then return end
    local strength = math.clamp(strength or 1, 0, 1)
    local origin = Vector(ScreenX() / 2, ScreenY())
    love.graphics.setBlendMode('alpha', 'alphamultiply')

    -- Total milliseconds in a 24-hour period (24 * 60 * 60 * 1000)
    local milliseconds_in_day = 24 * 60 * 60 * 1000

    -- Convert the current time (hours, minutes, seconds) into total milliseconds of the day
    local current_time_in_ms = (game.clock.hours * 60 * 60 * 1000) + -- Hours to milliseconds
        (game.clock.minutes * 60 * 1000) +                           -- Minutes to milliseconds
        (game.clock.seconds * 1000)                                  -- Seconds to milliseconds

    -- Calculate the rotation angle based on current time in milliseconds
    local angle = (current_time_in_ms % milliseconds_in_day) * (2 * math.pi / milliseconds_in_day)

    for _, star in pairs(sky.stars) do
        assert(star.pos ~= nil, "Star without position on sky renderer.")
        local pos = star.pos
        local glow = star.glow or 1

        -- Rotate star around the origin
        local dx = pos.x - origin.x
        local dy = pos.y - origin.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local currentAngle = math.atan2(dy, dx)
        local rotatedAngle = currentAngle + angle

        -- New rotated position
        local rotatedX = origin.x + distance * math.cos(rotatedAngle)
        local rotatedY = origin.y + distance * math.sin(rotatedAngle)

        local valid = true
        if (rotatedX < 0 or rotatedX > ScreenX()) then valid = false end
        if (rotatedY < 0 or rotatedY > ScreenY()) then valid = false end
        
        if valid then

            local r,g,b,a = sky.mask:getPixel(rotatedX, rotatedY)

            if (r > 0.5) then
                -- Render glow if any
                if glow > 1 then
                    love.graphics.setColor(1, 1, 1, 0.1)
                    local g = glow
                    while g >= 0 do
                        love.graphics.circle("fill", rotatedX, rotatedY, g * strength)
                        g = g - 1
                    end
                end

                -- Draw the star at the new rotated position
                love.graphics.setColor(1, 1, 1, (glow / 10) * strength)
                love.graphics.points({ rotatedX, rotatedY })
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Stars: [%s]", #sky.stars), 8, ScreenY() - 128)
end



local function getStarStrength()
    local time = (game.clock.hours * 3600) + (game.clock.minutes * 60) + game.clock.seconds

    if (time > 19*HOUR and time <= 21*HOUR) then
        return utils.midpercent(time, 19*HOUR, 21*HOUR)
    end

    if (time > 21*HOUR and time <= 24*HOUR) then
        return 1
    end

    if (time > 0 and time < 4*HOUR) then
        return 1 - utils.midpercent(time, 0, 4*HOUR)
    end


    return 0
end

hooks.Add("OnGameDraw", function()
    love.graphics.draw(sky.landscape)
    drawSky()
    local s = getStarStrength()
    drawStars(s)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(string.format("Sky Strength: [%s]", s), 8, ScreenY() - 164)
end)
