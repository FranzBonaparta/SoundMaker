local Object = require("libs.classic")
local HarmonicEditor = Object:extend()
local Knob = require("UI.knob")
local Button = require("UI.button")
local InputField = require("inputField")
function HarmonicEditor:new(x, y, instrumentsAmount)
  self.x = x
  self.y = y
  self.indexChosen = 0
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
    table.insert(self.shapesButtons, btn)
  end
  self.shapesButtons[1].onClick()
end

function HarmonicEditor:initializeAddButtons()
  local btn = Button(self.x + 200, self.y + (90), 40, 20)
  btn:setImmediate()
  btn:setText("add")
  btn:setBackgroundColor(125, 125, 125)
  btn:setOnClick(function()
    self:addHarmonic()
  end)
  table.insert(self.addButtons, btn)
end

function HarmonicEditor:initializeFields(index)
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

--[[Forme d’onde	harmonicFactors	harmonicAmplitudes
Sinusoïdale 1.0 1.0
Carré	Impairs seulement (1,3,5…)	1/n (ex: 1, 1/3, 1/5…)
Triangle	Impairs (1,3,5…)	1/n² (ex: 1, 1/9, 1/25…)
Dent de scie	Tous (1,2,3,...)	1/n (mais signes alternés si besoin)
Bruitage	Aléatoire ou bruit blanc	Amplitudes variables, ou sans harmonique claire
]]
function HarmonicEditor:addHarmonic()
  local limit = 10
  local tableFactors = self.factors[self.indexChosen]
  local tableAmplitude = self.amplitudes[self.indexChosen]
  --put the limit to 10 harmonics!
  local size = #tableFactors
  if size <= limit then
    if self.shapes[self.indexChosen] ~= "sine" then
      local lastFactor = tableFactors[size]
      local amplitudeField = InputField("float")
      local factorField = InputField("float")
      local diffX, diffY = self.x + 90, self.y + 90
      factorField:setCoords(self.x, diffY + (size * 20), 50)
      amplitudeField:setCoords(diffX, diffY + (size * 20), 50)


      if self.shapes[self.indexChosen] == "square" then
        table.insert(tableFactors, lastFactor + 2)
        table.insert(tableAmplitude, 1 / (lastFactor + 2))
      elseif self.shapes[self.indexChosen] == "triangle" then
        table.insert(tableFactors, lastFactor + 2)
        table.insert(tableAmplitude, 1 / ((lastFactor + 2) ^ 2))
      elseif self.shapes[self.indexChosen] == "saw" then
        table.insert(tableFactors, lastFactor + 1)
        table.insert(tableAmplitude, (1 / (lastFactor + 1)) * ((-1) ^ lastFactor))
      end
      factorField:setPlaceholder(tableFactors[size])
      amplitudeField:setPlaceholder(string.format("%.3f", tableAmplitude[size]))

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
  for i, btn in ipairs(self.addButtons) do
    if self.shapes[i] ~= "sine" and self.shapes[i] ~= "noise" then
      btn:draw()
    end
  end
end

function HarmonicEditor:mousepressed(mx, my, button)
  self.attackKnob:mousepressed(mx, my, button)
  self.decayKnob:mousepressed(mx, my, button)
  for _, btn in ipairs(self.shapesButtons) do
    btn:mousepressed(mx, my, button)
  end
  for _, btn in ipairs(self.addButtons) do
    btn:mousepressed(mx, my, button)
  end
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
  for _, field in ipairs(self.factorsFields) do
    field:update(dt)
  end
  for _, field in ipairs(self.amplitudesFields) do
    field:update(dt)
  end
end

function HarmonicEditor:keypressed(key)
  for _, field in ipairs(self.factorsFields) do
    field:keypressed(key)
  end
  for _, field in ipairs(self.amplitudesFields) do
    field:keypressed(key)
  end
end

return HarmonicEditor
