game.clock = {}
game.clock.milliseconds = 0
game.clock.seconds = 0
game.clock.minutes = 0
game.clock.hours = 0
game.clock.days = 1
game.clock.weeks = 0
game.clock.months = 1
game.clock.years = 0

-- Constants for time conversion
local MILLISECONDS_IN_SECOND = 1000
local SECONDS_IN_MINUTE = 60
local MINUTES_IN_HOUR = 60
local HOURS_IN_DAY = 24
local DAYS_IN_WEEK = 7

-- Month lengths in days (non-leap year)
local monthLengths = {
	31, -- January
	28, -- February (29 in leap years)
	31, -- March
	30, -- April
	31, -- May
	30, -- June
	31, -- July
	31, -- August
	30, -- September
	31, -- October
	30, -- November
	31, -- December
}

-- Function to determine if a year is a leap year
local function isLeapYear(year)
	if year % 4 == 0 then
		if year % 100 == 0 then
			return year % 400 == 0
		else
			return true
		end
	else
		return false
	end
end

-- Function to get the number of days in the current month
local function getCurrentMonthLength()
	local month = game.clock.months
	if month == 2 and isLeapYear(game.clock.years) then
		return 29                                 -- February in a leap year
	else
		return monthLengths[(month - 1) % 12 + 1] -- Make sure month is always valid
	end
end

local function normalizeClock()
	-- Normalize milliseconds to seconds
	if game.clock.milliseconds >= MILLISECONDS_IN_SECOND then
		game.clock.seconds = game.clock.seconds + math.floor(game.clock.milliseconds / MILLISECONDS_IN_SECOND)
		game.clock.milliseconds = game.clock.milliseconds % MILLISECONDS_IN_SECOND
	elseif game.clock.milliseconds < 0 then
		game.clock.seconds = game.clock.seconds + math.floor(game.clock.milliseconds / MILLISECONDS_IN_SECOND)
		game.clock.milliseconds = (game.clock.milliseconds % MILLISECONDS_IN_SECOND + MILLISECONDS_IN_SECOND) % MILLISECONDS_IN_SECOND
	end

	-- Normalize seconds to minutes
	if game.clock.seconds >= SECONDS_IN_MINUTE then
		game.clock.minutes = game.clock.minutes + math.floor(game.clock.seconds / SECONDS_IN_MINUTE)
		game.clock.seconds = game.clock.seconds % SECONDS_IN_MINUTE
	elseif game.clock.seconds < 0 then
		game.clock.minutes = game.clock.minutes + math.floor(game.clock.seconds / SECONDS_IN_MINUTE)
		game.clock.seconds = (game.clock.seconds % SECONDS_IN_MINUTE + SECONDS_IN_MINUTE) % SECONDS_IN_MINUTE
	end

	-- Normalize minutes to hours
	if game.clock.minutes >= MINUTES_IN_HOUR then
		game.clock.hours = game.clock.hours + math.floor(game.clock.minutes / MINUTES_IN_HOUR)
		game.clock.minutes = game.clock.minutes % MINUTES_IN_HOUR
	elseif game.clock.minutes < 0 then
		game.clock.hours = game.clock.hours + math.floor(game.clock.minutes / MINUTES_IN_HOUR)
		game.clock.minutes = (game.clock.minutes % MINUTES_IN_HOUR + MINUTES_IN_HOUR) % MINUTES_IN_HOUR
	end

	-- Normalize hours to days
	if game.clock.hours >= HOURS_IN_DAY then
		game.clock.days = game.clock.days + math.floor(game.clock.hours / HOURS_IN_DAY)
		game.clock.hours = game.clock.hours % HOURS_IN_DAY
	elseif game.clock.hours < 0 then
		game.clock.days = game.clock.days + math.floor(game.clock.hours / HOURS_IN_DAY)
		game.clock.hours = (game.clock.hours % HOURS_IN_DAY + HOURS_IN_DAY) % HOURS_IN_DAY
	end

	-- Normalize days to months based on current month's length
	local currentMonthLength = getCurrentMonthLength()
	while game.clock.days > currentMonthLength do
		game.clock.months = game.clock.months + 1
		game.clock.days = game.clock.days - currentMonthLength
		currentMonthLength = getCurrentMonthLength() -- Update for next month if overflow
	end

	while game.clock.days <= 0 do
		game.clock.months = game.clock.months - 1
		currentMonthLength = getCurrentMonthLength()
		game.clock.days = game.clock.days + currentMonthLength
	end

	-- Normalize months to years
	if game.clock.months > 12 then
		game.clock.years = game.clock.years + math.floor((game.clock.months - 1) / 12)
		game.clock.months = (game.clock.months - 1) % 12 + 1
	elseif game.clock.months <= 0 then
		game.clock.years = game.clock.years + math.floor((game.clock.months - 1) / 12)
		game.clock.months = (game.clock.months - 1) % 12 + 12
	end
