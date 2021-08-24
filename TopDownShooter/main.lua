function love.load()
    sprites = {}
    --loading sprites
    sprites.background = love.graphics.newImage("sprites/background.png")
    sprites.bullet = love.graphics.newImage("sprites/bullet.png")
    sprites.player = love.graphics.newImage("sprites/player.png")
    sprites.zombie = love.graphics.newImage("sprites/zombie.png")
    
    -- player table to track player data 
    player = {}
    -- position
    player.x = love.graphics.getWidth()/2
    player.y = love.graphics.getHeight()/2
    --properties
    player.speed = 180


    zombies = {}
end

function love.update(dt)

    -- movement of our player, multiplied by dt (Delta time) to help keep consistent movement across framerates
    if  love.keyboard.isDown('d') then
        player.x = player.x + player.speed * dt
    end
    if  love.keyboard.isDown('a') then
        player.x = player.x - player.speed * dt
    end
    if  love.keyboard.isDown('w') then
        player.y = player.y - player.speed * dt
    end
    if  love.keyboard.isDown('s') then
        player.y = player.y + player.speed * dt
    end
    
    -- directs zombies towards the player uses cos sin to on the angle to find the direction needed to move in
    for index, zombos in ipairs(zombies) do
        zombos.x = zombos.x + (math.cos(ZombiePlayerAngle(zombos)) * zombos.speed * dt)
        zombos.y = zombos.y + (math.sin(ZombiePlayerAngle(zombos)) * zombos.speed * dt)

        -- makes it so that when zombies hit the player they dissapear
        if distanceBetween(zombos.x, zombos.y, player.x, player.y) < 30 then
            for index, zombos in ipairs(zombies) do
               zombies[index] = nil 
            end
        end
    end

end

function love.draw()
   love.graphics.draw(sprites.background, 0, 0) 

    -- adjusted the pivot point with getWidth and getHeight used nil to ignore the scaling
   love.graphics.draw(sprites.player, player.x, player.y, PlayerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

   for index, zombo in ipairs(zombies) do
      love.graphics.draw(sprites.zombie, zombo.x, zombo.y, ZombiePlayerAngle(zombo), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2) 
   end
end

function love.keypressed(key)
   if key == "space" then
      spawnZombie() 
   end 
end

function PlayerMouseAngle()
    -- atan2 used to find the angle from player to mouse
      return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function spawnZombie()
    local zombie = {}
   zombie.x = math.random(0, love.graphics.getWidth())
   zombie.y = math.random(0, love.graphics.getHeight()) 
   zombie.speed = 140
   table.insert(zombies, zombie)
end

function ZombiePlayerAngle(enemy)
       -- uses atan2 (arc tangent) to find the angle between a player and zombie
      return math.atan2(player.y - enemy.y, player.x - enemy.x ) 
end


function distanceBetween(x1, y1, x2, y2)
    -- using the distance formula
   return math.sqrt((x2 - x1)^2 + (y2 - y1)^2) 
end