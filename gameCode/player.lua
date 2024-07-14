local anim8 = require 'anim8'
local Animation = require 'animation'

local player = {}

local spriteSheetPathsRight = {
    'sprites/character1right.png',
    'sprites/character2right.png',
    'sprites/character3right.png',
    'sprites/character4right.png',
    'sprites/character5right.png'
}

local spriteSheetPathsLeft = {
    'sprites/character1left.png',
    'sprites/character2left.png',
    'sprites/character3left.png',
    'sprites/character4left.png',
    'sprites/character5left.png'
}

local animations = {}

local gameOver = false
local showWinnerScreen = false
local gameOverTimer = 0
local gameOverDuration = 5 -- 5 segundos
local winner = nil

function player.setCharacters(char1, char2, spawnProjectileCallback)
    print("Configurar personagens: " .. char1 .. ", " .. char2)
    print("Imagem à direita para char1: " .. spriteSheetPathsRight[char1])
    print("Imagem à esquerda para char1: " .. spriteSheetPathsLeft[char1])
    print("Imagem à direita para char2: " .. spriteSheetPathsRight[char2])
    print("Imagem à esquerda para char2: " .. spriteSheetPathsLeft[char2])

    animations[1] = Animation.new(spriteSheetPathsRight[char1], spriteSheetPathsLeft[char1], 64, 66)
    animations[2] = Animation.new(spriteSheetPathsRight[char2], spriteSheetPathsLeft[char2], 64, 66)
    player.initPlayers(spawnProjectileCallback)
end

function player.initPlayers(spawnProjectileCallback)
    player.spawnProjectile = spawnProjectileCallback

    -- Inicializando vida dos jogadores
    local initialHealth = 5  -- Vida inicial dos jogadores
    local minHealthForProjectile = 1  -- Vida mínima necessária para usar o ataque com projétil

    -- Criar jogadores com parâmetros simples
    player1 = player.createPlayer(200, 600, initialHealth, {left = "a", right = "d", up = "w", attack = "5", secondaryAttack = "i", projectile = "i", dash = "6"}, {0, 0, 1}, minHealthForProjectile, animations[1])
    player2 = player.createPlayer(1300, 600, initialHealth, {left = "left", right = "right", up = "up", attack = ",", secondaryAttack = "o", projectile = "o", dash = "."}, {1, 0, 0}, minHealthForProjectile, animations[2])
end

function player.createPlayer(x, y, health, controls, headColor, minHealthForProjectile, animation)
    return {
        x = x,
        y = y,
        width = 50,  -- Ajuste o valor de largura do jogador
        height = 66,  -- Ajuste o valor de altura do jogador
        speed = 250,
        jumpHeight = -500,
        gravity = -900,
        ground = y,
        y_velocity = 100,
        isGrounded = true,
        isAttacking = false,
        attackDuration = 0.2,
        attackTimer = 0,
        attackCooldown = 2,  -- Tempo de recarga do ataque
        cooldownTimer = 0,
        secondaryAttackCooldown = 3,  -- Cooldown do ataque secundário
        secondaryAttackTimer = 0,
        projectileCooldown = 5,  -- Cooldown do ataque com projétil
        projectileTimer = 0,
        dashDistance = 270,  -- Distância do dash
        dashSpeed = 600,  -- Velocidade do dash
        dashCooldown = 3,  -- Cooldown do dash
        dashTimer = 0,
        isDashing = false,
        dashDirection = 0,
        dashTimerDuration = 0,  -- Duração do dash
        dashInvincible = false,
        dashInvincibleDuration = 0.1,  -- Duração da invencibilidade do dash
        direction = "right",
        controls = controls,
        attackRange = 40,  -- Definindo o alcance do ataque
        primaryAttackDamage = 1,  -- Dano do ataque primário
        secondaryAttackDamage = 2,  -- Dano do ataque secundário
        headColor = headColor,  -- Cor da cabeça
        maxHealth = health,  -- Vida máxima
        health = health,  -- Vida atual
        knockbackDistance = 300,  -- Distância de afastamento após um hit
        knockbackSpeed = 600,  -- Velocidade do knockback
        isKnockedBack = false,  -- Indica se o jogador está em knockback
        knockbackTimer = 0,  -- Temporizador do knockback
        knockbackDirection = 0,  -- Direção do knockback
        minHealthForProjectile = minHealthForProjectile,  -- Vida mínima necessária para usar o ataque com projétil
        animation = animation,
        state = 'idle'
    }
