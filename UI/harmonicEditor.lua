local Object = require("libs.classic")
local HarmonicEditor = Object:extend()
local Knob = require("UI.knob")
local Button=require("UI.button")

function HarmonicEditor:new(x,y,instrumentsAmount)
  self.x=x
  self.y=y
  self.indexChosen=0
  self.size = instrumentsAmount or 10
  self.attacks = {}
  self.decays = {}
  self.attackKnob = Knob(400, 120, 20, "attack")
  self.decayKnob = Knob(460, 120, 20, "decay")
  self.attackKnob:setLimits(-20, -1)
  self.decayKnob:setLimits(-20, -1)
  self.factors = {}
  self.amplitudes = {}
  self.shapesButtons={}
  self.shapes={} --sine/square/triangle/saw/noise
  self:initializeInstruments()
  self:initializeShapesButtons()
  self.addButtons={}
  self:initializeAddButtons()
end

function HarmonicEditor:initializeInstruments()
  --initialize a default sineWave for all instruments
  for i=1, self.size do
    self.attacks[i]=-3
    self.decays[i]=-15
    self.shapes[i]="sine"
    self.factors[i] = {}
    self.amplitudes[i] = {}
    table.insert(self.factors[i],1)
    table.insert(self.amplitudes[i],1)
  end
end

function HarmonicEditor:initializeShapesButtons()
  local shapes={"sine","square", "triangle", "saw", "noise"}
  for i=1, #shapes do
    local btn=Button(300+(i*70), 150,60,20)
    btn:setImmediate()
    btn:setText(shapes[i])
    btn:setBackgroundColor(125,125,125)
    btn:setOnClick(function() 
      if self.shapes[self.indexChosen]~= shapes[i] then
        self.shapes[self.indexChosen]= shapes[i]
        for _, b in ipairs(self.shapesButtons) do
      b:setBackgroundColor(125, 125, 125)
    end
        btn:setBackgroundColor(125,0,0)
      end
    end)
    table.insert(self.shapesButtons, btn)
  end
  self.shapesButtons[1].onClick()
end

function HarmonicEditor:initializeAddButtons()

 
    local btn=Button(self.x+200, self.y+(90),40,20)
    btn:setImmediate()
    btn:setText("add")
    btn:setBackgroundColor(125,125,125)
    btn:setOnClick(function()self:addHarmonic()
    end)
    table.insert(self.addButtons,btn)
  
end
--[[Forme d’onde	harmonicFactors	harmonicAmplitudes
Sinusoïdale 1.0 1.0
Carré	Impairs seulement (1,3,5…)	1/n (ex: 1, 1/3, 1/5…)
Triangle	Impairs (1,3,5…)	1/n² (ex: 1, 1/9, 1/25…)
Dent de scie	Tous (1,2,3,...)	1/n (mais signes alternés si besoin)
Bruitage	Aléatoire ou bruit blanc	Amplitudes variables, ou sans harmonique claire
]]
function HarmonicEditor:addHarmonic()
  local limit=10
  local tableFactors=self.factors[self.indexChosen]
  local tableAmplitude=self.amplitudes[self.indexChosen]
  --put the limit to 10 harmonics!
  local size=#tableFactors
  if size < limit then
    local lastFactor=tableFactors[size]
    if self.shapes[self.indexChosen]=="square" then
      table.insert(tableFactors,lastFactor+2)
      table.insert(tableAmplitude,1/(lastFactor+2))
    elseif self.shapes[self.indexChosen]=="triangle"   then
            table.insert(tableFactors,lastFactor+2)
      table.insert(tableAmplitude,1/((lastFactor+2)^2))

    elseif self.shapes[self.indexChosen]=="saw"  then
      table.insert(tableFactors,lastFactor+1)
      table.insert(tableAmplitude,(1/(lastFactor+1))*(-1^lastFactor))
    end
  end
end
function HarmonicEditor:draw(index)
  if self.size>= index then
    local text=string.format("attack: [%d]\n\ndecay: [%d]\n\nshape: [%s]",
  self.attacks[index], self.decays[index], self.shapes[index])
    love.graphics.print(text,self.x,self.y)
    local diffX, diffY=self.x+90,self.y+90
    love.graphics.print("factors", self.x, diffY)
    love.graphics.print("amplitudes", diffX, diffY)
    for i, value in ipairs(self.factors[index]) do
      love.graphics.print(value,self.x, diffY+(i*20))
    end
    for i, value in ipairs(self.amplitudes[index]) do
      love.graphics.print(value,diffX, diffY+(i*20))
    end
  end
  self.attackKnob:draw()
  self.decayKnob:draw()
  for _, btn in ipairs(self.shapesButtons) do
    btn:draw()
  end
  for i, btn in ipairs(self.addButtons) do
    if self.shapes[i]~="sine" then
      btn:draw()
    end
    
  end
end

function HarmonicEditor:mousepressed(mx,my,button)
  self.attackKnob:mousepressed(mx, my, button)
  self.decayKnob:mousepressed(mx, my, button)
  for _, btn in ipairs(self.shapesButtons) do
    btn:mousepressed(mx,my,button)
  end
  for _, btn in ipairs(self.addButtons) do
    btn:mousepressed(mx,my,button)
  end
end

function HarmonicEditor:update(dt)
  if self.attackKnob.value ~= self.attacks[self.indexChosen] then
    self.attacks[self.indexChosen]=self.attackKnob.value
  end
  if self.decayKnob.value ~= self.decays[self.indexChosen] then
    self.decays[self.indexChosen]=self.decayKnob.value
  end

end

return HarmonicEditor
