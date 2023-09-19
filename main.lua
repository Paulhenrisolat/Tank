-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
  require("lldebugger").start()
end

io.stdout:setvbuf('no') --Debug
love.graphics.setDefaultFilter("nearest") --No blurry pixel

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) 
  return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

-- Returns the angle between two vectors assuming the same origin.
function math.angle(x1,y1, x2,y2) 
  return math.atan2(y2-y1, x2-x1) 
end

local map = require("map")

local Tank = {
  x = 0,
  y = 0,
  rotation = math.rad(-90),
  speed = 80,
  img = love.graphics.newImage("images/tank.png")
}

local TankE = {
  x = 0,
  y = 0,
  rotation = math.rad(-90),
  rotationTarget = 0,
  speed = 50,
  img = love.graphics.newImage("images/tankE.png"),
  width = 0,
  height = 0,
  detectionArea = 150,
  state = nill,
  footstep = 0,
  reloadTime = 0.5,
  life = 10
}

local TankEStates = {}
TankEStates.start = "start"
TankEStates.walk = "walk"
TankEStates.changeDirection = "changeDirection"
TankEStates.chase = "chase"
TankEStates.shoot = "shoot"

local Mouse = {
  x = 0,
  y = 0,
  img = love.graphics.newImage("images/pointer.png")
}

local projectiles = {}
  projectiles.img = love.graphics.newImage("images/projectile.png")
  projectiles.speed = 250

function Input(dt)
  if love.keyboard.isDown("up","z") then    
    local vx = Tank.speed * math.cos(Tank.rotation) * dt
    local vy = Tank.speed * math.sin(Tank.rotation) * dt
    Tank.x = Tank.x + vx
    Tank.y = Tank.y + vy
  end
  if love.keyboard.isDown("down","s") then    
    local vx = Tank.speed * math.cos(Tank.rotation) * dt
    local vy = Tank.speed * math.sin(Tank.rotation) * dt
    Tank.x = Tank.x - vx
    Tank.y = Tank.y - vy
  end
  if love.keyboard.isDown("right","d") then
    Tank.rotation = Tank.rotation + 1 * dt
  end
  if love.keyboard.isDown("left","q") then
    Tank.rotation = Tank.rotation - 1 * dt
  end
end

function love.keypressed(key)
  if key == "space" then
    Shoot(Tank.x, Tank.y, Tank.rotation)
  end
end

function Shoot(px, py, prot)
  local projectile = {}
  projectile.x = px 
  projectile.y = py
  projectile.rotation = prot
  table.insert(projectiles, projectile)
end

function EnnemyState(dt)
  --rotate smoothly
  if TankE.rotation < TankE.rotationTarget then
    TankE.rotation = TankE.rotation + 1 * dt
  elseif TankE.rotation > TankE.rotationTarget then
    TankE.rotation = TankE.rotation - 1 * dt
  end
  --state start
  if TankE.state == TankEStates.start then
    TankE.footstep = math.random(1, 4)
    TankE.state = TankEStates.walk
  end
  --state walk
  if TankE.state == TankEStates.walk then
    TankE.footstep = TankE.footstep - dt
    local vx = TankE.speed * math.cos(TankE.rotation) * dt
    local vy = TankE.speed * math.sin(TankE.rotation) * dt
    TankE.x = TankE.x + vx
    TankE.y = TankE.y + vy

    if TankE.footstep <= 0 then
      TankE.state = TankEStates.changeDirection
    else
      local distance = math.dist(TankE.x, TankE.y, Tank.x, Tank.y)
      if distance < TankE.detectionArea/2 then
        TankE.state = TankEStates.shoot
      elseif distance < TankE.detectionArea then
        TankE.state = TankEStates.chase
      end
    end
  end
  --state rotate
  if TankE.state == TankEStates.changeDirection then
    local rolRandom = love.math.random(1,2)
    if rolRandom == 1 then
      TankE.rotationTarget = TankE.rotationTarget + math.pi/2
    elseif rolRandom == 2 then
      TankE.rotationTarget = TankE.rotationTarget + math.pi/-2
    end
    TankE.state = TankEStates.start
  end
  --state chase
  if TankE.state == TankEStates.chase then
    local rotationTowardTank = math.angle(TankE.x, TankE.y, Tank.x, Tank.y)
    TankE.rotation = rotationTowardTank
    TankE.state = TankEStates.walk
  end
  --state shoot
  if TankE.state == TankEStates.shoot then
    local rotationTowardTank = math.angle(TankE.x, TankE.y, Tank.x, Tank.y)
    TankE.rotation = rotationTowardTank
    TankE.reloadTime = TankE.reloadTime - dt
    if TankE.reloadTime <= 0 then
      Shoot(TankE.x, TankE.y, TankE.rotation)
      TankE.reloadTime = 0.5
    end

    local distance = math.dist(TankE.x, TankE.y, Tank.x, Tank.y)
    if distance > TankE.detectionArea/2 then
      TankE.state = TankEStates.start
    end
  end
