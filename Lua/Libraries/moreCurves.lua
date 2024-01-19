local gas = require "gas"

local self = {}

local argIdxWrongTypeError = 'Argument #%d: expected a %s but got a %s!'

function self.circle(x, y, r)
    if type(x) ~= type(0) then error(argIdxWrongTypeError:format(1, type(0), type(x), 2)) end
    if type(y) ~= type(0) then error(argIdxWrongTypeError:format(1, type(0), type(y), 2)) end
    if type(r) ~= type(0) then error(argIdxWrongTypeError:format(1, type(0), type(r), 2)) end

    local curve = gas.genericcurve(function (c, t)
        return
            c.x + c.r * math.sin(t * 2 * math.pi),
            c.y + c.r * math.cos(t * 2 * math.pi)
    end)

    curve.x = x
    curve.y = y
    curve.r = r

    function curve.setx(x)
        curve.x = x
        curve.updatepoints()
    end

    function curve.sety(y)
        curve.y = y
        curve.updatepoints()
    end

    function curve.setr(r)
        curve.r = r
        curve.updatepoints()
    end

    return curve
end