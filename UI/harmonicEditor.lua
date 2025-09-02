local Object = require("libs.classic")
local HarmonicEditor = Object:extend()
local Knob = require("UI.knob")
local Button = require("UI.button")
local InputField = require("inputField")
local FileManager = require("fileManager")

function HarmonicEditor:new(x, y, instrumentsAmount)
  self.x = x
  self.y = y
  self.indexChosen = 1
  self.size = instrumentsAmount or 10
  self.attacks = {}
  self.decays = {}
  self.attackKnob = Knob(400, 120, 20, "attack")
  self.decayKnob = Knob(460, 120, 20, "decay")
  self.attackKnob:setLimits(-20, -1)
  self.decayKnob:setLimits(-20, -1)
  self.factors = {}
  self.amplitudes = {}
  self.shapesButtons = {}
  self.shapes = {} --sine/square/triangle/saw/noise
  self.factorsFields = nil
  self.amplitudesFields = nil
  self:initializeInstruments()
  self:initializeShapesButtons()
  self.addButtons = {}
  self:initializeAddButtons()
  --fields are shared for all instruments
end

function HarmonicEditor:initializeInstruments()
  --initialize a default sineWave for all instruments
  for i = 1, self.size do
    self.attacks[i] = -3
    self.decays[i] = -15
    self.shapes[i] = "sine"
    self.factors[i] = {}
    self.amplitudes[i] = {}
    table.insert(self.factors[i], 1)
    table.insert(self.amplitudes[i], 1)
  end
  self:initializeFields(1)
end

function HarmonicEditor:initializeShapesButtons()
  self.shapesButtons = {}
  local shapes = { "sine", "square", "triangle", "saw", "noise" }
  for i = 1, #shapes do
    local btn = Button(300 + (i * 70), 150, 60, 20)
    btn:setImmediate()
    btn:setText(shapes[i])
    btn:setBackgroundColor(125, 125, 125)
    btn:setOnClick(function()
      if self.shapes[self.indexChosen] ~= shapes[i] then
        self.shapes[self.indexChosen] = shapes[i]
        for _, b in ipairs(self.shapesButtons) do
          b:setBackgroundColor(125, 125, 125)
        end
        btn:setBackgroundColor(125, 0, 0)
      end
    end)
    if btn.text == self.shapes[self.indexChosen] then
      btn:setBackgroundColor(125, 0, 0)
    end
    table.insert(self.shapesButtons, btn)
  end
  --self.shapesButtons[1].onClick()
end

function HarmonicEditor:initializeAddButtons()
  local btn = Button(self.x + 200, self.y + (90), 40, 20)
  btn:setImmediate()
  btn:setText("add")
  btn:setBackgroundColor(125, 125, 125)
  btn:setOnClick(function()
    self:addHarmonic()
  end)
  self.addButtons = btn
end

function HarmonicEditor:initializeFields(index)
  self.factorsFields = {}    -- 🔧 Added
  self.amplitudesFields = {} -- 🔧 Added

  if self.factors[index] then
    self.factorsFields = {}
    self.amplitudesFields = {}
    local diffX, diffY = self.x + 90, self.y + 90
    for i, factor in ipairs(self.factors[index]) do
      --create a new field
      local field = InputField("numeric")
      field:setCoords(self.x, diffY + (i * 20), 50)
      field:setPlaceholder(factor)
      table.insert(self.factorsFields, field)
    end
    for i, amplitude in ipairs(self.amplitudes[index]) do
      --create a new field
      local field = InputField("float")
      field:setCoords(diffX, diffY + (i * 20), 50)
      field:setPlaceholder(tonumber(string.format("%.3f", amplitude)))
      table.insert(self.amplitudesFields, field)
    end
  end
end

--[[Waveform harmonicFactors harmonicAmplitudes
Sine 1.0 1.0
Square Odd only (1, 3, 5…) 1/n (e.g.: 1, 1/3, 1/5…)
Triangle Odd (1, 3, 5…) 1/n² (e.g.: 1, 1/9, 1/25…)
Sawtooth All (1, 2, 3,...) 1/n (but alternating signs if necessary)
Sound Effect Random or white noise Variable amplitudes, or no clear harmonic
]]
function HarmonicEditor:addHarmonic()
  local limit = 10
  local tableFactors = self.factors[self.indexChosen]
  local tableAmplitude = self.amplitudes[self.indexChosen]
  --put the limit to 10 harmonics!
  local size = #tableFactors
  if size <= limit then
    if self.shapes[self.indexChosen] then
      local lastFactor = tableFactors[size]
      local amplitudeField = InputField("float")
      local factorField = InputField("float")
      local diffX, diffY = self.x + 90, self.y + 90
      local newIndex = size + 1
      factorField:setCoords(self.x, diffY + (newIndex * 20), 50)
      amplitudeField:setCoords(diffX, diffY + (newIndex * 20), 50)
      local shapes = { "sine", "square", "triangle", "saw" }
      local newFactors = { lastFactor + 1, lastFactor + 2, lastFactor + 2, lastFactor + 1 }
      local newAmplitudes = { (1 - (0.2 * lastFactor)), 1 / (lastFactor + 2), 1 / ((lastFactor + 2) ^ 2), (1 / (lastFactor + 1)) *
      ((-1) ^ lastFactor) }
      for i = 1, #shapes do
        if self.shapes[self.indexChosen] == shapes[i] then
          table.insert(tableFactors, newFactors[i])
          table.insert(tableAmplitude, newAmplitudes[i])
          break
        end
      end
      factorField:setPlaceholder(tableFactors[newIndex])
      amplitudeField:setPlaceholder(string.format("%.3f", tableAmplitude[newIndex]))

      table.insert(self.amplitudesFields, amplitudeField)
      table.insert(self.factorsFields, factorField)
    end
  end
