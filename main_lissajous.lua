local Constructible = {
    __call = function (class, ...)
        return class.constructor(...)
    end
}

local function default_constructible()
    local class = {}
    class.constructor = function(obj)
        return setmetatable(obj, class)
    end

    return setmetatable(class, Constructible)
end



local function wave(t, w, delta)
    delta = delta or 0
    return math.sin(w * t + delta)
end

local function affine1(x, scale, shift)
    shift = shift or 0
    return shift + scale * x
end



Lissajous = default_constructible()

Lissajous.__index = Lissajous

function Lissajous:calculate_xy(time)
    local x = wave(time, self.a, self.delta)
    local y = wave(time, self.b)
    return affine1(x, self.A, self.cx), affine1(y, self.B, self.cy)
end


Ellipse = default_constructible()

Ellipse.__index = Ellipse

function Ellipse:calculate_xy(time)
    local x = math.cos(time)
    local y = math.sin(time)
    return affine1(x, self.A, self.cx), affine1(y, self.B, self.cy)
end


Sinus = default_constructible()

Sinus.__index = Sinus

function Sinus:calculate_xy(time)
    local x = time
    local y = math.sin(time)
    return affine1(x, self.A, self.cx), affine1(y, self.B, self.cy)
end


Parabola = default_constructible()

Parabola.__index = Parabola

function Parabola:calculate_xy(time)
    local x = time
    local y = self.a * time^2 + self.b * time + self.c
    return affine1(x, self.A, self.cx), affine1(y, self.B, self.cy)
end


Spirale = default_constructible()

Spirale.__index = Spirale

function Spirale:calculate_xy(time)
    local R = time
    local phi = time
    local x = R * math.cos(phi + self.alfa)
    local y = R * math.sin(phi + self.alfa)
    return affine1(x, self.A, self.cx), affine1(y, self.B, self.cy)
end


Ball = default_constructible()

Ball.__index = Ball

function Ball:update(dt)
    self.t = self.t + dt * self.speed
    if self.t > self.finish then self.t = self.start end
end

function Ball:draw()
    local x, y = self.tr:calculate_xy(self.t)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("line", x, y, self.r)
end





Worm = default_constructible()

Worm.__index = Worm

function Worm:update(dt)
    self.t = self.t + dt * self.speed
    if self.t > self.finish then self.t = self.start end
end

function Worm:draw()
    local length = self.worm_length

    local step = 0.01
    local dir_coef = self.speed < 0 and -1 or 1

    local tail_t = self.t - dir_coef * length


    local prev_x, prev_y = self.tr:calculate_xy(tail_t)

    for time = tail_t, self.t, dir_coef * step do
        local x, y = self.tr:calculate_xy(time)
        local alfa = dir_coef * (time - tail_t)/(length)

        love.graphics.setColor(1, 1, 1, alfa)
        love.graphics.line(prev_x, prev_y, x, y)

        prev_x, prev_y = x, y
    end
end





Curve = default_constructible()

Curve.__index = Curve

function Curve:update(dt)
end

function Curve:draw()
    local start = self.start
    local finish = self.finish
    local step = 0.01

    local prev_x, prev_y = self.tr:calculate_xy(start)

    for time = start, finish, step do
        local x, y = self.tr:calculate_xy(time)

        love.graphics.line(prev_x, prev_y, x, y)

        prev_x, prev_y = x, y
    end
end


local l1 = Lissajous{
    cx = love.graphics.getWidth() / 2 + 250,
    cy = love.graphics.getHeight() / 2 + 150,
    A = 100,
    B = 100,

    a = 3,
    b = 4,
    delta = 0,
}

local ball1 = Ball{
    tr = l1,
    t = 0,
    speed = 1.5,
    r = 10,
    start = 0,
    finish = 2 * math.pi,
}
local ball2 = Ball{
    tr = l1,
    t = -0.3,
    speed = 1.5,
    r = 10,
    start = 0,
    finish = 2 * math.pi,
}
local ball3 = Ball{
    tr = l1,
    t = -0.6,
    speed = 1.5,
    r = 10,
    start = 0,
    finish = 2 * math.pi,
}
local worm1 = Worm{
    tr = l1,
    t = 0,
    speed = 1.5,
    worm_length = 0.3,
    start = 0,
    finish = 2 * math.pi,
}
local worm2 = Worm{
    tr = l1,
    t = -0.3,
    speed = 1.5,
    worm_length = 0.3,
    start = -0.3,
    finish = 2 * math.pi - 0.3,
}
local worm3 = Worm{
    tr = l1,
    t = -0.6,
    speed = 1.5,
    worm_length = 0.3,
    start = -0.6,
    finish = 2 * math.pi - 0.6,
}
local curv6 = Curve{
    tr = l1,
    t = 0,
    speed = 1,
    start = 0,
    finish = math.pi * 2,
}








local e1 = Ellipse{
    cx = love.graphics.getWidth() / 2 + 250,
    cy = love.graphics.getHeight() / 2 - 100,

    A = 100,
    B = 150,
}

