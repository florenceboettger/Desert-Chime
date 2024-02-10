--[[

Grow a Spline v1.1a
- 9thCore
- draw width, draw sprite and show by underFlorence

A library which calculates stuff to make Bézier curves and splines.

FUNCTIONS
gas.curve(x1, y1, x2, y2, x3, y3, x4, y4)

  - every argument is a number
    - x1, y1, and x3, y3 and the positions of the start and end of the curve, while x2, y2 and x4, y4 are the position of the points used to make the curve

  - returns a curve object

gas.spline(...)

  - every argument is a number, but
    - there have to a multiple of 8 arguments
    - every set of 8 arguments should be laid out as x1, y1, x2, y2, x3, y3, x4, y4 with the same meaning as the arguments passsed to gas.curve()
      - example: gas.spline(0, 0, 50, 60, 100, 0, 150, -50) would make a curve from 0, 0 to 100, 0
                 gas.spline(0, 0, 50, 60, 100, 0, 150, -50, 40, 120, 100, 75, 170, 90, 200, 100) would make a curve from 0, 0 to 100, 0 and another curve from 40, 120 to 170, 90

    - this explanation probably makes no sense so look at the example encounter and tinker around to see what happens

  - returns a spline object

gas.smoothspline(...)

  - every argument is a number, but
    - there have to a multiple of 4 arguments
    - as opposed to gas.spline(), this connects the curves together!
      - example: gas.smoothspline(0, 0, 50, 60, 100, 0, 150, -50) would make a curve from 0, 0 to 100, 0
                 gas.smoothspline(0, 0, 50, 60, 100, 0, 150, -50, 200, 0, -50, 150) would make a curve from 0, 0 to 100, 0 and another curve from 100, 0 to 200, 0

    - this explanation probably makes no sense so look at the example encounter and tinker around to see what happens

  - returns a spline object

OBJECTS
- curve
  - an object representing a curve

    - curve.points
      - table, the points of the curve
      - if you want to move a point, don't directly change this. similarly, if you want to get a point's position, there's a function to make that easier

    - curve.segments
      - table, the segments of the curve after curve.draw() is called
      - gets emptied when curve.cleardraw() is called

    - curve.getpointcount()
      - returns how many points the curve has, so 4
      - only reason it exists is parity with the spline object

    - curve.getpoint(idx)
      - [idx] is a number
      - returns two numbers, the x and y positions of the point at index [idx]

    - curve.movepoint(idx, x, y)
      - every argument is a number
      - moves the point at index [idx] to [x] and [y]

    - curve.getpos(t)
      - [t] is a number, 0-1
      - v1.1: no longer has to be in the 0-1 range, but unintended effects may happen if not
      
      - returns two numbers, the x and y positions on the curve at the time [t]

    - curve.draw(segments = 20, color = {1, 1, 1, 1}, layer = 'Top', width = 1)
      - [segments] is a number, [color] is a table of numbers in the range 0-1, [layer] is a string
      - draws the curve with [segments] lines, with the color [color], a width of [width] and on the layer [layer]
	  - note that for very large widths, the number of segments needs to also be larger

	- curve.show(segments = 20, color = {1, 1, 1, 1}, layer = 'Top', width = 1)
	  - same usage as curve.draw except it only needs to be called once
	  - any use of spline.movepoint() from then on updates the display

    - curve.cleardraw()
      - removes the segments drawn by curve.draw() or curve.show()
      - automatically called whenever curve.draw() or curve.show() are

	- curve.updatelayer(layer)
	  - if curve is being displayed, updates the layer of the sprites

	- curve.updatecolor(color)
	  - if curve is being displayed, updates the color of the sprites

	- curve.updatewidth(color)
	  - if curve is being displayed, updates the width of the sprites

- spline
  - an object representing a spline

    - spline.points
      - table, the points of the spline
      - if you want to move a point, don't directly change this. similarly, if you want to get a point's position, there's a function to make that easier

    - spline.curves
      - table, the curves of the spline

    - spline.getpointcount()
      - returns how many points the spline has

    - spline.getpoint(idx)
      - [idx] is a number
      - returns two numbers, the x and y positions of the point at index [idx]

    - spline.movepoint(idx, x, y)
      - every argument is a number
      - moves the point at index [idx] to [x] and [y]

    - spline.getpos(t)
      - [t] is a number, 0-1
      - v1.1: no longer has to be in the 0-1 range, but unintended effects may happen if not

      - returns two numbers, the x and y positions on the spline at the time [t]

    - spline.getspeedmultiplier()
      - returns a number. multiply your timer by this
      - useful because, due to how spline.getpos() works, the more curves there are, the less time each takes
      - see the example encounter

    - spline.draw(segments = 20, color = {1, 1, 1, 1}, layer = 'Top', width = 1)
      - [segments] is a number, [color] is a table of numbers in the range 0-1, [layer] is a string
      - draws the spline with [segments] lines for each curve, with the color [color], a width of [width] and on the layer [layer]
	  - note that for very large widths, the number of segments needs to also be larger

	- spline.show(segments = 20, color = {1, 1, 1, 1}, layer = 'Top', width = 1)
	  - same usage as spline.draw except it only needs to be called once
	  - any use of spline.movepoint() from then on updates the display

    - spline.cleardraw()
      - removes the segments drawn by spline.draw() or spline.show()
      - automatically called whenever spline.draw() or spline.show() are

	- spline.updatelayer(layer)
	  - if spline is being displayed, updates the layer of the sprites

	- spline.updatecolor(color)
	  - if spline is being displayed, updates the color of the sprites

	- spline.updatewidth(color)
	  - if spline is being displayed, updates the width of the sprites

]]

