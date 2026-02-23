-- Trashball Game Configuration


function love.conf(t)
    t.identity = "trashball"
    t.version = "11.5"
    t.console = false
    t.externalstorage = false

    t.window.title = "Trashball"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.vsync = 1
end
