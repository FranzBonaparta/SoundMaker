local Object = require("libs.classic")
local UI = Object:extend()
local PianoViewer = require("UI.pianoViewer")
local HarmonicEditor = require("UI.harmonicEditor")
local Button = require("UI.button")

--local FrequencySlider=require("UI.frequencySlider")
function UI:new(player)
  self.piano = PianoViewer(50, 100)
  self.harmonicEditor = HarmonicEditor(50, 100)
  self.player=player
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
        self.harmonicEditor.indexChosen = instrument.index
        
        self.harmonicEditor.attackKnob.value = self.harmonicEditor.attacks[instrument.index]
        self.harmonicEditor.decayKnob.value = self.harmonicEditor.decays[instrument.index]
        self.harmonicEditor:initializeFields(self.instrumentIndex)
        self.harmonicEditor:initializeAddButtons()
        self.harmonicEditor:initializeShapesButtons()
        print("instr index modified " .. self.instrumentIndex)
      end
    end)
    instrument:setBackgroundColor(125, 125, 125)
    table.insert(self.instruments,i, instrument)
  end
  --choose default 1 instrument
  if self.instruments[1] then
    self.instruments[1].onClick()
  end
end

function UI:update(dt)
  if self.state == "piano" then
    --highlight notes played on reading partition -> see simpleMusicPlayer:update
 --[[   self.player:update(dt, function(note, duration)
      self.piano:highlightNote(note, duration)
    end)]]
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
    local instrument = self.harmonicEditor
    self.piano:mousepressed(mx, my, button, instrument)
    for _, instr in ipairs(self.instruments) do
      if button == 1 and instr:isHovered(mx, my) then
        instr:mousepressed(mx, my, button)
      elseif button == 2 and instr:isHovered(mx, my) then
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
    player:keypressed(key)
    if key == "tab" and #self.piano.partition > 0 then
      self.piano:playPartition(player, self.harmonicEditor)
    end
    if key == "delete" then
      self.piano.partition = {}
      self.piano.partitionText = {"Partition jouée:\n"}
      self.piano:updateText()
    end
    if key=="backspace" then
      table.remove(self.piano.partition,#self.piano.partition)
      table.remove(self.piano.partitionText,#self.piano.partitionText)
      self.piano:updateText()
    end
  elseif self.state == "harmonic" then
    self.harmonicEditor:keypressed(key)
  end
end

return UI
