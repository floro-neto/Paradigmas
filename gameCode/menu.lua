-- menu.lua

local Menu = {}
local selectedCharacter1 = 1
local selectedCharacter2 = 1
local characters = {1, 2, 3, 4, 5}
local playerTurn = 1

function Menu.load()
    -- Carregar qualquer recurso necessário para o menu
end

function Menu.update(dt)
    -- Atualizar lógica do menu se necessário
end

function Menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Player " .. playerTurn .. " Selecione seu Personagem:", 0, love.graphics.getHeight() / 2 - 60, love.graphics.getWidth(), "center")
    for i, char in ipairs(characters) do
        local y = love.graphics.getHeight() / 2 - 30 + (i - 1) * 30
        love.graphics.printf("Personagem " .. char, 0, y, love.graphics.getWidth(), "center")
        if (playerTurn == 1 and i == selectedCharacter1) or (playerTurn == 2 and i == selectedCharacter2) then
            love.graphics.printf(">", love.graphics.getWidth() / 2 - 60, y, love.graphics.getWidth(), "left")
        end
    end
end

function Menu.keypressed(key)
    if key == 'down' then
        if playerTurn == 1 then
            selectedCharacter1 = math.min(selectedCharacter1 + 1, #characters)
        else
            selectedCharacter2 = math.min(selectedCharacter2 + 1, #characters)
        end
    elseif key == 'up' then
        if playerTurn == 1 then
            selectedCharacter1 = math.max(selectedCharacter1 - 1, 1)
        else
            selectedCharacter2 = math.max(selectedCharacter2 - 1, 1)
        end
    elseif key == 'return' then
        if playerTurn == 1 then
            playerTurn = 2
        else
            startGame(characters[selectedCharacter1], characters[selectedCharacter2])
        end
    end
end

return Menu