end

function player.update(dt)
    if showWinnerScreen then
        return
    end

    if gameOver then
        gameOverTimer = gameOverTimer + dt
        if gameOverTimer >= gameOverDuration then
            showWinnerScreen = true
        else
            -- Manter as animações de vitória e derrota indefinidamente
            player1.state = player1.state == 'win' and 'win' or 'lose'
            player2.state = player2.state == 'win' and 'win' or 'lose'
        end
        player1.animation:play(player1.state)
        player1.animation:update(dt)
        player2.animation:play(player2.state)
        player2.animation:update(dt)
    else
        player.updatePlayer(player1, dt, player2)
        player.updatePlayer(player2, dt, player1)
    end
end

function player.updatePlayer(p, dt, opponent)
    if gameOver then
        -- Atualizar as animações de vitória e derrota
        p.animation:play(p.state)
        p.animation:update(dt)
    else
        -- Atualizar o cooldown do ataque
        if p.cooldownTimer > 0 then
            p.cooldownTimer = p.cooldownTimer - dt
        end

        -- Atualizar o cooldown do ataque secundário
        if p.secondaryAttackTimer > 0 then
            p.secondaryAttackTimer = p.secondaryAttackTimer - dt
        end

        -- Atualizar o cooldown do dash
        if p.dashTimer > 0 then
            p.dashTimer = p.dashTimer - dt
        end

        -- Atualizar o temporizador do knockback
        if p.knockbackTimer > 0 then
            p.knockbackTimer = p.knockbackTimer - dt
            p.x = p.x + p.knockbackDirection * p.knockbackSpeed * dt
            if p.knockbackTimer <= 0 then
                p.isKnockedBack = false
            end
        end

        -- Verificar dash
        if love.keyboard.isDown(p.controls.dash) and p.dashTimer <= 0 then
            p.isDashing = true
            p.dashTimer = p.dashCooldown
            p.dashTimerDuration = p.dashDistance / p.dashSpeed
            p.dashDirection = p.direction == "right" and 1 or -1
            p.state = 'dash'
        end

        -- Atualizar animação de dash
        if p.isDashing then
            local dashMove = p.dashDirection * p.dashSpeed * dt
            if not player.checkCollision(p, dashMove, 0, opponent) then
                p.x = p.x + dashMove
            end
            p.dashTimerDuration = p.dashTimerDuration - dt
            if p.dashTimerDuration <= 0 then
                p.isDashing = false
            end
        end

        -- Verificar ataque primário
        if love.keyboard.isDown(p.controls.attack) and not p.isAttacking and p.cooldownTimer <= 0 then
            p.isAttacking = true
            p.attackTimer = 1  -- Duração da animação de ataque primário (1 segundo)
            p.cooldownTimer = p.attackCooldown  -- Reinicia o cooldown
            p.state = 'primaryAttack'
        end

        -- Atualizar o temporizador de ataque primário
        if p.isAttacking then
            p.attackTimer = p.attackTimer - dt
            if p.attackTimer <= 0 then
                p.isAttacking = false
                if not p.isSecondaryAttacking then
                    p.state = p.isGrounded and 'idle' or 'jump'
                end
            end
        end

        -- Verificar ataque secundário (projétil)
        if love.keyboard.isDown(p.controls.secondaryAttack) and not p.isSecondaryAttacking and p.secondaryAttackTimer <= 0 and p.health <= p.minHealthForProjectile then
            p.isSecondaryAttacking = true
            p.secondaryAttackTimer = 1  -- Duração da animação de ataque secundário (1 segundo)
            p.secondaryAttackCooldown = p.secondaryAttackCooldown
            player.spawnProjectile(p)
            p.state = 'secondaryAttack'
        end

        -- Atualizar o temporizador de ataque secundário
        if p.isSecondaryAttacking then
            p.secondaryAttackTimer = p.secondaryAttackTimer - dt
            if p.secondaryAttackTimer <= 0 then
                p.isSecondaryAttacking = false
                if not p.isAttacking then
                    p.state = p.isGrounded and 'idle' or 'jump'
                end
            end
        end

        -- Movimentação, pulo e knockback
        if not p.isDashing and not p.isKnockedBack then
            local moveX = 0

            -- Movimentação para a esquerda
            if love.keyboard.isDown(p.controls.left) then
                moveX = -p.speed * dt
                p.direction = "left"
                p.animation:setDirection("left")
            elseif love.keyboard.isDown(p.controls.right) then
                moveX = p.speed * dt
                p.direction = "right"
                p.animation:setDirection("right")
            end

            -- Aplicar o movimento apenas se não houver colisão
            if not player.checkCollision(p, moveX, 0, opponent) then
                p.x = p.x + moveX
            end

            -- Atualizar o estado de movimento
            if moveX ~= 0 and not p.isAttacking and not p.isSecondaryAttacking then
                p.state = 'move'
            elseif not p.isAttacking and not p.isSecondaryAttacking and p.isGrounded then
                p.state = 'idle'
            end

            -- Pulo
            if love.keyboard.isDown(p.controls.up) and p.isGrounded then
                p.y_velocity = p.jumpHeight
                p.isGrounded = false
                p.state = 'jump'
            end
            
            -- Aplicando gravidade
            if not p.isGrounded then
                p.y = p.y + p.y_velocity * dt
                p.y_velocity = p.y_velocity - p.gravity * dt
                if not p.isAttacking and not p.isSecondaryAttacking then
                    p.state = 'jump'
                end
            end

            -- Verificação se o personagem está no chão
            if p.y >= p.ground then
                p.y = p.ground
                p.y_velocity = 0
                p.isGrounded = true
                if not p.isAttacking and not p.isSecondaryAttacking and moveX == 0 then
                    p.state = 'idle'
                end
            end

            -- Limitar movimento às bordas da janela
            if p.x < 0 then
                p.x = 0
            elseif p.x + p.width > love.graphics.getWidth() then
                p.x = love.graphics.getWidth() - p.width
            end
        end

        -- Checar se o ataque atinge o oponente
        if p.isAttacking and player.checkAttackHit(p, opponent) then
            if not opponent.isTakingDamage then
                opponent.health = opponent.health - p.primaryAttackDamage
                opponent.isTakingDamage = true
                opponent.damageTimer = 1 -- Duração do take damage
                opponent.state = 'takeDamage'
                -- Verificar se o oponente perdeu
                if opponent.health <= 0 then
                    opponent.health = 0
                    gameOver = true
                    winner = p == player1 and "Player 1" or "Player 2"
                    p.state = 'win'
                    opponent.state = 'lose'
                else
                    -- Aplicar knockback ao acertar o oponente
                    opponent.isKnockedBack = true
                    opponent.knockbackTimer = p.knockbackDistance / p.knockbackSpeed
                    opponent.knockbackDirection = p.direction == "right" and 1 or -1
                end
            end
        end

        -- Atualizar animação de dano
        if opponent.isTakingDamage then
            opponent.damageTimer = opponent.damageTimer - dt
            if opponent.damageTimer <= 0 then
                opponent.isTakingDamage = false
                opponent.state = opponent.isGrounded and 'idle' or 'jump'
            end
        end

        -- Tocar a animação do player e do oponente
        p.animation:play(p.state)
        p.animation:update(dt)
        opponent.animation:play(opponent.state)
        opponent.animation:update(dt)
    end
