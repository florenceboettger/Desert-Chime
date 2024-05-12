local gas = require 'gas'

local self = {}

local argIdxNotInRangeError = 'Argument #%d should be between %d and %d!'

--- Performs easing between [0, 1] using a Bezier curve defined by the first two points.
--- Optional param iterations shows accuracy of the Binary Search.
--- For slower time spans for the ease, increase this number if it is choppy.
--- Use https://cubic-bezier.com/ to find fitting values for what you need.
---
--- @param x1 number (In [0, 1]) x coordinate of the first variable point
--- @param y1 number y coordinate of the first variable point
--- @param x2 number (In [0, 1]) x coordinate of the second variable point
--- @param y2 number y coordinate of the second variable point
--- @param x number Point at which to sample
--- @param[opt=7] iterations number (Optional, defaults to 7) Number of Binary Search iterations
--- @return number vy
function self.ease(x1, y1, x2, y2, x, iterations)
	iterations = iterations or 7

	if x == 0 then
		return 0
	elseif x == 1 then
		return 1
	end

	-- if x values are out of [0, 1] range, the curve is not a function
	if x1 < 0 or x1 > 1 then
		error(argIdxNotInRangeError:format(x1, 0, 1))
	elseif x2 < 0 or x2 > 1 then
		error(argIdxNotInRangeError:format(x2, 0, 1))
	end

	local curve = gas.curve(0, 0, x1, y1, 1, 1, x2, y2)

	local min = 0
	local max = 1

	local vx, vy

	for _ = 1, iterations do
		local t = (min + max) / 2
		vx, vy = curve.getpos(t)

		if vx < x then
			min = t
		elseif vx > x then
			max = t
		else
			break
		end
	end

	return vy
end

return self