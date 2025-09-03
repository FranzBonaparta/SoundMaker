local Object = require("libs.classic")
local UI = Object:extend()
local PianoViewer = require("UI.pianoViewer")
local HarmonicEditor = require("UI.harmonicEditor")
local Button = require("UI.button")
local FileManager = require("fileManager")
local FileVizualizer = require("FileExplorer.FileVizualizer")
local InputName = require("libs.inputName")
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
  self.save = Button(1400, 650, 40, 40, "save")
  self.load = Button(1450, 650, 40, 40, "load")
  self.fileVizualizer = FileVizualizer("SoundMaker", "partitions")
  --self.partitionExplorer = FileVizualizer("SoundMaker", "partitions")
--self.instrumentExplorer = FileVizualizer("SoundMaker", "instruments")
  self.fileVizualizer:init()
  self.fileVizualizer.hidden = true
  --self.partitionExplorer.hidden = not self.showingPartitions
--self.instrumentExplorer.hidden = self.showingPartitions
  self:initButtons({ self.load, self.save })
  self.input = InputName(50, 50, 400, 200)
  self.input:setText("Entrez le nom de la partition: ")
  self.canPlay = true
  self.coolDown = 0
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

function UI:initButtons(buttons)
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
    print("saving...")
    self.canPlay = false
    self.input:show()
    --FileManager.saveSprite(name, grid, self.palette)
  end)
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
  if self.fileVizualizer:isVisible() then
    self.fileVizualizer:update()
    self.coolDown = 1
    return
  end
  self.input:update(dt)
  if self.input:consumeValidation() then
    print("Sauvegarde déclenchée :", self.input.name)

    FileManager.savePartition(self.input.name, self.piano)
    self.input.name = ""
    self.coolDown = 1
    return
  end
  if not self.fileVizualizer:isVisible() and not self.input:isVisible() then
    self.coolDown = math.max(0, self.coolDown - dt)
    if self.coolDown <= 0 then
      self.canPlay = true
    end
  end
  if self.state == "piano" and self.canPlay then
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

function UI:saveFile()
  self.save.onClick()
end

function UI:showLoader()
  self.canPlay = false
  --self.load.onClick()
end

function UI:mousepressed(mx, my, button)
--[[  if button==1 and #self.piano.partition >0 then
    local lastNote=self.piano.partition[#self.piano.partition]
    print(lastNote.note, lastNote.duration)
  end]]
  self.input:mousepressed(mx, my, button)
  if self.fileVizualizer:isVisible() then
    local name = self.fileVizualizer:mousepressed(mx, my, button)
    if name then
      local chunk=FileManager.loadPartition(name)
      self.piano:initText()
      self.piano.partition={}
      for i, value in ipairs(chunk) do
  table.insert(self.piano.partition, { note = value.note, duration = value.duration })
  table.insert(self.piano.partitionText,tostring(value.name))
      end
        self.piano:updateText()

      self.fileVizualizer.hidden = true
      return
    end
  elseif not self.fileVizualizer:isVisible() and not self.input:isVisible() then
    if self.state == "piano" then
       self.save:mousepressed(mx, my, button)
    if self.load:isHovered(mx, my) then
      self:showLoader()
      self.load:mousepressed(mx,my, button)
    end
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
  if self.input:isVisible() then
    self.input:keypressed(key)
  else
    if self.state == "piano" then
      player:keypressed(key)
      if key == "tab" and #self.piano.partition > 0 then
        self.piano:playPartition(player, self.harmonicEditor)
      end
      if key == "delete" then
        self.piano.partition = {}
        self.piano.partitionText = { "Partition jouée:\n" }
        self.piano:updateText()
      end
      if key == "backspace" then
        if #self.piano.partition >= 1 then
          table.remove(self.piano.partition, #self.piano.partition)
          table.remove(self.piano.partitionText, #self.piano.partitionText)
          self.piano:updateText()
        end
      end
    elseif self.state == "harmonic" then
      self.harmonicEditor:keypressed(key)
    end
  end
end

function UI:wheelmoved(mx,my)
  self.fileVizualizer:wheelmoved(mx,my)
end
return UI
