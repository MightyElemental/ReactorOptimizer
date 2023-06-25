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

g = graph.newGraph(4,2000000,10000000)
graph.addLabel(g,"Energy")

useGraph = graph.newGraph(3,1100,12000)
graph.addLabel(useGraph,"Usage")
graph.changeType(useGraph,1)

term.clear()

function pullRodOut()
  current = mainRod.level()
  if current > 5 then
    reactor.setAllControlRodLevels(current-5)
  else
    reactor.setAllControlRodLevels(0)
  end
end

function pushRodIn()
  current = mainRod.level()
  if current < targetPos-5 then
    reactor.setAllControlRodLevels(current+5)
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
  
  if reactor.active() and (usage > 0 or energy == 0) then
    pullRodOut()
  else
    pushRodIn()
  end
  
  rodPos = mainRod.level()
  chargePct = (energy/capacity)*100

  print("Energy: " .. tostring(battery.stored()).." ("..tostring(math.floor(chargePct*10)/10).."%)  ")
  print("Usage: "..tostring(usage).."     ")
  
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
