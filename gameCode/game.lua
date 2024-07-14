-- game.lua

local player = require("player")
local projectiles = require("projectiles")
local background = require("background")

local game = {}

function game.checkGameOver()
    -- Esta função pode ser usada para verificações adicionais de game over se necessário
end

function game.drawStartScreen()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Pressione Enter para Começar", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function game.drawGame()
    -- Desenhar fundo
    background.draw()

    -- Desenhar jogadores
    player.drawPlayers()

    -- Desenhar projéteis
    projectiles.draw()

    -- Desenhar HUD
    game.drawHUD()
end

function game.drawGameOverScreen()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Over! " .. winner .. " Wins!", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    love.graphics.printf("Pressione Enter para Jogar Novamente", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
end

function game.drawHUD()
    love.graphics.setColor(1, 1, 1)

    -- Desenhar corações do Player 1
    for i = 1, player1.maxHealth do
        local heart = i <= player1.health and heart_full or heart_empty
        love.graphics.draw(heart, 10 + (i - 1) * 40, 10)
    end

    -- Desenhar corações do Player 2, alinhados à direita
    local screenWidth = love.graphics.getWidth()
    local heartWidth = heart_full:getWidth()
    local totalHeartWidth = player2.maxHealth * heartWidth
    local startX = screenWidth - totalHeartWidth - 10

    for i = 1, player2.maxHealth do
        local heart = i <= player2.health and heart_full or heart_empty
        love.graphics.draw(heart, startX + (i - 1) * 40, 10)
    end
end

return game