local ItemManager = require("Managers.itemManager")
local PartitionManager = ItemManager:extend()
local FileManager = require("Data.fileManager")
local NoteButton=require("UI.noteButton")

function PartitionManager:new()
  ItemManager.new(self)
  ItemManager.initButtons(self, { self.save, self.load })
  ItemManager.initVizualizer(self, "partitions")
  self.input:setText("Entrez le nom de la partition: ")
  self.input.inputField:setType("alphanumeric")
end

function PartitionManager:update(dt, piano)
  ItemManager.update(self, dt)
  if self.input:consumeValidation() then
    print("Sauvegarde déclenchée :", self.input.name)

    FileManager.savePartition(self.input.name, piano)
    self.input.name = ""
    self.coolDown = 1
    return
  end
end

function PartitionManager:draw()
  ItemManager.draw(self)
end

function PartitionManager:mousepressed(mx, my, button, piano, state)
  ItemManager.mousepressed(self, mx, my, button)
  if self.fileVizualizer:isVisible() then
    local name = self.fileVizualizer:mousepressed(mx, my, button)
    if name then
      local chunk = FileManager.loadPartition(name)
      piano.partition = {}
      piano.partitionButtons={{}}
      for i, value in ipairs(chunk) do
        piano:updatePartition(value,value.duration)
        --[[table.insert(piano.partition, { note = value.note, duration = value.duration })
        table.insert(piano.partitionButtons, NoteButton(i,tostring(value.name),value.duration,value.note,i))]]
      end
      self.fileVizualizer.hidden = true
      return self.fileVizualizer.hidden
    end
  elseif not self.fileVizualizer:isVisible() and not self.input:isVisible() then
    if state == "piano" then
      self.save:mousepressed(mx, my, button)
      if self.load:isHovered(mx, my) then
        self:showLoader()
        self.load:mousepressed(mx, my, button)
      end
    end 
  end
  return self.fileVizualizer.hidden
end

function PartitionManager:keypressed(key)
  ItemManager.keypressed(self, key)
end

function PartitionManager:wheelmoved(mx, my)
  ItemManager.wheelmoved(self, mx, my)
end

return PartitionManager
