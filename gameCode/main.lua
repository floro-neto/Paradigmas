-- main.lua

-- Importar módulos
local player = require("player")
local projectiles = require("projectiles")
local game = require("game")
local background = require("background")
local menu = require("menu")

function love.load()
    -- Configurações iniciais
    love.window.setTitle("RoadFighters")
    love.window.setMode(1540, 800, {fullscreen = false, resizable = true})

    -- Carregar imagem de fundo
    background.load("assets/background3.jpg")

    -- Carregar imagens de corações
    heart_full = love.graphics.newImage("assets/heart_full.png")
    heart_empty = love.graphics.newImage("assets/heart_empty.png")

    -- Inicializando os jogadores
    player.initPlayers(projectiles.spawn)

    -- Inicializando projéteis
    projectiles.init(player1, player2)

    -- Carregar menu
    menu.load()

    -- Estados do jogo
    gameState = "start"  -- "start", "playing", "gameover", "menu"
    winner = nil

    print("Jogo carregado. Pressione Enter para começar.")
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)
    elseif gameState == "playing" then
        player.update(dt)
        projectiles.update(dt)
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "start" then
        game.drawStartScreen()
    elseif gameState == "playing" then
        game.drawGame()
    elseif gameState == "gameover" then
        game.drawGameOverScreen()
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        menu.keypressed(key)
    elseif key == "return" and gameState == "start" then
        gameState = "menu"
        print("Estado do jogo: Menu de seleção de personagens")
    elseif key == "return" and gameState == "gameover" then
        gameState = "start"
        player.initPlayers(projectiles.spawn)
        projectiles.init(player1, player2)
        print("Estado do jogo: Start")
    end
end

function startGame(char1, char2)
    print("Personagens selecionados para o jogo: " .. char1 .. ", " .. char2)
    player.setCharacters(char1, char2, projectiles.spawn)  -- Passando a função projectiles.spawn para player.setCharacters
    gameState = "playing"
    print("Jogo iniciado com personagens: " .. char1 .. " e " .. char2)
end