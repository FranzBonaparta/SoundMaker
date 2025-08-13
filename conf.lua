-- Configuration function of Love2D
function love.conf(w)
    w.title = ""
    w.window.height = 800
    w.window.width = 1500
    w.version = "11.4"
    w.console = true
    w.window.icon = nil
    w.window.borderless = false
    w.window.resizable = true
    w.window.minwidth = 1
    w.window.minheight = 1
    w.window.fullscreen = false
    w.window.fullscreentype = "desktop"
    w.window.msaa = 0
    w.window.display = 1

    w.modules.audio = true
    w.modules.data = true
    w.modules.event = true
    w.modules.font = true
    w.modules.graphics = true
    w.modules.image = true
    w.modules.joystick = true
    w.modules.keyboard = true
    w.modules.math = true
    w.modules.mouse = true
    w.modules.physics = true
    w.modules.sound = true
    w.modules.system = true
    w.modules.thread = true
    w.modules.timer = true
    w.modules.touch = true
    w.modules.video = true
    w.modules.window = true
end
