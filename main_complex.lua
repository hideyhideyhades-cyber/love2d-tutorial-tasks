local Constructible = {
    __call = function (Class, ...)
        return Class.constructor(...)
    end
}

Complex = {}

setmetatable(Complex, Constructible)


Complex.__index = Complex

Complex.constructor = function (a)
    local obj = {}
    if type(a) =="number" then
        obj = {a, 0}
    elseif type(a) =="table" then
        obj = {a[1] or 0, a[2] or 0}
    else
        obj = {69, 69}
    end

    return setmetatable(obj, Complex)
end


local C = Complex

local complex_string = function(z)
    local a = z[1]
    local b = z[2]
    local real = tostring(a)
    local imaginary = tostring(b).."i"

    if a == 0 then real = "" end
    if b == 0 then imaginary = "" end
    if a == 0 and b == 0 then real = "0" end
    if b == 1 then imaginary = "i" end
    if b == -1 then imaginary = "-i" end
    if b > 0 and a ~= 0 then imaginary = "+"..imaginary end
    return (real..imaginary)
end




local re = function(a)
    return a[1]
end

local im = function(a)
    return a[2]
end




local complex_add = function (a, b)
    a = C(a)
    b = C(b)
    return {a[1] + b[1], a[2] + b[2]}
end

local complex_sub = function (a, b)
    a = C(a)
    b = C(b)
    return {a[1] - b[1], a[2] - b[2]}
end

local complex_mul = function (a, b)
    a = C(a)
    b = C(b)
    return {a[1] * b[1] - a[2] * b[2], a[1] * b[2] + b[1] * a[2]}
end







-- print(complex_string{5, 3})
-- print(complex_string{5, -3})
-- print(complex_string{0, 3})
-- print(complex_string{5, 0})
-- print(complex_string{0, 0})
-- print(complex_string{5, 1})
-- print(complex_string{5, -1})

-- print(re{6, 7})
-- print(im{6, 7})

-- print(complex_string(complex_add({6, 7}, 6)))
-- print(complex_string(complex_sub(6, {6, 9})))
-- print(complex_string(complex_mul(7, {6, 9})))
-- print(complex_string(complex_mul(7, 6)))

local z1 = C{3, 1}
local z2 = C{4, 1}
local z3 = C{5, 6}
local z4 = C{5, 9}

-- print(complex_string(complex_sub(complex_mul(z1, z2), complex_mul(complex_add(z3, 5), z4))))


Complex.re = re
Complex.im = im

Complex.scale = function (self, factor)
    self[1] = self[1] * factor
    self[2] = self[2] * factor
end

Complex.__add = function (a, b)
    a = C(a)
    b = C(b)
    return C{a[1] + b[1], a[2] + b[2]}
end

Complex.__sub = function (a, b)
    a = C(a)
    b = C(b)
    return C{a[1] - b[1], a[2] - b[2]}
end

Complex.__mul = function (a, b)
    a = C(a)
    b = C(b)
    return C{a[1] * b[1] - a[2] * b[2], a[1] * b[2] + b[1] * a[2]}
end

Complex.__tostring = function (z)
    local a = z[1]
    local b = z[2]
    local real = tostring(a)
    local imaginary = tostring(b).."i"

    if a == 0 then real = "" end
    if b == 0 then imaginary = "" end
    if a == 0 and b == 0 then real = "0" end
    if b == 1 then imaginary = "i" end
    if b == -1 then imaginary = "-i" end
    if b > 0 and a ~= 0 then imaginary = "+"..imaginary end
    return (real..imaginary)
end

-- print(z1)

print(z1 * z2 - (z3 + 5) * z4)
-- z1:scale(8)
-- print(z1)