local self = {}

-- i just copied this from https://en.wikipedia.org/wiki/B%C3%A9zier_curve
local function magic(t, p1, p2, p3, p4)
	return (1 - t)^3 * p1 + 3 * (1 - t)^2 * t * p2 + 3 * (1 - t) * t^2 * p3 + t^3 * p4
end

local function createline(layer, width, color, sprite, top)
	local spr 
	if type(layer) == type('') then
		spr = CreateSprite(sprite, layer)
	elseif type(layer) == "userdata" then
		spr = CreateSprite(sprite)
		spr.SetParent(layer)
	end
	if not top then spr.SendToBottom() end
	spr.SetPivot(0,0.5)
	spr.yscale = width / spr.height
	spr.color = color

	return spr
end

local function updateline(curve, spr, t1, t2)
	local x, y = curve.getpos(t1)
	local x2, y2 = curve.getpos(t2)
	local diffx, diffy = x2 - x, y2 - y
	local dist = math.sqrt(diffx*diffx + diffy*diffy)

	local angle = math.deg(math.atan2(diffy, diffx))

	spr.MoveToAbs(x,y)
	spr.xscale = dist
	spr.rotation = angle
end

local function newline(curve, color, layer, width, x, y, x2, y2)

	local diffx, diffy = x2 - x, y2 - y
	local dist = math.sqrt(diffx*diffx + diffy*diffy)

	local angle = math.deg(math.atan2(diffy, diffx))

	local spr = createline(layer, width, color)

	spr.MoveToAbs(x,y)

	spr.xscale = dist
	spr.rotation = angle

	curve.segments[#curve.segments+1] = spr

end

local generalWrongTypeError = '%s should be a %s, but it is a %s!'
local argIdxWrongTypeError = 'Argument #%d: expected a %s but got a %s!'
local argIdxNotInRangeError = 'Argument #%d should be between %d and %d!'
local movePointError = 'Can\'t move point %d because it doesn\'t exist!'
local getPointError = 'Can\'t get point %d because it doesn\'t exist!'
local notEnoughPoints = '%s need %s points!'
local notEvenCount = '%s need an even amount of positions! (each point needs one x coord and one y coord!)'

-- takes a function curve, [0, 1] -> R^2 that takes a curve + relative point on the curve and gives a position
function self.genericcurve(func)
	if type(func) ~= type(function() return nil end) then
		error(argIdxWrongTypeError:format(1, type(function() return nil end), type(func)), 2)
	end

	local curve = {}
	curve.segments = {}

	function curve.getpos(t)
		return func(curve, t)
	end

	function curve.updatepoints()
		if #curve.segments > 0 then
			local i = 1
			local step = 1 / #curve.segments
			for t = step, 1 - step * 0.99, step do
				updateline(curve, curve.segments[i], t - step, t)
				i = i + 1
			end
			updateline(curve, curve.segments[i], 1 - step, 1)
		end
	end

	function curve.show(segments, color, layer, width, sprite, top)
		if type(segments) ~= type(1) and type(segments) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(segments), 2)) end
		if type(color) ~= type({}) and type(color) ~= type(nil) then error(argIdxWrongTypeError:format(2, type({}), type(color), 2)) end
		if type(layer) ~= type('') and type(layer) ~= "userdata" and type(layer) ~= type(nil) then error(argIdxWrongTypeError:format(3, type(''), type(layer), 2)) end
		if type(width) ~= type(1) and type(width) ~= type(nil) then error(argIdxWrongTypeError:format(4, type(1), type(width), 2)) end
		if type(sprite) ~= type('') and type(sprite) ~= type(nil) then error(argIdxWrongTypeError:format(5, type(''), type(sprite), 2)) end
		if type(top) ~= type(true) and type(top) ~= type(nil) then error(argIdxWrongTypeError:format(6, type(true), type(top), 2)) end

		if color then
			for i = 1, #color do
				if type(color[i]) ~= type(1) then error('Argument #2: expected a table of numbers!', 2) end
			end
		end

		segments = segments or 16
		color = color or {1,1,1,1}
		layer = layer or 'Top'
		width = width or 1
		sprite = sprite or "px"
		if top == nil then top = true end

		curve.cleardraw()

		local step = 1 / segments

		for t = step, 1 - step * 0.99, step do
			local spr = createline(layer, width, color, sprite, top)
			updateline(curve, spr, t - step, t)
			curve.segments[#curve.segments+1] = spr
		end

		local spr = createline(layer, width, color, sprite, top)
		updateline(curve, spr, 1 - step, 1)
		curve.segments[#curve.segments+1] = spr
	end

	function curve.updatecolor(color)
		if color then
			for i = 1, #color do
				if type(color[i]) ~= type(1) then error('Argument #2: expected a table of numbers!', 2) end
			end
		end

		for _, spr in ipairs(curve.segments) do
			spr.color = color
		end
	end

	function curve.updatewidth(width)
		if type(width) ~= type(1) and type(width) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(width), 2)) end

		for _, spr in ipairs(curve.segments) do
			spr.yscale = width
		end
	end

	function curve.updatelayer(layer)
		if type(layer) ~= type('') and type(layer) ~= type(nil) then error(argIdxWrongTypeError:format(3, type(''), type(layer), 2)) end

		for _, spr in ipairs(curve.segments) do
			spr.layer = layer
		end
	end

	function curve.cleardraw()
		for _,sprite in ipairs(curve.segments) do
			sprite.Remove()
		end

		curve.segments = {}
	end

	return curve
