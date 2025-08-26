local Object=require("libs.classic")
local UI=Object:extend()
local Knob=require("UI.knob")
local PianoViewer=require("UI.pianoViewer")
--local FrequencySlider=require("UI.frequencySlider")
function UI:new()
  self.piano=PianoViewer(50,100)
  self.attack=Knob(1430,100,20,"attack")
  self.decay=Knob(1430,180,20,"decay")
  self.attack:setLimits(-20,-1)
  self.decay:setLimits(-20,-1)
end

function UI:update(dt)
  self.piano:update(dt)
  self.attack:update(dt)
  self.decay:update(dt)
end

function UI:draw()
  self.piano:draw()
  self.attack:draw()
  self.decay:draw()
end

function UI:mousepressed(mx,my,button)
  self.piano:mousepressed(mx,my,button)
  self.attack:mousepressed(mx,my,button)
  self.decay:mousepressed(mx,my,button)
end

function UI:mousereleased(mx,my,button)
  self.piano:mousereleased(mx,my,button)
end

function UI:keypressed(key,player)
      if key == "tab" and #self.piano.partition > 0 then
        self.piano:playPartition(player)
    end
    if key=="backspace" then
        self.piano.partition={}
        self.piano.partitionText="Partition jouée\n"
    end
end

return UI