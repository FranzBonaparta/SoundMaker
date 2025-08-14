-- main.lua - entry point of your Love2D project
local SimpleMusicPlayer = require("simpleMusicPlayer")
local player = SimpleMusicPlayer()
local PianoViewer = require("pianoViewer")
local piano = PianoViewer(50, 100)
local FrequencySweep = require("FrequencySweep")

-- Function called only once at the beginning
function love.load()
    -- Initialization of resources (images, sounds, variables)
    player:playIntro()

    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
end

-- Function called at each frame, it updates the logic of the game
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
    player:update(dt)
    piano:update(dt)
end

-- Function called after each update to draw on screen
function love.draw()
    -- Everything that needs to be displayed passes here
    love.graphics.setColor(1, 1, 1) -- blanc
    love.graphics.print("Hello Love2D!", 100, 100)
    piano:draw()
end

function love.mousepressed(mx, my, button)
    piano:mousepressed(mx, my, button)
end

-- Function called at each touch
function love.keypressed(key)
    -- Example: exit the game with Escape
    if key == "escape" then
        love.event.quit()
    end
    if key == "s" then
        local sweep = FrequencySweep.generateSweep(300, 1000, 5, 0.4)
        sweep:play()
    end
    if key == "tab" and #piano.partition > 0 then
        piano:playPartition(player)
    end
    player:keypressed(key)
end