end

function HarmonicEditor:draw(index)
  if self.size >= index then
    local text = string.format("attack: [%d]\n\ndecay: [%d]\n\nshape: [%s]",
      self.attacks[index], self.decays[index], self.shapes[index])
    love.graphics.print(text, self.x, self.y)
    local diffX, diffY = self.x + 90, self.y + 90
    love.graphics.print("factors", self.x, diffY)
    love.graphics.print("amplitudes", diffX, diffY)
    for _, field in ipairs(self.factorsFields) do
      field:draw()
    end
    for _, field in ipairs(self.amplitudesFields) do
      field:draw()
    end
  end
  self.attackKnob:draw()
  self.decayKnob:draw()
  for _, btn in ipairs(self.shapesButtons) do
    btn:draw()
  end
  --[[  for i, btn in ipairs(self.addButtons) do
    if self.shapes[i] ~= "noise" then
      btn:draw()
    end
  end]]
  self.addButtons:draw()
end

function HarmonicEditor:mousepressed(mx, my, button)
  self.attackKnob:mousepressed(mx, my, button)
  self.decayKnob:mousepressed(mx, my, button)
  for _, btn in ipairs(self.shapesButtons) do
    btn:mousepressed(mx, my, button)
  end
  self.addButtons:mousepressed(mx, my, button)
  for _, field in ipairs(self.factorsFields) do
    field:mousepressed(mx, my, button)
  end
  for _, field in ipairs(self.amplitudesFields) do
    field:mousepressed(mx, my, button)
  end
end

function HarmonicEditor:update(dt)
  if self.attackKnob.value ~= self.attacks[self.indexChosen] then
    self.attacks[self.indexChosen] = self.attackKnob.value
  end
  if self.decayKnob.value ~= self.decays[self.indexChosen] then
    self.decays[self.indexChosen] = self.decayKnob.value
  end
  for i, field in ipairs(self.factorsFields) do
    field:update(dt)
    if field.isValidated and tonumber(field.text) then
      self.factors[self.indexChosen][i] = tonumber(field.text)
      print("factor " .. i .. " set to " .. field.text)
      field.isValidated = false
    end
  end
  for i, field in ipairs(self.amplitudesFields) do
    field:update(dt)
    if field.isValidated and tonumber(field.text) then
      self.amplitudes[self.indexChosen][i] = tonumber(field.text)
      print("amplitude " .. i .. " set to " .. field.text)
      field.isValidated = false
    end
  end
end

function HarmonicEditor:keypressed(key)
  for _, field in ipairs(self.factorsFields) do
    field:keypressed(key)
  end
  for _, field in ipairs(self.amplitudesFields) do
    field:keypressed(key)
  end
  if key == "s" then
    FileManager.saveInstrument("testPiano", self, 1)
  end
  if key == "l" then
    local shape, attack, decay, factors, amplitudes = FileManager.loadInstrument("testPiano")
    self.attacks[self.indexChosen] = attack
    self.attackKnob.value = attack
    self.decays[self.indexChosen] = decay
    self.decayKnob.value = decay
    for i = 1, #factors do
      if i < #factors then
        self:addHarmonic()
      end

      self.factorsFields[i].text = tostring(factors[i])
      self.factorsFields[i].focused = false
      self.factorsFields[i].isValidated = true
      self.amplitudesFields[i].text = tostring(amplitudes[i])
      self.amplitudesFields[i].focused = false
      self.amplitudesFields[i].isValidated = true
    end
    for _, btn in ipairs(self.shapesButtons) do
      print(btn.text, shape)
      if btn.text == shape then
        print("match")
        btn.onClick()
      end
    end

    print("Loaded instrument:", shape, attack, decay, "#factors=" .. #factors, "#amplitudes=" .. #amplitudes)
  end
end

return HarmonicEditor
