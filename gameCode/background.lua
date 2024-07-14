-- background.lua

local background = {}

function background.load(imagePath)
    background.image = love.graphics.newImage(imagePath)
    background.updateScale()
end

function background.updateScale()
    background.scaleX = love.graphics.getWidth() / background.image:getWidth()
    background.scaleY = love.graphics.getHeight() / background.image:getHeight()
end

function background.draw()
    love.graphics.draw(background.image, 0, 0, 0, background.scaleX, background.scaleY)
end

return background