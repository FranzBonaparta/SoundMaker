local Object = require("libs.classic")
local ScrollBar = require("FileExplorer.ScrollBar")
local PartitionVizualizer=Object:extend()

function PartitionVizualizer:new()
      self.lines = {}
    self.visibleLines = {}
      self.x = 0
    self.y = 20
    self.width = 600
    self.height = 600
    self.offset = 20
    self.scrollBar = ScrollBar()
    self.hidden = false
    self.cursorState = "arrow"
end

return PartitionVizualizer