end

function self.curve(x1, y1, x2, y2, x3, y3, x4, y4)
	if not y4 then
		error(notEnoughPoints:format('Curves', '4'), 2)
	end

	local curve = self.genericcurve(function (c, t)
		local x1, y1 = c.points[1], c.points[2]
		local x2, y2 = c.points[3], c.points[4]
		local x4, y4 = c.points[5], c.points[6]
		local x3, y3 = c.points[7], c.points[8]

		local x = magic(t, x1, x2, x3, x4)
		local y = magic(t, y1, y2, y3, y4)

		return x, y
	end)
	curve.points = {x1, y1, x2, y2, x3, y3, x4, y4}

	for i, arg in ipairs(curve.points) do
		if type(arg) ~= type(1) then
			error(argIdxWrongTypeError:format(i, type(1), type(arg)), 2)
		end
	end

	function curve.movepoint(idx, x, y)

		if type(idx) ~= type(1) then
			error(argIdxWrongTypeError:format(1, type(1), type(idx)), 2)
		elseif type(x) ~= type(1) then
			error(argIdxWrongTypeError:format(2, type(1), type(x)), 2)
		elseif type(y) ~= type(1) then
			error(argIdxWrongTypeError:format(3, type(1), type(y)), 2)
		end

		if idx < 1 or idx > 4 then error(movePointError:format(idx), 2) end

		curve.points[idx*2-1], curve.points[idx*2] = x, y

		curve.updatepoints()
	end

	function curve.getpointcount()
		return 4
	end

	function curve.draw(segments, color, layer, width)
		if type(segments) ~= type(1) and type(segments) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(segments), 2)) end
		if type(color) ~= type({}) and type(color) ~= type(nil) then error(argIdxWrongTypeError:format(2, type({}), type(color), 2)) end
		if type(layer) ~= type('') and type(layer) ~= type(nil) then error(argIdxWrongTypeError:format(3, type(''), type(layer), 2)) end
		if type(width) ~= type(1) and type(width) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(width), 2)) end

		if color then
			for i = 1, #color do
				if type(color[i]) ~= type(1) then error('Argument #2: expected a table of numbers!', 2) end
			end
		end

		curve.cleardraw()

		segments = segments or 16
		color = color or {1,1,1,1}
		layer = layer or 'Top'
		width = width or 1

		local step = 1 / segments

		for t = step, 1 - step * 0.99, step do

			local x, y = curve.getpos(t - step)
			local x2, y2 = curve.getpos(t)

			newline(curve, color, layer, width, x, y, x2, y2)

		end

		local x, y = curve.getpos(1 - step)
		local x2, y2 = curve.getpos(1)

		newline(curve, color, layer, width, x, y, x2, y2)
	end

	return curve