end

function player.drawPlayers()
    if showWinnerScreen then
        player.drawWinnerScreen()
    elseif gameOver then
        player.drawVictoryDefeatAnimations()
    else
        player.drawPlayer(player1)
        player.drawPlayer(player2)
    end
end

function player.drawPlayer(p)
    p.animation:draw(p.x, p.y)
end

function player.drawVictoryDefeatAnimations()
    player1.animation:draw(player1.x, player1.y)
    player2.animation:draw(player2.x, player2.y)
end

function player.drawWinnerScreen()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(winner .. " venceu!!!", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2)
end

-- Checar colisão para movimentação
function player.checkCollision(p, moveX, moveY, opponent)
    -- Verifique se os retângulos dos jogadores se sobrepõem
    return not (p.x + moveX + p.width < opponent.x or
                p.x + moveX > opponent.x + opponent.width or
                p.y + moveY + p.height < opponent.y or
                p.y + moveY > opponent.y + opponent.height)
end

-- Checar se o ataque atinge o oponente
function player.checkAttackHit(attacker, opponent)
    -- Verifique se o retângulo de ataque do atacante colide com o retângulo do oponente
    local attackX = attacker.direction == "right" and attacker.x + attacker.width or attacker.x - attacker.attackRange
    return not (attackX + attacker.attackRange < opponent.x or
                attackX > opponent.x + opponent.width or
                attacker.y + attacker.height < opponent.y or
                attacker.y > opponent.y + opponent.height)
end

return player