end

local function updateClock(deltaTime)
	-- Convert deltaTime from seconds to milliseconds
	game.clock.milliseconds = game.clock.milliseconds + deltaTime * MILLISECONDS_IN_SECOND

	-- Normalize the clock values after adding deltaTime
	normalizeClock()


end

-- Add time to the clock
function game.clock.addTime(milliseconds, seconds, minutes, hours, days, months, years)
	game.clock.milliseconds = game.clock.milliseconds + (milliseconds or 0)
	game.clock.seconds = game.clock.seconds + (seconds or 0)
	game.clock.minutes = game.clock.minutes + (minutes or 0)
	game.clock.hours = game.clock.hours + (hours or 0)
	game.clock.days = game.clock.days + (days or 0)
	game.clock.months = game.clock.months + (months or 0)
	game.clock.years = game.clock.years + (years or 0)

	-- Normalize after adding time
	normalizeClock()
end

-- Remove time from the clock
function game.clock.removeTime(milliseconds, seconds, minutes, hours, days, months, years)
	game.clock.milliseconds = game.clock.milliseconds - (milliseconds or 0)
	game.clock.seconds = game.clock.seconds - (seconds or 0)
	game.clock.minutes = game.clock.minutes - (minutes or 0)
	game.clock.hours = game.clock.hours - (hours or 0)
	game.clock.days = game.clock.days - (days or 0)
	game.clock.months = game.clock.months - (months or 0)
	game.clock.years = game.clock.years - (years or 0)

	-- Normalize after removing time
	normalizeClock()
end

-- Set time to the clock
function game.clock.setTime(milliseconds, seconds, minutes, hours, days, months, years)
	game.clock.milliseconds = milliseconds or game.clock.milliseconds or 0
	game.clock.seconds = seconds or game.clock.seconds or 0
	game.clock.minutes = minutes or game.clock.minutes or 0
	game.clock.hours = hours or game.clock.hours or 0
	game.clock.days = days or game.clock.days or 0
	game.clock.months = months or game.clock.months or 0
	game.clock.years = years or game.clock.years or 0

	-- Normalize after modifiying the time.
	normalizeClock()
end

function game.clock.get(milliseconds, seconds, minutes, hours, days, months, years)
	local clock = {}
	local milliseconds = milliseconds or game.clock.milliseconds or 0
	local seconds = seconds or game.clock.seconds or 0
	local minutes = minutes or game.clock.minutes or 0
	local hours = hours or game.clock.hours or 0
	local days = days or game.clock.days or 0
	local months = months or game.clock.months or 0
	local years = years or game.clock.years or 0

	clock["milliseconds"]   = milliseconds
	clock["seconds"]        = seconds
	clock["minutes"]        = minutes
	clock["hours"]          = hours
	clock["days"]           = days
	clock["months"]         = months
	clock["years"]          = years

	return clock,
	milliseconds,
	seconds,
	minutes,
	hours,
	days,
	months,
	years
end

