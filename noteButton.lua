local Object=require("libs.classic")
local Button=require("UI.button")
local NoteButton=Object:extend()

function NoteButton:new(x,y,text,duration, note,index)
  self.index=index
    self.x=x*50
self.y=y
  --self.mainButton=Button(newX,y,50,30,text)
  self.text=text
  self.decreaseDuration=Button(self.x,self.y+30,25,20,"-")
  self.addDuration=Button(self.x+25,self.y+30,25,20,"+")
  self.note=note
  self.duration=duration
  self.playedTime=0
  self.timer=0
  self.backgroundColor={200,200,200}
  self:setBackgroundColor()
  self:initButtons()
  --self.mainButton:setTextColor({255,255,255})
end
function NoteButton:initButtons()
  self.addDuration:setOnClick(function()self.duration=self.duration+0.1 end)
  self.decreaseDuration:setOnClick(function()self.duration=math.max(0.1,self.duration-0.1) end)
  self.addDuration:setImmediate()
  self.decreaseDuration:setImmediate()
end
function NoteButton:setBackgroundColor()
  local r,g,b=self.backgroundColor[1],self.backgroundColor[2],self.backgroundColor[3]
  self.addDuration:setBackgroundColor({r,g,b})
  self.decreaseDuration:setBackgroundColor({r,g,b})

end

function NoteButton:draw()
    local r,g,b=self.backgroundColor[1],self.backgroundColor[2],self.backgroundColor[3]
r, g, b = love.math.colorFromBytes(r, g, b)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("fill",self.x,self.y,50,30)
  love.graphics.setColor(0,0,0)
  love.graphics.print(self.text,self.x+10,self.y)
  love.graphics.print(self.duration,self.x+10, self.y+15)
  self.addDuration:draw()
  self.decreaseDuration:draw()
end

function NoteButton:highlight(index)
  if index==self.index then
    self.timer=self.duration
  self.backgroundColor=({255,20,20})
  end
end

function NoteButton:update(dt)

self.timer=math.max(0,self.timer-dt)
self.backgroundColor[1]=self.timer==0 and 200 or 255
self.backgroundColor[2]=self.timer==0 and 200 or 0
self.backgroundColor[3]=self.timer==0 and 200 or 0
--self.mainButton.backgroundColor[4]=self.timer==0 and 0 or 0
end

function NoteButton:mousepressed(mx,my,button)
  self.addDuration:mousepressed(mx,my,button)
  self.decreaseDuration:mousepressed(mx,my,button)
end
return NoteButton