local box = require("pixelbox_lite").new(term.current())

local path = ...
if not path then error("Usage: bimg-player <file.bimg>") end

local file, err = fs.open(shell.resolve(path), "rb")
if not file then error("Could not open file: " .. err) end

local img = textutils.unserialize(file.readAll())
file.close()

local function drawFrame(frame)
    for y, row in ipairs(frame) do
        -- Each row contains blit-style data: text, foreground colors, and background colors
        local text, fgColors, bgColors = table.unpack(row)
        for x = 1, #text do
            -- Extract the color index for foreground and background
            local fgColorIndex = tonumber(fgColors:sub(x, x), 16) or 0
            local bgColorIndex = tonumber(bgColors:sub(x, x), 16) or 0
            
            -- Use foreground color for the pixel
            local color = 2 ^ fgColorIndex
            box.canvas[x][y] = color
        end
    end
    box:render()
end

if img.multiMonitor then
    term.clear()
    term.setCursorPos(1, 1)
    print("Multi-monitor images are not supported with this API.")
else
    for _, frame in ipairs(img) do
        drawFrame(frame)
        if img.animation then
            sleep(frame.duration or img.secondsPerFrame or 0.05)
        else
            read() -- Wait for user input to display the next frame
            break
        end
    end

    -- Reset terminal to default state after rendering
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end
