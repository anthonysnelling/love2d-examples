function love.load()
   -- make the random number generation based on time to keep things more random
   math.randomseed(os.time())

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

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime
    score = 0
end

function love.update(dt)

    -- movement of our player, multiplied by dt (Delta time) to help keep consistent movement across framerates
    if  love.keyboard.isDown('d') and player.x < love.graphics.getWidth() then
        player.x = player.x + player.speed * dt
    end
    if  love.keyboard.isDown('a') and player.x > 0 then
        player.x = player.x - player.speed * dt
    end
    if  love.keyboard.isDown('w') and player.y > 0  then
        player.y = player.y - player.speed * dt
    end
    if  love.keyboard.isDown('s')and player.y < love.graphics.getHeight() then
        player.y = player.y + player.speed * dt
    end
    
    -- directs zombies towards the player, uses cos/sin on the angle to find the direction needed to move in
    for index, zombos in ipairs(zombies) do
        zombos.x = zombos.x + (math.cos(ZombiePlayerAngle(zombos)) * zombos.speed * dt)
        zombos.y = zombos.y + (math.sin(ZombiePlayerAngle(zombos)) * zombos.speed * dt)

        -- makes it so that when zombies hit the player they dissapear also resets game
        if distanceBetween(zombos.x, zombos.y, player.x, player.y) < 30 then
            for index, zombos in ipairs(zombies) do
               zombies[index] = nil 
               gameState = 1
               player.x = love.graphics.getWidth() /2
               player.y = love.graphics.getHeight() /2
            end
        end
    end

    for index, bullet in ipairs(bullets) do
       bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
       bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end

    -- #TableName returns the number of elements in a table
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
           table.remove(bullets, i) 
        end
    end

   --  test the distance between a zombie and bullet and kills the bullet and zombie
    for i, z in ipairs(zombies) do
        for j, b in ipairs(bullets) do
          if distanceBetween(z.x,z.y,b.x,b.y) < 20 then
            z.dead = true 
            b.dead = true
            score = score + 1
          end 
        end  
    end

   --  removes zombies if they are dead
    for i = #zombies, 1, -1 do
         local z = zombies[i] 
         if z.dead == true then
            table.remove(zombies,i)
         end
    end

   --  removes bullets if they are dead
    for i = #bullets, 1, -1 do
         local b = bullets[i] 
         if b.dead == true then
            table.remove(bullets,i)
         end
    end


    if gameState == 2 then
       timer = timer - dt
       if timer <= 0 then
          spawnZombie()
          timer = maxTime
          maxTime = 0.95 * maxTime
       end
    end

end

function love.draw()
   -- draws background
   love.graphics.draw(sprites.background, 0, 0) 

   if gameState == 1 then
      love.graphics.setFont(myFont)
      love.graphics.printf("Click Anywhere to begin!", 0, 50, love.graphics.getWidth(),'center') 
   end

   love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), 'center')
    -- adjusted the pivot point with getWidth and getHeight used nil to ignore the scaling
   love.graphics.draw(sprites.player, player.x, player.y, PlayerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

   for index, zombo in ipairs(zombies) do
      love.graphics.draw(sprites.zombie, zombo.x, zombo.y, ZombiePlayerAngle(zombo), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2) 
   end

   for index, bullet in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, bullet.x, bullet.y, nil, 0.5, nil, sprites.bullet:getWidth(), sprites.bullet:getWidth())
   end
end

function love.keypressed(key)
   if key == "space" then
      spawnZombie() 
   end 
end

function love.mousepressed(x,y,button)
   if button == 1 and gameState ==2 then
      spawnBullet() 
   elseif button == 1 and gameState == 1 then
      gameState = 2
      maxTime = 2
      timer = maxTime
      score = 0
   end
end

function PlayerMouseAngle()
    -- atan2 used to find the angle from player to mouse
      return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function spawnZombie()
    local zombie = {}

   zombie.x = 0
   zombie.y = 0 
   zombie.speed = 140
   zombie.dead = false
    
   -- determines the side of the screen a zombie should spawn
   local side = math.random(1,4)
  
   -- for left side spawns
   if side == 1 then
      zombie.x = -30;
      zombie.y = math.random(0, love.graphics.getHeight())
   end

   -- for right side spawns
   if side == 2 then
      zombie.x = love.graphics.getWidth() + 30;
      zombie.y = math.random(0, love.graphics.getHeight())
   end

   -- for Top side spawns
   if side == 3 then
      zombie.x = math.random(0, love.graphics.getWidth());
      zombie.y = -30
   end

   -- for Bottom side spawns
   if side == 4 then
      zombie.x = math.random(0, love.graphics.getWidth());
      zombie.y = love.graphics.getHeight() + 30
   end


   table.insert(zombies, zombie)

end

function ZombiePlayerAngle(enemy)
       -- uses atan2 (arc tangent) to find the angle between a player and zombie
      return math.atan2(player.y - enemy.y, player.x - enemy.x ) 
end

function spawnBullet()
   local bullet = {}
   bullet.x = player.x
   bullet.y = player.y
   bullet.speed = 500
   bullet.direction = PlayerMouseAngle() 
   bullet.dead = false
   table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
    -- using the distance formula
   return math.sqrt((x2 - x1)^2 + (y2 - y1)^2) 
end