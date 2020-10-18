os.loadAPI("graph.lua")
os.loadAPI("optimize.lua")
local reactor = peripheral.find("BigReactors-Reactor")

if not fs.exists("reactorOptimization.csv") then
  optimize.runOptimization(reactor)
end

energyLastSec = 0

g = graph.newGraph(4,2000000,10000000)
graph.addLabel(g,"Energy")

useGraph = graph.newGraph(3,1100,12000)
graph.addLabel(useGraph,"Usage")
graph.changeType(useGraph,1)

term.clear()

function pullRodOut()
  current = reactor.getControlRodLevel(1)
  if current > 5 then
    reactor.setAllControlRodLevels(current-5)
  else
    reactor.setAllControlRodLevels(0)
  end
end

function pushRodIn()
  current = reactor.getControlRodLevel(1)
  rodPos,_=optimize.getBestEfficiencyFromFile()
  if current < rodPos-5 then
    reactor.setAllControlRodLevels(current+5)
  end
end

while true do
  local energy = reactor.getEnergyStored()
  if energy > 8000000 then
    reactor.setActive(false)
  elseif energy < 4000000 then
    reactor.setActive(true)
  end
  term.setCursorPos(1,1)
  usage = energyLastSec-energy
  print("Energy: " .. tostring(reactor.getEnergyStored()).."       ")
  print("Usage: "..tostring(usage).."     ")
  
  if reactor.getActive() and (usage > 0 or energy == 0) then
    pullRodOut()
  else
    pushRodIn()
  end
  
  rodPos = reactor.getControlRodLevel(1)
  
  print("Rod Position: "..tostring(rodPos).."    ")
  
  graph.addData(g,energy)
  graph.addLabel(g,"Energy: "..tostring(energy))
  graph.renderGraph(g)
  
  graph.addData(useGraph,usage)
  graph.addLabel(useGraph,"Usage: "..tostring(usage))
  graph.renderGraph(useGraph)
  
  sleep(1)
  energyLastSec = energy
end