local eball1 = Ball{
    tr = e1,
    t = 4,
    speed = 3,
    r = 5,
    start = 4,
    finish = math.pi * 2 + 4,
}

local eworm1 = Worm{
    tr = e1,
    t = 4,
    speed = 3,
    worm_length = 2,
    start = 4,
    finish = math.pi * 2 + 4,
    
}

local curv2 = Curve{
    tr = e1,
    t = 0,
    speed = 1,
    start = 0,
    finish = math.pi * 2,
}








local s1 = Sinus{
    cx = 0,
    cy = love.graphics.getHeight() / 2 + 200,
    
    A = 30,
    B = 30,
}

local curv3 = Curve{
    tr = s1,
    t = 0,
    speed = 1,
    start = 0,
    finish = math.pi * 6,
}
local sball1 = Ball{
    tr = s1,
    t = 0,
    speed = 3,
    r = 5,
    start = 0,
    finish = math.pi * 6,
}

local sworm1 = Worm{
    tr = s1,
    t = 0,
    speed = 3,
    worm_length = 2,
    start = 0,
    finish = math.pi * 6,
}

local sball2 = Ball{
    tr = s1,
    t = 2,
    speed = 3,
    r = 5,
    start = 2,
    finish = math.pi * 6 + 2,
}

local sworm2 = Worm{
    tr = s1,
    t = 2,
    speed = 3,
    worm_length = 2,
    start = 2,
    finish = math.pi * 6 + 2,
}

local sball3 = Ball{
    tr = s1,
    t = 4,
    speed = 3,
    r = 5,
    start = 4,
    finish = math.pi * 6 + 4,
}

local sworm3 = Worm{
    tr = s1,
    t = 4,
    speed = 3,
    worm_length = 2,
    start = 4,
    finish = math.pi * 6 + 4,
}










local p1 = Parabola{
    cx = love.graphics.getWidth() / 2,
    cy = love.graphics.getHeight() / 2 + 200,

    A = 50,
    B = 50,
    a = -1,
    b = 0,
    c = 0,
}

local curv4 = Curve{
    tr = p1,
    t = 0,
    speed = 1,
    start = -math.pi,
    finish = math.pi 
}

local pball = Ball{
    tr = p1,
    t = -math.pi,
    speed = 1.5,
    r = 15,
    start = -math.pi,
    finish = math.pi,
}









local sp1 = Spirale{
    cx = love.graphics.getWidth() / 2,
    cy = love.graphics.getHeight() / 2,

    A = 10,
    B = 10,
    alfa = 0;
}
local curv5 = Curve{
    tr = sp1,
    t = 0,
    speed = 1,
    start = 0,
    finish = math.pi * 8
}
local spball1 = Ball{
    tr = sp1,
    t = 0,
    speed = 3,
    r = 5,
    start = 0,
    finish = math.pi * 8,
}

local spworm1 = Worm{
    tr = sp1,
    t = 0,
    speed = 3,
    worm_length = 0.3,
    start = 0,
    finish = math.pi * 8
}

local spball2 = Ball{
    tr = sp1,
    t = 0.3,
    speed = 3,
    r = 5,
    start = 0.3,
    finish = math.pi * 8 + 0.3,
}

local spworm2 = Worm{
    tr = sp1,
    t = 0.3,
    speed = 3,
    worm_length = 0.3,
    start = 0.3,
    finish = math.pi * 8 + 0.3,
}

local spball3 = Ball{
    tr = sp1,
    t = 0.6,
    speed = 3,
    r = 5,
    start = 0.6,
    finish = math.pi * 8 + 0.6,
}

local spworm3 = Worm{
    tr = sp1,
    t = 0.6,
    speed = 3,
    worm_length = 0.3,
    start = 0.6,
    finish = math.pi * 8 + 0.6,
}








local l2 = Lissajous{
    cx = 120,
    cy = 120,
    A = 100,
    B = 100,

    a = 2,
    b = 5,
    delta = 1,
}

local curv1 = Curve{
    tr = l2,
    t = 0,
    speed = 1,
    start = 0,
    finish = math.pi * 2,
}
local dumb_ball = Ball{
    tr = l2,
    t = 0,
    speed = 1,
    r = 15,
    start = 0,
    finish = math.pi * 2,
}




local objects = {

    ball1,
    ball2,
    ball3,
    worm1,
    worm2,
    worm3,
    curv1,
    --curv2,
    --curv3,
    curv4,
    --curv5,
    --curv6,
    dumb_ball,

    pball,


    spball1,
    spworm1,
    spball2,
    spworm2,
    spball3,
    spworm3,


    sball1,
    sworm1,
    sball2,
    sworm2,
    sball3,
    sworm3,

    eball1,
    eworm1
}



function love.update(dt)
    for _, obj in ipairs(objects) do
        obj:update(dt)
    end
end

function love.draw()
    for _, obj in ipairs(objects) do
        obj:draw()
    end
end