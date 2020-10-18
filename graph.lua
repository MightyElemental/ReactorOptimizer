local graphs = {}

local positions = {{0,0},{26,0}, {0,10},{26,10}}

local dataOffset = 6

--corner, lower value, upper value, nextPointer, label, graph type
function newGraph(corner, lowerBound, upperBound)
  table.insert(graphs, {corner,lowerBound,upperBound,1,"",0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1})
  return #graphs
end

function addLabel(id, label)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  if( string.len(label) > 24) then error("Label must be shorter than 25 characters") end
  graphs[id][5] = label
end

function changeType(id, gType)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  graphs[id][6] = gType
end

function changeGraphPos(id, newCorner)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  if( newCorner > 4) then error("Graphs can only be in positions 1-4") end
  graphs[id][1] = newCorner
end

function getGraphPixPos(id)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  return positions[graphs[id][1]]
end

function addData(id, value)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  nextP = graphs[id][4]
  graphs[id][nextP+dataOffset] = value
  graphs[id][nextP+dataOffset+1] = -1
  nextP = nextP+1
  if(nextP > 25) then nextP = 1 end
  graphs[id][4] = nextP
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function getBarHeight(low,upp,val)
  return round((val-low)/(upp-low)*9.0,0)
end

local function renderLabel(id)
  if(string.len(graphs[id][5]) <= 0) then return end
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  term.setCursorPos(pos[1]+1,pos[2])
  write(" "..graphs[id][5])
end

local function renderBar(i,height)
  paintutils.drawLine(pos[1]+i,pos[2]+10,pos[1]+i,pos[2]+1,colors.black)
  if(height > 0) then
    paintutils.drawLine(pos[1]+i,pos[2]+10,pos[1]+i,pos[2]+10-height,colors.white)
  end
end

local function charAt(c, x, y)
  ox, oy = term.getCursorPos() 
  term.setCursorPos(x, y)
  write(c)
  term.setCursorPos(ox, oy)
end

local function renderPoint(i,height)
  paintutils.drawLine(pos[1]+i,pos[2]+10,pos[1]+i,pos[2]+1,colors.black)
  if(height > 0) then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    charAt(".",pos[1]+i,pos[2]+10-height)
    --paintutils.drawPixel(pos[1]+i,pos[2]+10-height,colors.white)
  end
end

local function renderLine(i,height,nextHeight)
  if(nextHeight > 9) then
      nextHeight = 9
  end
  paintutils.drawLine(pos[1]+i,pos[2]+10,pos[1]+i,pos[2]+1,colors.black)
  if(height > 0) then
    if(nextHeight > 0 and i~=25) then
      paintutils.drawLine(pos[1]+i,pos[2]+10-height,pos[1]+i+1,pos[2]+10-nextHeight,colors.white)
    else
      paintutils.drawPixel(pos[1]+i,pos[2]+10-height,colors.white)
    end
  end
end

function renderGraph(id)
  if( #graphs < id) then error("no such graph with ID "..tostring(id)) end
  pos = getGraphPixPos(id)
  low=graphs[id][2]
  upp=graphs[id][3]
  cx,cy=term.getCursorPos()
  col=term.getBackgroundColor()
  tex=term.getTextColor()
  paintutils.drawBox(pos[1],pos[2],pos[1]+26,pos[2]+10,colors.white)
  for i = 1,25 do
    val=graphs[id][i+dataOffset]
    height = getBarHeight(low,upp,val)
    if(height > 9) then
      height = 9
    end
    if(graphs[id][6]==0) then
      renderBar(i,height)
    elseif(graphs[id][6]==1) then
      renderLine(i,height,getBarHeight(low,upp,graphs[id][dataOffset+(1+i)%25]))
    elseif(graphs[id][6]==2) then
      renderPoint(i,height)
    end
  end
  renderLabel(id)
  term.setCursorPos(cx,cy)
  term.setBackgroundColor(col)
  term.setTextColor(tex)
end