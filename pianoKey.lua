local Object = require("libs.classic")
local PianoKey = Object:extend()
local SoundMaker = require("SoundMaker")
local soundMaker = SoundMaker()
local FrequencySlider=require("frequencySlider")
local index = 1

function PianoKey:new(type, x, y, width, height, bool)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.type = type
  self.isIsolated = bool or false
  self.note = {}
  self.index = 0
  self.name = ""
  self.touchTimer = 0
  self.frequencySlider=nil

  if self.type == "white" then
    self.index = index
    index = index + 1
    self.x = self.x + self.width * self.index - 1
  elseif self.type == "black" then
    if self.isIsolated then
      self.x = self.x + (self.width * 1.7)
      self:updateWidth()
    end
  end
end

function PianoKey:setWhiteIndex(id)
  if self.type == "black" then
    self.index = id
    local spacing = self.width
    self.x = self.x + spacing * (self.index + 0.7)
    self:updateWidth()
  end
end

function PianoKey:updateWidth()
  self.width = self.width * 0.6
end
--set frequency name, note & setter
function PianoKey:setName(name)
  self.name = name
  if self.type == "white" then
    self:setNote(soundMaker.WhiteNotes[self.name])
    self.frequencySlider=FrequencySlider(self.x+10,self.y+self.height+100,4,100,self.note)
  elseif self.type == "black" then
    self:setNote(soundMaker.BlackNotes[self.name])
     self.frequencySlider=FrequencySlider(self.x+5,self.y+self.height+100,4,100,self.note)
  end
end

function PianoKey:setNote(note)
  self.note = note
end

function PianoKey:play(duration)
  soundMaker:createSineWave(self.note, duration):play()
  self.touchTimer = duration
end

function PianoKey:mouseIsHover(mx, my)
  local isHover = false
  if mx >= self.x and mx <= self.x + self.width and
      my >= self.y and my <= self.y + self.height then
    isHover = true
  end
  return isHover
end

function PianoKey:draw()
  local color = self.type == "white" and { 210 / 255, 210 / 255, 210 / 255 } or { 0.1, 0.1, 0.1 }
  --draw key
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  if self.touchTimer > 0 then
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end
  --draw borders
  if self.type == "white" then
    love.graphics.setColor(10 / 255, 10 / 255, 10 / 255)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  else
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  end
  --print name of key
  if self.type == "white" then
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.name, self.x + 2, self.y + self.height - 20)
  elseif self.type == "black" then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x + 1, self.y - 20)
  end
  if self.frequencySlider then
    self.frequencySlider:draw()
  end
end
function PianoKey:mousepressed(mx,my,button)
  self.frequencySlider:mousepressed(mx,my,button)
end
function PianoKey:mousereleased(mx,my,button)
  self.frequencySlider:mousereleased(mx,my,button)
end
function PianoKey:update(dt)
  if self.touchTimer > 0 then
    self.touchTimer = math.max(self.touchTimer - dt, 0)
  end
  self.frequencySlider:update(dt)
  self.note=self.note~=self.frequencySlider.modifiedNote and self.frequencySlider.modifiedNote or self.note
end

return PianoKey
