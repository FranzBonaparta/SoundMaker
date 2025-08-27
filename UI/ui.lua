local Object = require("libs.classic")
local UI = Object:extend()
local PianoViewer = require("UI.pianoViewer")
local HarmonicEditor = require("UI.harmonicEditor")
local Button = require("UI.button")

--local FrequencySlider=require("UI.frequencySlider")
function UI:new()
  self.piano = PianoViewer(50, 100)
  self.harmonicEditor = HarmonicEditor(50, 100)
  self.instruments = {}
  self.instrumentIndex = 0
  self:setInstrumentsButtons()
  self.state = "piano"
  self.stateButton = nil
  self:initializeStateButton()
end

function UI:initializeStateButton()
  self.stateButton = Button(1400, 700, 70, 40, "edit Harmonic")
  self.stateButton:setImmediate()
  self.stateButton:setOnClick(function()
    self.state = self.state == "piano" and "harmonic" or "piano"
    if self.state == "piano" then
      self.stateButton:setText("edit Harmonic")
    else
      self.stateButton:setText("go to piano")
    end
  end)
  self.stateButton:setBackgroundColor(125, 125, 125)
end

function UI:setInstrumentsButtons()
  for i = 1, self.harmonicEditor.size do
    local x = 1400 + (((i + 1) % 2) * 40) + 20
    local y = 400 + (math.floor((i - 1) / 2) * 50)
    local instrument = Button(x, y, 35, 40, "instr " .. i)
    instrument:setIndex(i)
    instrument:setImmediate()
    instrument:setOnClick(function()
      instrument:setBackgroundColor(125, 0, 0)
      if self.instrumentIndex ~= instrument.index then
        if self.instruments[self.instrumentIndex] then
          self.instruments[self.instrumentIndex]:setBackgroundColor(125, 125, 125)
        end

        self.instrumentIndex = instrument.index
        print("instr index modified " .. self.instrumentIndex)
      end
    end)
    instrument:setBackgroundColor(125, 125, 125)
    self.instruments[i] = instrument
  end
end

function UI:update(dt)
  if self.state == "piano" then
    self.piano:update(dt)
  else
    self.harmonicEditor:update(dt)
  end
end

function UI:draw()
  if self.state == "piano" then
    self.piano:draw()
    for _, instr in ipairs(self.instruments) do
      instr:draw()
    end
  else
    self.harmonicEditor:draw(self.instrumentIndex)
  end
  self.stateButton:draw()
end

function UI:mousepressed(mx, my, button)
  if self.state == "piano" then
    self.piano:mousepressed(mx, my, button)
    for _, instr in ipairs(self.instruments) do
      instr:mousepressed(mx, my, button)
      if button == 2 and instr:isHovered(mx, my) then
        self.harmonicEditor.indexChosen = instr.index
        self.harmonicEditor.attackKnob.value = self.harmonicEditor.attacks[instr.index]
        self.harmonicEditor.decayKnob.value = self.harmonicEditor.decays[instr.index]

        self.stateButton.onClick()
      end
    end
  else
    self.harmonicEditor:mousepressed(mx, my, button)
  end
  self.stateButton:mousepressed(mx, my, button)
end

function UI:mousereleased(mx, my, button)
  if self.state == "piano" then
    self.piano:mousereleased(mx, my, button)
  end
end

function UI:keypressed(key, player)
  if self.state == "piano" then
    if key == "tab" and #self.piano.partition > 0 then
      self.piano:playPartition(player)
    end
    if key == "backspace" then
      self.piano.partition = {}
      self.piano.partitionText = "Partition jouée\n"
    end
  end
end

return UI