end

local function newspline(...)

	local spline = {}

	spline.points = {...}

	function spline.getpointcount()
		return #spline.points/2
	end

	function spline.getpoint(idx)
		if type(idx) ~= type(1) then error(argIdxWrongTypeError:format(1, type(1), type(idx)), 2) end
		if idx < 1 or idx > spline.getpointcount() then error(getPointError:format(idx), 2) end

		return spline.points[idx*2-1], spline.points[idx*2]
	end

	spline.curves = {}

	local pcount = spline.getpointcount()

	for i = 1, pcount - 3, 4 do

		local x1, y1 = spline.getpoint(i  )
		local x2, y2 = spline.getpoint(i+1)
		local x3, y3 = spline.getpoint(i+2)
		local x4, y4 = spline.getpoint(i+3)

		spline.curves[#spline.curves+1] = self.curve(x1, y1, x2, y2, x3, y3, x4, y4)

	end

	function spline.getpos(t)

		if type(t) ~= type(1) then error(argIdxWrongTypeError:format(1, type(1), type(t)), 2) end

		local pcount = spline.getpointcount()/2

		local barrier = 2 / pcount
		local idx = math.max(math.min(math.floor(t/barrier)+1, #spline.curves), 1)

		if t > 0 and t < 1 then t = (t % barrier) * pcount/2
		elseif t >= 1 then
			t = (t-1) * pcount/2 + 1
		else
			t = t * pcount/2
		end

		return spline.curves[idx].getpos(t)

	end

	function spline.movepoint(idx, x, y)

		if type(idx) ~= type(1) then
			error(argIdxWrongTypeError:format(1, type(1), type(idx)), 2)
		elseif type(x) ~= type(1) then
			error(argIdxWrongTypeError:format(2, type(1), type(x)), 2)
		elseif type(y) ~= type(1) then
			error(argIdxWrongTypeError:format(3, type(1), type(y)), 2)
		end

		local pcount = spline.getpointcount()

		if idx < 1 or idx > pcount then error(movePointError:format(idx), 2) end

		spline.points[idx*2-1], spline.points[idx*2] = x, y

		local curveidx = math.floor((idx-1)/4)+1

		spline.curves[curveidx].movepoint((idx-1)%4+1, x, y)

	end

	function spline.getspeedmultiplier()
		return 2 / (spline.getpointcount() / 2)
	end

	function spline.show(segments, color, layer, width)
		if type(segments) ~= type(1) and type(segments) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(segments), 2)) end
		if type(color) ~= type({}) and type(color) ~= type(nil) then error(argIdxWrongTypeError:format(2, type({}), type(color), 2)) end
		if type(layer) ~= type('') and type(layer) ~= type(nil) then error(argIdxWrongTypeError:format(3, type(''), type(layer), 2)) end
		if type(width) ~= type(1) and type(width) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(width), 2)) end

		if color then
			for i = 1, #color do
				if type(color[i]) ~= type(1) then error('Argument #2: expected a table of numbers!', 2) end
			end
		end

		for _, curve in ipairs(spline.curves) do
			curve.show(segments, color, layer, width)
		end
	end

	function spline.updatewidth(width)
		for _, curve in ipairs(spline.curves) do
			curve.updatewidth(width)
		end
	end

	function spline.updatecolor(color)
		for _, curve in ipairs(spline.curves) do
			curve.updatecolor(color)
		end
	end

	function spline.updatelayer(layer)
		for _, curve in ipairs(spline.curves) do
			curve.updatelayer(layer)
		end
	end

	function spline.draw(segments, color, layer, width)

		if type(segments) ~= type(1) and type(segments) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(segments), 2)) end
		if type(color) ~= type({}) and type(color) ~= type(nil) then error(argIdxWrongTypeError:format(2, type({}), type(color), 2)) end
		if type(layer) ~= type('') and type(layer) ~= type(nil) then error(argIdxWrongTypeError:format(3, type(''), type(layer), 2)) end
		if type(width) ~= type(1) and type(width) ~= type(nil) then error(argIdxWrongTypeError:format(1, type(1), type(width), 2)) end

		if color then
			for i = 1, #color do
				if type(color[i]) ~= type(1) then error('Argument #2: expected a table of numbers!', 2) end
			end
		end

		for _,curve in ipairs(spline.curves) do

			curve.draw(segments, color, layer, width)

		end

	end

	function spline.cleardraw()

		for _,curve in ipairs(spline.curves) do
			curve.cleardraw()
		end

	end

	return spline

