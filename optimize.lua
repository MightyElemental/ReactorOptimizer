OUTPUT_FILE = "reactor_optimization.csv"
MAX_INSERTION = 98
-- When pulling rods out, efficiency decreases.
-- The multiplier for how far away the reactor can operate from peak efficiency
MIN_EFFICIENCY_MULT = 0.85

-- Used to block script from progressing until the reactor is at a stable temperature
-- This is important because the temperature change is not instantaneous once the rod is changed
-- Fuel consumption and energy output are dependent on the temperature so this is important for accuracy
local function waitUntilTemperatureStable(reactor)
  lastFuel = reactor.fuelTemperature()
  lastCase = reactor.casingTemperature()
  sleep(1)
  while math.abs(lastFuel - reactor.fuelTemperature()) > 2 or math.abs(lastCase-reactor.casingTemperature()) > 2 do
    lastFuel = reactor.fuelTemperature()
    lastCase = reactor.casingTemperature()
    sleep(1)
  end
  sleep(1)
end

function runOptimization(reactor)
  local file = fs.open(OUTPUT_FILE, "w")
  file.writeLine("Rod Pos, Power, Fuel Used, Efficiency")

  g = graph.newGraph(4, 0, 5)
  graph.addLabel(g,"Efficiency (Log.)")
  graph.changeType(g,1)

  reactor.setActive(true)
  term.clear()
  bestEff = 0
  bestEffRodLevel = 0
  found = false
  for i=0,99 do
    term.setCursorPos(1,1)
    reactor.setAllControlRodLevels(i)
    rodLevel = reactor.getControlRod(0).level()
    
    waitUntilTemperatureStable(reactor)
    
    eff = getEfficiency(reactor)
    -- Efficiency may be higher after MAX_INSERTION% rod insertion, but there is usually no point running a reactor at such a low power level
    -- TODO: Create config for this (currently doesn't impact performance - it's just a visual thing)
    if(eff < bestEff and i > MAX_INSERTION) then
      found = true
    end
    if(eff > bestEff and not found) then
      bestEff = eff
      bestEffRodLevel = rodLevel
    end
    saveResult(reactor,i,file)
    print(string.format("Reactor Rod Position: %i  ", rodLevel))
    print(string.format("Efficiency: %i      ", eff))
    print(string.format("Best Efficiency: %i @ %i       ", bestEff, bestEffRodLevel))

    -- Draw graph
    if i%4==0 then
      -- Calculate new upper bound if needed
      _,hb = graph.getBounds(g)
      dp = math.log10(eff)
      if dp+0.1 > hb then
        graph.changeHighBound(g, dp+0.1)
      end
      if i == 0 then -- 0 insertion should be lowest efficiency
        graph.changeLowBound(g, dp-0.1)
        if dp >= hb then -- Ensure upper bound is higher
          graph.changeHighBound(g, dp+0.1)
        end
      end
      -- Add data point
      graph.addData(g, dp)
    end
    graph.renderGraph(g)

  end
  reactor.setAllControlRodLevels(bestEffRodLevel)
  file.flush()
end

-- Write rod insertion value to file
function saveResult(reactor,rodInsertLvl,file)
  energy, fuel, efficiency = getReactorStats(reactor)
  file.writeLine(string.format("%i,%f,%f,%f", rodInsertLvl, energy, fuel, efficiency))
end

-- Returns the energy, fuel usage, and efficiency of the reactor at this moment
function getReactorStats(reactor)
  fuelTank = reactor.fuelTank()
  fuel = fuelTank.burnedLastTick()
  energy = reactor.battery().producedLastTick()
  -- You don't want 0 fuel usage or 0 energy output!
  -- This will lead to div/0 error or an outlier efficiency value of 0
  while (fuel <= 0 or energy <= 0) do
    fuel = fuelTank.burnedLastTick()
    energy = reactor.battery().producedLastTick()
    sleep(0.5)
  end
  efficiency = energy/fuel

  return energy, fuel, efficiency
end

-- Get efficiency ratio at current moment
function getEfficiency(reactor)
  _,_,efficiency = getReactorStats(reactor)
  return efficiency
end

-- Gets the best efficiency under the maximum insertion level
function getBestEfficiency(maxInsertion)
  if not fs.exists(OUTPUT_FILE) then
    return -1
  end
  config = {}
  file = fs.open(OUTPUT_FILE, "r")
  hasNext = true
  file.readLine()
  bestEff = -1
  bestEffRodLevel = -1
  minRodLevel = 0

  -- Load config file
  while hasNext do
    line = file.readLine()
    if line == nil then
      hasNext = false
    else
      rodPos,_,_,eff = getValues(line)
      rodPos = tonumber(rodPos)
      eff = tonumber(eff)

      config[rodPos] = eff

      -- Stop reading config file after max insertion level
      if(rodPos >= maxInsertion) then
        break
      end
    end
  end

  -- Scan config file for best
  for rodPos,eff in pairs(config) do
    if(eff > bestEff) then
      bestEff = eff
      bestEffRodLevel = rodPos
    end
  end

  -- Scan config file for lowest allowed
  for rodPos,eff in pairs(config) do
    if(eff > bestEff*MIN_EFFICIENCY_MULT) then
      minRodLevel = rodPos
      break
    end
  end

  return bestEffRodLevel, minRodLevel, bestEff
end

-- Used to split csv line into array
-- rod insertion level, energy, fuel, efficiency
function getValues(line)
  return line:match("([^,]+),([^,]+),([^,]+),([^,]+)")
end