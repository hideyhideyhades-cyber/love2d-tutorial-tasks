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

function Ball:wall_hit(dt)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local x, y, vx, vy = self.x, self.y, self.vx, self.vy
    local r = self.r
    local m = r ^ 3


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

        if getmetatable(obj) == Ball and not obj.aimed then
            self:ball_hit(obj)
        end
    end
end

local g = 980

function Ball:calculate_xy(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

local time_frame = 2
local timer_on = false
local elapsed_time = 0



local function random_ball()
    local ball = {
        r = love.math.random(10, 30),

        vx = love.math.random(-500, 500),
        vy = love.math.random(-500, 500),

        x = love.math.random(30, love.graphics.getWidth() - 30),
        y = love.math.random(30, love.graphics.getHeight() - 30),

        aimed = false,
    }
    return Ball(ball)
end
local function aimed_ball()
    local ball = {
        r = 30,

        x = 200,
        y = 500,

        vx = 0,
        vy = 0,

        maxv = 1500,
        v = 0,
        ind = 0,

        aimed = true,
        grad = math.pi/4,

        l = 1,
        tstep = 0,
    }
    return Ball(ball)
end
local function set_new_ball_for_aim()
    local ball = aimed_ball()
    table.insert(Objects, ball)
end

function Ball:throw()
    if not self.aimed then return end

    self.vx = self.v * math.cos(self.grad)
    self.vy = -self.v * math.sin(self.grad)
    self.aimed = false

    timer_on = true
end

function Ball:trajectory_draw()
    if not self.aimed then return end

    self.tstep = (self.tstep - 0.005) % 0.2

    local step = 0.01

    local prevx, prevy = self.x, self.y
    local vx = self.v * math.cos(self.grad)
    local vy = -self.v * math.sin(self.grad)
    local x, y = prevx, prevy
    local tstep = self.tstep % 0.2

    for time = 0, self.l, step do
        vy = vy + g * step
        x = x + vx * step
        y = y + vy * step

        if not (tstep >= 0.1 and tstep < 0.2) then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.line(prevx, prevy, x, y)
        end

        prevx, prevy = x, y
        tstep = (tstep + step) % 0.2
    end
end



function Ball:gravitation(dt)
    if self.aimed then return end
    self.vy = self.vy + g * dt
end


function Ball:update(dt)
    self:gravitation(dt)
    self:calculate_xy(dt)
    self:object_hit()
    self:wall_hit()
end



function Ball:draw()
    self:trajectory_draw()
    local x, y = self.x, self.y

    love.graphics.setColor(1, 1, 1, 1)

    if self.aimed then
        love.graphics.setColor(self.ind, 0, 1 - self.ind, 1)
    end

    love.graphics.circle("line", x, y, self.r)
end



local ball1 = random_ball()
local ball2 = aimed_ball()

Objects = {
    ball1,
    ball2,
}


local function grad_change()
    if love.keyboard.isDown("d") then
        for _, obj in ipairs(Objects) do
            if obj.aimed then obj.grad = obj.grad + math.pi / 90 end
        end
    end

    if love.keyboard.isDown("a") then
        for _, obj in ipairs(Objects) do
            if obj.aimed then obj.grad = obj.grad - math.pi / 90 end
        end
    end
end
local function veocity_change()
    if love.keyboard.isDown("w") then
        for _, obj in ipairs(Objects) do
            if obj.aimed and obj.v <= obj.maxv - 15 then
                obj.v = obj.v + 15
                obj.ind = obj.ind + 15/obj.maxv
             end
        end
    end

    if love.keyboard.isDown("s") then
        for _, obj in ipairs(Objects) do
            if obj.aimed and obj.v >= 15 then
                obj.v = obj.v - 15
                obj.ind = obj.ind - 15/obj.maxv
             end
        end
    end
end

local function key_scan()
    grad_change()  
    veocity_change()
end

local function timer(dt)
    if timer_on then
        elapsed_time = elapsed_time + dt
        if elapsed_time >= time_frame then
            set_new_ball_for_aim()
            timer_on = false
            elapsed_time = 0
        end
    end
end

function love.update(dt)
    for _, obj in ipairs(Objects) do
        obj:update(dt)
    end

    key_scan()
    timer(dt)
end

function love.draw()
    for _, obj in ipairs(Objects) do
        obj:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if scancode == "space" then
        for _, obj in ipairs(Objects) do
            if obj.aimed then obj:throw() end
        end
    end
    if scancode == "escape" then love.event.quit() end
end