end

function love.load()
  Tank.x = love.graphics.getWidth()/2
  Tank.y = love.graphics.getHeight()/2

  TankE.height = TankE.img:getWidth()
  TankE.width = TankE.img:getWidth()

  windowW = love.graphics.getWidth()
  windowH = love.graphics.getHeight()
  teSpawnX = love.math.random(TankE.width, windowW - TankE.width)
  teSpawnY = love.math.random(TankE.height, windowW - TankE.height)
  
  TankE.x = 200--teSpawnX
  TankE.y = 200--teSpawnY
  TankE.state = TankEStates.start
end

function love.update(dt)
  Input(dt)
  EnnemyState(dt)

  for i=#projectiles,1,-1 do 
    local b = projectiles[i]
    b.x = b.x + dt * projectiles.speed * math.cos(b.rotation)
    b.y = b.y + dt * projectiles.speed * math.sin(b.rotation)
    --check if collide
    local distance = math.dist(b.x, b.y, TankE.x, TankE.y)
    if distance < projectiles.img:getWidth() then
      print("tankEhp-1 !")
      TankE.life = TankE.life - 1
      table.remove(projectiles, i)
    end
    if b.x <= 0 or b.y <=0 or b.x >= windowW or b.y >= windowH then
      table.remove(projectiles, i)
    end
  end

  Mouse.x = love.mouse.getX()
  Mouse.y = love.mouse.getY()
end

function love.draw()
  love.graphics.draw(Tank.img, Tank.x, Tank.y, Tank.rotation, 1, 1,Tank.img:getWidth()/2, Tank.img:getHeight()/2)
  
  if TankE.life > 0 then -- just for testing
    love.graphics.draw(TankE.img, TankE.x, TankE.y, TankE.rotation, 1, 1,TankE.img:getWidth()/2, TankE.img:getHeight()/2)
  end
  
  love.graphics.draw(Mouse.img, Mouse.x, Mouse.y, 0, 1, 1, Mouse.img:getWidth()/2, Mouse.img:getHeight()/2)
  for i=#projectiles,1,-1 do
    local b = projectiles[i]
    love.graphics.draw(projectiles.img, b.x, b.y, b.rotation, 1, 1,projectiles.img:getWidth()/2, projectiles.img:getHeight()/2)
    love.graphics.circle("line", b.x, b.y, projectiles.img:getWidth())
  end
  --Debug
  love.graphics.line(Tank.x, Tank.y, Mouse.x, Mouse.y)
  love.graphics.print("Map Height: "..windowW.." Map Width: "..windowH.."BulletNB:"..#projectiles)
  love.graphics.print(TankE.state, TankE.x, TankE.y - 40)
  love.graphics.circle("line", TankE.x, TankE.y, TankE.detectionArea)
end