local projectiles = {}

function projectiles.init(p1, p2)
    projectiles.list = {}
    projectiles.player1 = p1
    projectiles.player2 = p2
end

function projectiles.spawn(player)
    local projectile = {
        x = player.direction == "right" and player.x + player.width or player.x,
        y = player.y + player.height / 2,
        width = 10,
        height = 5,
        speed = player.direction == "right" and 300 or -300,
        damage = player.secondaryAttackDamage,  -- Dano do projétil
        direction = player.direction,
        owner = player  -- Adiciona o campo owner   
    }
    table.insert(projectiles.list, projectile)
end

function projectiles.update(dt)
    for i = #projectiles.list, 1, -1 do
        local projectile = projectiles.list[i]
        projectile.x = projectile.x + projectile.speed * dt

        -- Remover projétil se sair da tela
        if projectile.x < 0 or projectile.x > love.graphics.getWidth() then
            table.remove(projectiles.list, i)
        else
            -- Checar colisão com os jogadores, ignorando o owner
            if projectile.owner ~= projectiles.player1 and projectiles.checkHit(projectile, projectiles.player1) then
                print("Projectile hit player1")  -- Debug
                projectiles.player1.health = projectiles.player1.health - projectile.damage
                print("Player 1 Health: " .. projectiles.player1.health)  -- Debug
                table.remove(projectiles.list, i)
                -- Verificar se o player1 perdeu
                if projectiles.player1.health <= 0 then
                    projectiles.player1.health = 0
                    gameState = "gameover"
                    winner = "Player 2"
                end
            elseif projectile.owner ~= projectiles.player2 and projectiles.checkHit(projectile, projectiles.player2) then
                print("Projectile hit player2")  -- Debug
                projectiles.player2.health = projectiles.player2.health - projectile.damage
                print("Player 2 Health: " .. projectiles.player2.health)  -- Debug
                table.remove(projectiles.list, i)
                -- Verificar se o player2 perdeu
                if projectiles.player2.health <= 0 then
                    projectiles.player2.health = 0
                    gameState = "gameover"
                    winner = "Player 1"
                end
            end
        end
    end
end

function projectiles.checkHit(projectile, player)
    -- Verifique se os retângulos do projétil e do jogador se sobrepõem
    return projectile.x < player.x + player.width and 
           projectile.x + projectile.width > player.x and 
           projectile.y < player.y + player.height and 
           projectile.y + projectile.height > player.y
end

function projectiles.draw()
    for _, projectile in ipairs(projectiles.list) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", projectile.x, projectile.y, projectile.width, projectile.height)
    end
end

return projectiles