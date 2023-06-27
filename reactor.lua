os.loadAPI("graph.lua")
os.loadAPI("optimize.lua")
local reactor = peripheral.find("BiggerReactors_Reactor")

local mainRod = reactor.getControlRod(0)
local battery = reactor.battery()

if not fs.exists(optimize.OUTPUT_FILE) then
  optimize.runOptimization(reactor)
end

energyLastSec = 0

-- Get best efficiency under 80% rod insertion
targetPos,_ = optimize.getBestEfficiency(optimize.MAX_INSERTION)

g = graph.newGraph(4, 0, battery.capacity())
graph.addLabel(g,"Energy")

-- TODO: Make graph adaptive
useGraph = graph.newGraph(3,0,10000)
graph.addLabel(useGraph,"Usage")
graph.changeType(useGraph,1)

term.clear()

function pullRodOut()
  current = mainRod.level()
  reactor.setAllControlRodLevels(current-1)
end

function pushRodIn()
  current = mainRod.level()
  if current < targetPos then
    reactor.setAllControlRodLevels(current+1)
  end
end

function controlRods(usage, energy)
  if reactor.active() and (usage > 0 or energy == 0) then
    -- TODO: Lookup value from csv file to match demand
    pullRodOut()
  else
    pushRodIn()
  end
end

while true do
  local energy = battery.stored()
  local capacity = battery.capacity()
  if energy > capacity*0.8 then
    reactor.setActive(false)
  elseif energy < capacity*0.4 then
    reactor.setActive(true)
  end
  term.setCursorPos(1,1)
  usage = energyLastSec-energy
  
  controlRods(usage, energy)
  
  rodPos = mainRod.level()
  chargePct = (energy/capacity)*100

  -- TODO: Change energy display to use RF/t instead of RF/s

  print("Energy: " .. tostring(battery.stored()).." ("..tostring(math.floor(chargePct*10)/10).."%)  ")
  print("Usage: "..tostring(usage).."          ")
  if reactor.active() then print("ACTIVE") else print("       ") end
  
  print("\n--- RODS ---")
  print(string.format("Target Position: %i    ", targetPos))
  print(string.format("Current Position: %i    ", rodPos))

  graph.addData(g,energy)
  graph.addLabel(g,"Energy: "..tostring(energy))
  graph.renderGraph(g)
  
  graph.addData(useGraph,usage)
  graph.addLabel(useGraph,"Usage: "..tostring(usage))
  graph.renderGraph(useGraph)
  
  sleep(1)
  energyLastSec = energy
end
