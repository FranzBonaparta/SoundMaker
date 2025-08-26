local Object = require("libs.classic")
local Button=require("button")
local Knob = Object:extend()

function Knob:new(x, y, r, name)
  self.x = x
  self.y = y
  self.radius=r
  self.minusButton=Button(x-r-1,y,r+1,r+2)
  self.addButton=Button(x,y,r+1,r+2)
  self.minValue = 0
  self.maxValue = 0
  self.value = 0
  self.name = name
  self.coolDown = 0
  self:initializeButtons()
end
function Knob:initializeButtons()
  self.minusButton:setImmediate()
  self.minusButton:setText("-")
  self.minusButton:setBackgroundColor(125,125,125)
  self.addButton:setText("+")
  self.addButton:setImmediate()
  self.addButton:setBackgroundColor(125,125,125)
end
function Knob:setLimits(min, max)
  self.minValue = min
  self.maxValue = max
  self.value = self.minValue+math.floor((self.maxValue-self.minValue)/2)
  self.addButton:setOnClick(function()self.value=math.min(self.maxValue,self.value+1) end)
  self.minusButton:setOnClick(function()self.value=math.max(self.minValue,self.value-1) end)

end

function Knob:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.name, self.x - self.radius, self.y - self.radius - 20)

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(0.85, 0.85, 0.85)
  love.graphics.circle("line", self.x, self.y, self.radius)
  local font=love.graphics.getFont()
  local textHeight,textWidth=font:getHeight(),font:getWidth(self.value)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.value,self.x-(textWidth/2),self.y-(textHeight))
  self.addButton:draw()
  self.minusButton:draw()
end

function Knob:update(dt)

end
function Knob:mousepressed(mx,my,button)
  self.addButton:mousepressed(mx,my,button)
  self.minusButton:mousepressed(mx,my,button)
end
return Knob