function game.clock.diff(a,b)
	-- Assuming both are clocks and i'm not checking because i'm lazy to implement a helper function for it.
	assert(a["milliseconds"] ~= nil, "Trying to clock diff a non-clock type.")
	assert(b["milliseconds"] ~= nil, "Trying to clock diff a non-clock type.")

	local milliseconds = math.abs(a["milliseconds"] - b["milliseconds"])
	local seconds = math.abs(a["seconds"] - b["seconds"])
	local minutes = math.abs(a["minutes"] - b["minutes"])
	local hours = math.abs(a["hours"] - b["hours"])
	local days = math.abs(a["days"] - b["days"])
	local months = math.abs(a["months"] - b["months"])
	local years = math.abs(a["years"] - b["years"])

	return game.clock.get(milliseconds, seconds, minutes, hours, days, months, years)
end

function game.clock.getHash(milliseconds, seconds, minutes, hours, days, months, years)
	local milliseconds = milliseconds or game.clock.milliseconds or 0
	local seconds = seconds or game.clock.seconds or 0
	local minutes = minutes or game.clock.minutes or 0
	local hours = hours or game.clock.hours or 0
	local days = days or game.clock.days or 0
	local months = months or game.clock.months or 0
	local years = years or game.clock.years or 0
	local s = tostring(milliseconds) ..
	tostring(seconds) ..
	tostring(minutes) ..
	tostring(hours) ..
	tostring(days) ..
	tostring(months) ..
	tostring(years)

	return love.data.hash("md5", s)
end


hooks.Add("OnGameUpdate", function(deltaTime)
	game.clock.lastTime = game.clock.get()
	updateClock(deltaTime)

	if love.keyboard.isDown("e") then
		game.clock.addTime(0, 0, 0, 1)
	end

	if love.keyboard.isDown("r") then
		game.clock.addTime(0, 0, 1)
	end

	game.clock.deltaClock = game.clock.diff(game.clock.lastTime, game.clock.get())
	local deltaMilliseconds = game.clock.deltaClock["milliseconds"] or 0
	local deltaSeconds = game.clock.deltaClock["seconds"] or 0
	local deltaMinutes = game.clock.deltaClock["minutes"] or 0
	local deltaHours = game.clock.deltaClock["hours"] or 0
	local deltaDays = game.clock.deltaClock["days"] or 0
	local deltaMonths = game.clock.deltaClock["months"] or 0
	local deltaYears = game.clock.deltaClock["years"] or 0

	if (deltaMilliseconds > 0) then
		hooks.Fire("ClockMillisecondsPassed", deltaMilliseconds)
	end
	if (deltaSeconds > 0) then
		hooks.Fire("ClockSecondsPassed", deltaSeconds)
	end
	if (deltaMinutes > 0) then
		hooks.Fire("ClockMinutesPassed", deltaMinutes)
	end
	if (deltaHours > 0) then
		hooks.Fire("ClockHoursPassed", deltaHours)
	end
	if (deltaDays > 0) then
		hooks.Fire("ClockDaysPassed", deltaDays)
	end
	if (deltaMonths > 0) then
		hooks.Fire("ClockMonthsPassed", deltaMonths)
	end
	if (deltaYears > 0) then
		hooks.Fire("ClockYearsPassed", deltaYears)
	end
end)

hooks.Add("PostGameDraw", function()
	-- Display the clock (example formatting)
	local text = string.format(
		"Years: %d, Months: %d, Days: %d, Hours: %d, Minutes: %d, Seconds: %d\nLeap Year?: %s\nMonth length: %s",
		game.clock.years,
		game.clock.months,
		game.clock.days,
		game.clock.hours,
		game.clock.minutes,
		game.clock.seconds,
		isLeapYear(game.clock.years) == true and "True" or "False",
		getCurrentMonthLength())

	love.graphics.setColor(1,1,1,1)
	love.graphics.setBlendMode("alpha")
	love.graphics.print(text, ScreenX() / 2, ScreenY()-64)
end)
