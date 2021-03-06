-- gd50 from Harvard University
-- author: @tiocadu

-- instead of using a package manager, i'm going with local dependences
-- https://github.com/Ulydev/push/blob/master/push.lua
push = require 'libs/push'

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'libs/class'

require 'Paddle'
require 'Ball'
require 'Game'

DEBUG = false

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- setting virtual window. We'll use it with push to make it look more retro
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

BALL_ACCELERATION = 1.1

sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
}

function love.load()
    love.window.setTitle('Hello Pong!')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- setting RNG for the game
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('assets/font.ttf', 8)
    mediumFont = love.graphics.newFont('assets/font.ttf', 16)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initial Paddles
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)

    -- initial ball position
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)

    -- game state
    game = Game()
end

-- input controll
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        game:updateState()
    end
end

function love.update(dt)
    -- player1 controls
    if love.keyboard.isDown('w') then
        player1:moveUp()
    elseif love.keyboard.isDown('s') then
        player1:moveDown()
    else
        player1:stop()
    end

    -- player2 controls
    if love.keyboard.isDown('up') then
        player2:moveUp()
    elseif love.keyboard.isDown('down') then
        player2:moveDown()
    else
        player2:stop()
    end

    -- ball movement
    if game.state == GAME_STATE.SERVE then
        ball:reset()

        if game.servingPlayer == 1 then
            ball.dx = 100
        elseif game.servingPlayer == 2 then
            ball.dx = -100
        end
    elseif game.state == GAME_STATE.PLAY then
        if ball:collides(player1) then
            ball.dx = -ball.dx * BALL_ACCELERATION
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * BALL_ACCELERATION
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- detect upper and lower boundaries
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        -- update score state
        if ball.x <= 0 then
            game:updatePlayer2Score()
            sounds['score']:play()
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            game:updatePlayer1Score()
            sounds['score']:play()
        end

        ball:update(dt)

        if game:checkWinner() then
            game:setWinner()
        end
    end

    -- update paddles
    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')

    -- setting bakcground color to gray
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    -- displayCentralLine()

    -- display game name
    game:render()

    -- display paddles - right and left
    player1:render()
    player2:render()

    -- display ball
    ball:render()

    -- debug
    if DEBUG == true then
        displayFPS()
    end

    push:apply('end')
end

function displayCentralLine()
    for i = 0, VIRTUAL_HEIGHT, 16 do
        love.graphics.line(VIRTUAL_WIDTH/2, i, VIRTUAL_WIDTH/2, i + 4)
    end
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print('ball x: ' .. tostring(math.floor(ball.x)), 10, 20)
    love.graphics.print('ball dx: ' .. tostring(math.floor(ball.dx)), 10, 30)
end

function love.resize(w, h)
    push:resize(w, h)
end
