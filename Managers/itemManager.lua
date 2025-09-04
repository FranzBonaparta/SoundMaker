local Object = require("libs.classic")
local ItemManager = Object:extend()
local Button = require("UI.button")
local FileVizualizer = require("FileExplorer.FileVizualizer")
local InputName = require("libs.inputName")

function ItemManager:new()
  self.save = Button(1400, 650, 40, 40, "save")
  self.load = Button(1450, 650, 40, 40, "load")
  self:initButtons({ self.load, self.save })
  self.input = InputName(50, 50, 400, 200)
  self.fileVizualizer = nil
  self.coolDown = 0
  self.canPlay = true
end

function ItemManager:initVizualizer(directory)
  self.fileVizualizer = FileVizualizer("SoundMaker", directory)
  self.fileVizualizer:init()
  self.fileVizualizer.hidden = true
end

function ItemManager:initButtons(buttons)
  for _, button in pairs(buttons) do
    button:setImmediate()
    button:setBackgroundColor(125, 125, 125)
    button:setAngle(5)
  end
  self.load:setOnClick(function()
    self.fileVizualizer:reset()
    self.fileVizualizer.hidden = false
    print("loading...")
  end)
  self.save:setOnClick(function()
    --print("saving...")
    self.canPlay = false
    self.input:show()
  end)
end

function ItemManager:saveFile()
  self.save.onClick()
end

function ItemManager:showLoader(bool)
  bool = false
end

function ItemManager:update(dt)
  if self.fileVizualizer:isVisible() then
    self.fileVizualizer:update()
    self.coolDown = 1
    return
  end
  self.input:update(dt)

  if not self.fileVizualizer:isVisible() and not self.input:isVisible() then
    self.coolDown = math.max(0, self.coolDown - dt)
    if self.coolDown <= 0 then
      self.canPlay = true
    end
  end
end

function ItemManager:draw()
  self.save:draw()
  self.load:draw()
  love.graphics.setColor(1, 1, 1)
  if self.input:isVisible() then
    self.input:draw()
  end
  if self.fileVizualizer:isVisible() then
    self.fileVizualizer:draw()
  end
end

function ItemManager:mousepressed(mx, my, button)
  self.input:mousepressed(mx, my, button)
end

function ItemManager:keypressed(key)
  if self.input:isVisible() then
    self.input:keypressed(key)
    return true
  end
  return false
end

function ItemManager:wheelmoved(mx, my)
  self.fileVizualizer:wheelmoved(mx, my)
end

return ItemManager
