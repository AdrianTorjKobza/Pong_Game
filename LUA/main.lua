-- Load push.lua library
push = require 'push'

-- Impot the class (Paddle.lua, Ball.lua)
Class = require 'class'
require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1440
WINDOW_HEIGHT = 900
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 320

-- Set paddle speed to 400 px/second
PADDLE_SPEED = 400

-- Initialiaze game
function love.load()
    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 10)
    scoreFont = love.graphics.newFont('font.ttf', 14)

    sounds = {
        ['ball_hit'] = love.audio.newSource('ball.wav', 'static'),
        ['ball_scored'] = love.audio.newSource('goal.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false

    })

    player1Score = 0
    player2Score = 0

    winningPlayer = 0

    -- Initiate the ball and paddles objects
    ball = Ball(VIRTUAL_WIDTH / 2 - 4, VIRTUAL_HEIGHT / 2 - 4, 8, 8)
    paddle1 = Paddle(5, 20, 8, 48)
    paddle2 = Paddle(VIRTUAL_WIDTH - 13, VIRTUAL_HEIGHT - 68, 8, 48)

    gameState = 'pause'
end

-- Update elements on the screen
function love.update(dt)
    if gameState == 'play' then
        ball:update(dt)
    end

    if ball.x <= 0 then
        player2Score = player2Score + 1
        ball:reset()

        sounds['ball_scored']:play()

        if player2Score == 10 then
            gameState = 'victory'
            winningPlayer = 2
        end
    end

    if ball.x >= VIRTUAL_WIDTH - 8  then
        player1Score = player1Score + 1
        ball:reset()

        sounds['ball_scored']:play()

        if player1Score == 10 then
            gameState = 'victory'
            winningPlayer = 1
        end
    end


    if ball:collides(paddle1) then
        -- Deflect the ball to the right and sliglthly increase the speed
        ball.dx = -ball.dx * 1.03
        sounds['ball_hit']:play()
    end

    if ball:collides(paddle2) then
        -- Deflect the ball to the left and sliglthly increase the speed
        ball.dx = -ball.dx * 1.03
        sounds['ball_hit']:play()
    end

    if ball.y <= 0 then
        -- Deflect the ball down
        ball.dy = -ball.dy
        ball.y = 0
    end

    if ball.y >= VIRTUAL_HEIGHT - 8 then
        -- Deflect the ball up
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 8
    end

    paddle1:update(dt)
    paddle2:update(dt)

    -- Move paddles up / down when keys are pressed 
    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end
end

-- Draw on the screen
function love.draw()
    push:apply('start')

    -- set the backroung color
    love.graphics.clear(15 / 255, 17 / 255, 26 / 255)

    -- Draw the title and score
    love.graphics.setFont(smallFont)

    if gameState == 'pause' or gameState == 'victory' then
        love.graphics.printf("PRESS ENTER", 0, 3, VIRTUAL_WIDTH,'center')
    end
    
    if gameState == 'victory' then
        -- Draw victory message 
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 50, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'play' then
        love.graphics.printf("PONG GAME", 0, 3, VIRTUAL_WIDTH,'center')
    end

    love.graphics.setFont(scoreFont)

    love.graphics.print(player1Score, VIRTUAL_WIDTH / 3, 0)
    love.graphics.print(player2Score, VIRTUAL_WIDTH/ 2 + 75, 0)

    -- Draw the ball and the paddles
    ball:render()
    paddle1:render()
    paddle2:render()

    push:apply('end')                  
end

-- Press Enter key to start / restart game and Escape key to exit game
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'pause' then
            gameState = 'play'
        elseif gameState == 'victory' then
            player1Score = 0
            player2Score = 0
            gameState = 'play'
            ball:reset()
        elseif gameState == 'play' then
            gameState = 'pause'
            ball:reset()
        end
    end
end