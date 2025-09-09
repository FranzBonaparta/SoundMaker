local Object = require("libs.classic")
local UI = Object:extend()
local PianoViewer = require("UI.pianoViewer")
local HarmonicEditor = require("UI.harmonicEditor")
local Button = require("UI.button")
local InstrumentPanel = require("Managers.instrumentPanel")
local PartitionManager = require("Managers.partitionManager")
--local FrequencySlider=require("UI.frequencySlider")
function UI:new(player)
  self.piano = PianoViewer(50, 100)
  self.harmonicEditor = HarmonicEditor(50, 100)
  self.player = player
  self.instruments = {}
  self.instrumentIndex = 0
  self:setInstrumentsButtons()
  self.state = "piano"
  self.stateButton = nil
  self:initializeStateButton()
  self.partitionExplorer = PartitionManager()
  self.instrumentExplorer = InstrumentPanel()
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
        self:initializeEditor(instrument)
        print("instr index modified " .. self.instrumentIndex)
      end
    end)
    instrument:setBackgroundColor(125, 125, 125)
    table.insert(self.instruments, i, instrument)
  end
  --choose default 1 instrument
  if self.instruments[1] then
    self.instruments[1].onClick()
  end
end

function UI:initializeEditor(instrument)
  self.harmonicEditor.indexChosen = instrument.index
  self.harmonicEditor.attackKnob.value = self.harmonicEditor.attacks[instrument.index]
  self.harmonicEditor.decayKnob.value = self.harmonicEditor.decays[instrument.index]
  self.harmonicEditor:initializeFields(instrument.index)
  self.harmonicEditor:initializeAddButtons()
  self.harmonicEditor:initializeShapesButtons()
end

function UI:update(dt)
  self.partitionExplorer:update(dt, self.piano)
  self.instrumentExplorer:update(dt,self.harmonicEditor)
  if self.state == "piano" and self.partitionExplorer.canPlay then
    --highlight notes played on reading partition -> see simpleMusicPlayer:update
    self.piano:update(dt)
  else
    self.harmonicEditor:update(dt)
  end
end

function UI:draw()
  love.graphics.setColor(1, 1, 1)
  if self.state == "piano" then
    self.piano:draw()
    for _, instr in ipairs(self.instruments) do
      instr:draw()
    end
  else
    self.harmonicEditor:draw(self.instrumentIndex)
  end
  self.stateButton:draw()
  self.partitionExplorer:draw()
  self.instrumentExplorer:draw()
end

function UI:mousepressed(mx, my, button)
  local bool = self.partitionExplorer:mousepressed(mx, my, button, self.piano, self.state)
  if bool and self.partitionExplorer.canPlay then
    if self.state == "piano" then
      local instrument = self.harmonicEditor
      self.piano:mousepressed(mx, my, button, instrument)
      for _, instr in ipairs(self.instruments) do
        if button == 1 and instr:isHovered(mx, my) then
          instr:mousepressed(mx, my, button)
        elseif button == 2 and instr:isHovered(mx, my) then
          self:initializeEditor(instr)
          self.stateButton.onClick()
        end
      end
    else
      self.instrumentExplorer:mousepressed(mx,my,button,self.harmonicEditor,self.state)
      self.harmonicEditor:mousepressed(mx, my, button)
    end
    self.stateButton:mousepressed(mx, my, button)
  end
end

function UI:mousereleased(mx, my, button)
  if self.state == "piano" then
    self.piano:mousereleased(mx, my, button)
  end
end

function UI:keypressed(key, player)
  local bool = self.partitionExplorer:keypressed(key)
  local bool2 = self.instrumentExplorer:keypressed(key)
  --test if no one explorer is opened
  if not bool and not bool2  
  and self.partitionExplorer.canPlay 
  and self.instrumentExplorer.canPlay then
    if self.state == "piano" then
      player:keypressed(key)
      if key == "tab" and #self.piano.partitionVizualizer.partition > 0 then
        self.piano.partitionVizualizer:playPartition(player, self.harmonicEditor)
      end
      if key == "delete" then
        self.piano.partitionVizualizer.partition = {}
        self.piano.partitionVizualizer.partitionButtons={{}}
        self.piano.partitionVizualizer.visibleLines={}
      end
      if key == "backspace" then
        if #self.piano.partitionVizualizer.partition >= 1 then
          table.remove(self.piano.partitionVizualizer.partition, #self.piano.partitionVizualizer.partition)
          local lastPartitionTable=self.piano.partitionVizualizer.partitionButtons[#self.piano.partitionVizualizer.partitionButtons]

          if #lastPartitionTable>1 then

            table.remove(lastPartitionTable,#lastPartitionTable)
          else

            table.remove(self.piano.partitionVizualizer.partitionButtons,#self.piano.partitionVizualizer.partitionButtons)
            table.remove(self.piano.partitionVizualizer.visibleLines,#self.piano.partitionVizualizer.visibleLines)
          end

        end
      end
    elseif self.state == "harmonic" then
      self.harmonicEditor:keypressed(key)
    end
  end
end

function UI:wheelmoved(mx, my)
  self.partitionExplorer:wheelmoved(mx, my)
  self.instrumentExplorer:wheelmoved(mx,my)
end

return UI
