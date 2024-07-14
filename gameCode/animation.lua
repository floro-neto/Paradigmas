local anim8 = require 'anim8'

local Animation = {}

function Animation.new(spriteSheetPathRight, spriteSheetPathLeft, frameWidth, frameHeight)
    print("Loading images:", spriteSheetPathRight, spriteSheetPathLeft)  -- Debugging
    local imageRight = love.graphics.newImage(spriteSheetPathRight)
    local imageLeft = love.graphics.newImage(spriteSheetPathLeft)
    
    local gridRight = anim8.newGrid(frameWidth, frameHeight, imageRight:getWidth(), imageRight:getHeight())
    local gridLeft = anim8.newGrid(frameWidth, frameHeight, imageLeft:getWidth(), imageLeft:getHeight())

    local animation = {
        animationsRight = {
            dash = anim8.newAnimation(gridRight('1-9', 1), 0.1),
            idle = anim8.newAnimation(gridRight('1-9', 2), 0.1),
            jump = anim8.newAnimation(gridRight('1-9', 3), 0.1),
            lose = anim8.newAnimation(gridRight('1-9', 4), 0.1),
            move = anim8.newAnimation(gridRight('1-9', 5), 0.1),
            primaryAttack = anim8.newAnimation(gridRight('1-9', 6), 0.1, 'pauseAtEnd'),
            secondaryAttack = anim8.newAnimation(gridRight('1-9', 7), 0.1, 'pauseAtEnd'),
            takeDamage = anim8.newAnimation(gridRight('1-9', 8), 0.1, 'pauseAtEnd'),
            win = anim8.newAnimation(gridRight('1-9', 9), 0.1),
        },
    
        animationsLeft = {
            dash = anim8.newAnimation(gridLeft('1-9', 1), 0.1),
            idle = anim8.newAnimation(gridLeft('1-9', 2), 0.1),
            jump = anim8.newAnimation(gridLeft('1-9', 3), 0.1),
            lose = anim8.newAnimation(gridLeft('1-9', 4), 0.1),
            move = anim8.newAnimation(gridLeft('1-9', 5), 0.1),
            primaryAttack = anim8.newAnimation(gridLeft('1-9', 6), 0.1, 'pauseAtEnd'),
            secondaryAttack = anim8.newAnimation(gridLeft('1-9', 7), 0.1, 'pauseAtEnd'),
            takeDamage = anim8.newAnimation(gridLeft('1-9', 8), 0.1, 'pauseAtEnd'),
            win = anim8.newAnimation(gridLeft('1-9', 9), 0.1),
        },
        direction = 'right',
        imageRight = imageRight,
        imageLeft = imageLeft,
        currentState = 'idle'
    }
    
    function animation:setDirection(dir)
        self.direction = dir
    end
    
    function animation:play(state)
        self.currentState = state
    end
    
    function animation:draw(x, y)
        if self.direction == 'right' then
            self.animationsRight[self.currentState]:draw(self.imageRight, x, y)
        else
            self.animationsLeft[self.currentState]:draw(self.imageLeft, x, y)
        end
    end
    
    function animation:update(dt)
        if self.direction == 'right' then
            self.animationsRight[self.currentState]:update(dt)
        else
            self.animationsLeft[self.currentState]:update(dt)
        end
    end

    return animation
end

return Animation