local ItemManager = require("Managers.itemManager")
local InstrumentPanel = ItemManager:extend()
local FileManager = require("Data.fileManager")

function InstrumentPanel:new()
  ItemManager.new(self)
  ItemManager.initButtons(self, { self.save, self.load })
  ItemManager.initVizualizer(self, "instruments")
  self.input:setText("Entrez le nom de l'instrument': ")
  self.input.inputField:setType("alphanumeric")

end

function InstrumentPanel:update(dt,harmonicEditor)
  ItemManager.update(self, dt)
  if self.input:consumeValidation() then
    print("Sauvegarde déclenchée :", self.input.name)

    FileManager.saveInstrument(self.input.name, harmonicEditor,harmonicEditor.indexChosen)
    self.input.name = ""
    self.coolDown = 1
    return
  end
end

function InstrumentPanel:draw()
  ItemManager.draw(self)
end

function InstrumentPanel:mousepressed(mx, my, button,harmonicEditor, state)
  ItemManager.mousepressed(self, mx, my, button)
  if self.fileVizualizer:isVisible() then
    local name = self.fileVizualizer:mousepressed(mx, my, button)
    if name then
      local shape, attack, decay, factors, amplitudes = FileManager.loadInstrument(name)
      harmonicEditor.attacks[harmonicEditor.indexChosen] = attack
    harmonicEditor.attackKnob.value = attack
    harmonicEditor.decays[harmonicEditor.indexChosen] = decay
    harmonicEditor.decayKnob.value = decay
    for _, btn in ipairs(harmonicEditor.shapesButtons) do
      if btn.text == shape then
        btn.onClick()
        break
      end
    end
      harmonicEditor.shapes[harmonicEditor.indexChosen] = shape
      harmonicEditor.attacks[harmonicEditor.indexChosen] = attack
      harmonicEditor.attackKnob.value = attack
      harmonicEditor.decays[harmonicEditor.indexChosen] = decay
      harmonicEditor.decayKnob.value = decay
      harmonicEditor.factors[harmonicEditor.indexChosen] = factors
      harmonicEditor.amplitudes[harmonicEditor.indexChosen] = amplitudes

    harmonicEditor:initializeFields(harmonicEditor.indexChosen)

      self.fileVizualizer.hidden = true
      return self.fileVizualizer.hidden
    end
  elseif not self.fileVizualizer:isVisible() and not self.input:isVisible() then
    if state == "harmonic" then
      self.save:mousepressed(mx, my, button)
      if self.load:isHovered(mx, my) then
        self:showLoader()
        self.load:mousepressed(mx, my, button)
      end
    end
  end
  return self.fileVizualizer.hidden

end

function InstrumentPanel:keypressed(key)
  ItemManager.keypressed(self,key)
end

function InstrumentPanel:wheelmoved(mx,my)
  ItemManager.wheelmoved(self,mx,my)
end

return InstrumentPanel
