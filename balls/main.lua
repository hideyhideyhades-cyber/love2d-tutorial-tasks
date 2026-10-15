function love.load()
    love.window.setFullscreen(true)
end

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





Ball = default_constructible()
Ball.__index = Ball


local energy_coef = 0.95
local minv = 10
local k = 5000000

function Ball:wall_hit(dt)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local x, y, vx, vy = self.x, self.y, self.vx, self.vy
    local r = self.r
    local m = r ^ 3

    -- if (x + r > w - r) then
    --     local dl = x + 2 * r - w
    --     local f = k * dl
    --     local a = (f / m)
    --     self.vx = vx - a * dt
    -- end

    -- if (x < 2 * r) then
    --     local dl = 2 * r - x
    --     local f = k * dl
    --     local a = (f / m)
    --     self.vx = vx + a * dt
    -- end

    if ((x + r > w) and vx >= 0) or ((x - r < 0) and vx <= 0) then
        if vx > 0 then self.x = w - r
        elseif vx < 0 then self.x = r end

        self.vx = -vx * energy_coef
        if (math.abs(self.vx) < minv) then self.vx = 0 end
    end

    if ((y + r > h) and vy > 0) or ((y - r < 0) and vy < 0) then
        if vy > 0 then self.y = h - r
        elseif vy < 0 then self.y = r end

        self.vy = -vy * energy_coef
        if (math.abs(self.vy) < minv) then self.vy = 0 end
    end
end


function Ball:ball_hit(ball)
    local r1, r2 = self.r, ball.r
    local hit_d = r1 + r2

    local m1, m2 = self.r ^ 3, ball.r ^ 3

    local x1, y1, x2, y2 = self.x, self.y, ball.x, ball.y
    local dx, dy = x2 - x1, y2 - y1
    local d = math.sqrt(dx * dx + dy * dy)
    local nx, ny = dx/d, dy/d

    if (d > hit_d) then return end

    if (d < hit_d) then
        local overlap = hit_d - d
        local total_mass = m1 + m2

        local k1 = overlap * (m2 / total_mass)
        local k2 = overlap * (m1 / total_mass)

        self.x = self.x - nx * k1
        self.y = self.y - ny * k1
        ball.x = ball.x + nx * k2
        ball.y = ball.y + ny * k2
    end

    local v1x, v1y, v2x, v2y = self.vx, self.vy, ball.vx, ball.vy
    local v1n = v1x * nx + v1y * ny
    local v2n = v2x * nx + v2y * ny
    local _v1n = (m1 * v1n + m2 * v2n + energy_coef ^ 2 * (m2 * v2n - m2 * v1n))/(m1 + m2)
    local _v2n = (m2 * v2n + m1 * v1n + energy_coef ^ 2 * (m1 * v1n - m1 * v2n))/(m1 + m2)

    local _v1x = v1x + (_v1n - v1n) * nx
    local _v1y = v1y + (_v1n - v1n) * ny
    local _v2x = v2x + (_v2n - v2n) * nx
    local _v2y = v2y + (_v2n - v2n) * ny

    self.vx = _v1x
    self.vy = _v1y
    ball.vx = _v2x
    ball.vy = _v2y
    if (math.abs(self.vx) < minv) then self.vx = 0 end
    if (math.abs(self.vy) < minv) then self.vy = 0 end
    if (math.abs(ball.vx) < minv) then ball.vx = 0 end
    if (math.abs(ball.vy) < minv) then ball.vy = 0 end
end

function Ball:rectangle_hit(rectangle)

end

function Ball:object_hit()
    local ind = 0

    for i, obj in ipairs(Objects) do
        if obj == self then
            ind = i
            break
        end
    end

    for i = ind + 1, #Objects do
        local obj = Objects[i]

        if getmetatable(obj) == Ball then
            self:ball_hit(obj)
        elseif getmetatable(obj) == Rectangle then
            self:rectangle_hit(obj)
        end
    end
end

local g = 980

function Ball:calculate_xy(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end



local function random_ball()
    local ball = {
        r = love.math.random(10, 30),

        vx = love.math.random(-500, 500),
        vy = love.math.random(-500, 500),

        x = love.math.random(love.graphics.getWidth()),
        y = love.math.random(love.graphics.getWidth()),
    }
    return ball
end


function Ball:update(dt)
    self.vy = self.vy + g * dt
    self:calculate_xy(dt)
    self:object_hit()
    self:wall_hit(dt)
end

function Ball:draw()
    local x, y = self.x, self.y

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("line", x, y, self.r)
end


Rectangle = default_constructible()
Rectangle.__index = Rectangle


function Rectangle:hit_a_wall()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local x, y, vx, vy = self.x, self.y, self.vx, self.vy
    local a, b = self.a, self.b

    if ((x + a > w) and vx > 0) or ((x < 0) and vx < 0) then
        self.vx = -vx
    end

    if ((y + b > h) and vy > 0) or ((y < 0) and vy < 0) then
        self.vy = -vy
    end
end


function Rectangle:calculate_xy(dt)
    self:hit_a_wall()
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end


local function random_rectangle()
    local rectangle = {
        a = love.math.random(10, 30),
        b = love.math.random(10, 30),

        vx = love.math.random(-500, 500),
        vy = love.math.random(-500, 500),

        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
    }
    return rectangle
end


function Rectangle:update(dt)
    self:calculate_xy(dt)
end

function Rectangle:draw()
    local x, y = self.x, self.y

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, self.a, self.b)
end


local ball1 = Ball(random_ball())
local ball2 = Ball(random_ball())
local ball3 = Ball(random_ball())
local ball4 = Ball(random_ball())
local ball5 = Ball(random_ball())
local ball6 = Ball(random_ball())
local ball7 = Ball(random_ball())
local ball8 = Ball(random_ball())
local ball9 = Ball(random_ball())
local ball10 = Ball(random_ball())
local ball11 = Ball(random_ball())
local ball12 = Ball(random_ball())
local ball13 = Ball(random_ball())
local ball14 = Ball(random_ball())
local ball15 = Ball(random_ball())
local ball16 = Ball(random_ball())
local ball17 = Ball(random_ball())
local ball18 = Ball(random_ball())
local ball19 = Ball(random_ball())
local ball20 = Ball(random_ball())
local rectangle1 = Rectangle(random_rectangle())
local rectangle2 = Rectangle(random_rectangle())
local rectangle3 = Rectangle(random_rectangle())

Objects = {
    ball1,
    ball2,
    ball3,
    ball4,
    ball5,
    ball6,
    ball7,
    ball8,
    ball9,
    ball10,
    ball11,
    ball12,
    ball13,
    ball14,
    ball15,
    ball16,
    ball17,
    ball18,
    ball19,
    ball20,
    -- rectangle1,
    -- rectangle2,
    -- rectangle3,
}

function love.update(dt)
    for _, obj in ipairs(Objects) do
        obj:update(dt)
    end
end

function love.draw()
    for _, obj in ipairs(Objects) do
        obj:draw()
    end
end