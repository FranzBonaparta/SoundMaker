-- SoundMaker
-- Made by Jojopov
-- Licence : GNU GPL v3 - 2025
-- https://www.gnu.org/licenses/gpl-3.0.html
local SimpleMusicPlayer = require("engine.simpleMusicPlayer")
local player = SimpleMusicPlayer()
local UI=require("UI.ui")
local ui=UI()

-- Function called only once at the beginning
function love.load()

    -- Initialization of resources (images, sounds, variables)
    player:playIntro()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
end

-- Function called at each frame, it updates the logic of the app
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
    player:update(dt)
    ui:update(dt)
end

-- Function called after each update to draw on screen
function love.draw()
    -- Everything that needs to be displayed passes here
    love.graphics.setColor(1, 1, 1) -- blanc
    ui:draw()
end

function love.mousepressed(mx, my, button)
    ui:mousepressed(mx, my, button)
end
function love.mousereleased(mx, my, button)
    ui:mousereleased(mx, my, button)
end
-- Function called at each touch
function love.keypressed(key)
    -- Example: exit the game with Escape
    if key == "escape" then
        love.event.quit()
    end
    ui:keypressed(key,player)

    
end
