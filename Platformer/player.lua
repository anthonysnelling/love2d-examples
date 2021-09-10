player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 400
player.animation = animations.idle
player.isMoving = false
player.direction = 1
player.grounded = true
player.dead = false

function playerUpdate(dt)
       -- check if the player is on the ground
    if player.body  then
      local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
      if #colliders > 0 then
         player.grounded = true
      else
         player.grounded = false
      end

      player.isMoving = false
       local px, py = player:getPosition()

    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
       player:setX(px + (player.speed * dt)) 
       player.isMoving = true
       player.direction = 1
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
       player:setX(px - (player.speed * dt)) 
       player.isMoving = true
       player.direction = -1
    end

    if player:enter('Danger') then
      player.dead = true
       player:destroy()
    end
   end

if player.grounded then
    if player.isMoving == true then
       player.animation = animations.run      
    elseif player.isMoving == false then 
       player.animation = animations.idle
    end 
   else 
      player.animation = animations.jump
   end
    player.animation:update(dt)
end
 
function drawPlayer()
   if player.dead == false then
       local px,py = player:getPosition()
      -- multiply scale by player.direction to scale
      player.animation:draw(sprites.playerSheet,px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
   end
end