end

-- spline where each start and end of each curve is supplied
function self.spline(...)

	local spline = newspline(...)

	for i,arg in ipairs(spline.points) do
		if type(arg) ~= type(1) then
			error(argIdxWrongTypeError:format(i, type(1), type(arg)), 2)
		end
	end

	if #spline.points % 2 ~= 0 then
		error(notEvenCount:format('Splines'), 2)
	end

	if #spline.points < 8 then
		error(notEnoughPoints:format('Splines', 'at least 4'), 2)
	end

	if (#spline.points/2) % 4 ~= 0 then
		error(notEnoughPoints:format('Splines', 'a multiple of 4'), 2)
	end

	return spline

end

-- spline where all the curves join
function self.smoothspline(...)

	local spline = newspline(...)

	spline.curves = {}

	for i,arg in ipairs(spline.points) do
		if type(arg) ~= type(1) then
			error(argIdxWrongTypeError:format(i, type(1), type(arg)), 2)
		end
	end

	if #spline.points % 2 ~= 0 then
		error(notEvenCount:format('Smooth splines'), 2)
	end

	if #spline.points < 8 then
		error(notEnoughPoints:format('Smooth splines', 'at least 4'), 2)
	end

	if (#spline.points/2) % 2 ~= 0 then
		error(notEnoughPoints:format('Smooth splines', 'a multiple of 2'), 2)
	end

	local pcount = spline.getpointcount()

	local x1, y1 = spline.getpoint(1)
	local x2, y2 = spline.getpoint(2)
	local x3, y3 = spline.getpoint(3)
	local x4, y4 = spline.getpoint(4)

	spline.curves[#spline.curves+1] = self.curve(x1, y1, x2, y2, x3, y3, x4, y4)

	for i = 3, pcount - 3, 2 do

		local x1, y1 = spline.getpoint(i  )
		local x2, y2 = spline.getpoint(i+1)
		local x3, y3 = spline.getpoint(i+2)
		local x4, y4 = spline.getpoint(i+3)

		local diffx, diffy = x2 - x1, y2 - y1
		x2, y2 = x1 - diffx, y1 - diffy

		spline.curves[#spline.curves+1] = self.curve(x1, y1, x2, y2, x3, y3, x4, y4)

	end

	function spline.getpos(t)

		if type(t) ~= type(1) then error(argIdxWrongTypeError:format(1, type(1), type(t)), 2) end

		local pcount = spline.getpointcount() - 2

		local barrier = 2 / pcount
		local idx = math.max(math.min(math.floor(t/barrier)+1, #spline.curves), 1)

		if t > 0 and t < 1 then t = (t % barrier) * pcount/2
		elseif t >= 1 then
			t = (t-1) * pcount/2 + 1
		else
			t = t * pcount/2
		end

		return spline.curves[idx].getpos(t)

	end

	function spline.getspeedmultiplier()
		return 2 / (spline.getpointcount() - 2)
	end

	function spline.movepoint(idx, x, y)

		local pcount = spline.getpointcount()

		if type(idx) ~= type(1) then
			error(argIdxWrongTypeError:format(1, type(1), type(idx)), 2)
		elseif type(x) ~= type(1) then
			error(argIdxWrongTypeError:format(2, type(1), type(x)), 2)
		elseif type(y) ~= type(1) then
			error(argIdxWrongTypeError:format(3, type(1), type(y)), 2)
		end

		if idx < 1 or idx > pcount then error(movePointError:format(idx), 2) end

		spline.points[idx*2-1], spline.points[idx*2] = x, y

		if idx < 3 then -- first two points, special case (they are in only one curve)

			spline.curves[1].movepoint(idx, x, y)

		elseif idx > pcount - 2 then -- last two points, special case (they are in only one curve)

			spline.curves[#spline.curves].movepoint(idx - (pcount - 2) + 2, x, y)

		else -- other points, general case

			local curveidx = math.floor((idx - 3) / 2) + 2

			spline.curves[curveidx].movepoint(idx - (curveidx-1)*2, x, y)
			spline.curves[curveidx-1].movepoint(idx - (curveidx-1)*2 + 2, x, y)

			if idx % 2 == 1 then -- main point

				local x2, y2 = spline.getpoint(idx+1)

				local diffx, diffy = x2 - x, y2 - y

				x2, y2 = x - diffx, y - diffy

				spline.curves[curveidx].movepoint(idx - (curveidx-1)*2 + 1, x2, y2)

			else -- control point

				local x2, y2 = spline.getpoint(idx-1)

				local diffx, diffy = x - x2, y - y2

				x2, y2 = x2 - diffx, y2 - diffy

				spline.curves[curveidx].movepoint(idx - (curveidx-1)*2, x2, y2)

			end

		end

	end

	return spline

end

return self