local Object = require("libs.classic")
local Knob = Object:extend()

function Knob:new(x, y, r, name)
  self.x = x
  self.y = y
  self.radius = r
  self.value = 0
  self.name = name
  self.isHover=false
end

function Knob:mouseIsHover(mx, my)
  if mx >= self.x - self.radius and mx <= self.x + self.radius and
      my >= self.y - self.radius and my <= self.y + self.radius  then
    self.isHover = true
      else self.isHover=false
  end
end

function Knob:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.name, self.x - self.radius, self.y - self.radius - 20)
  love.graphics.setColor(1,0,0)
  local text=self.isHover==true and "1" or "0"
  love.graphics.print(text,self.x+self.radius+10,self.y)
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(0.85, 0.85, 0.85)
  love.graphics.circle("line", self.x, self.y, self.radius)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.circle("fill", self.x, self.y, self.radius / 2)
  --[[  love.graphics.setColor(1,1,1)
    love.graphics.circle("line",self.x,self.y,self.radius/2)]]
end
function Knob:update(dt)
  local mx,my=love.mouse.getPosition()
  self:mouseIsHover(mx,my)
end
return Knob
