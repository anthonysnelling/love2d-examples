testScores = {}

table.insert(testScores, 48)
table.insert(testScores, 90)
table.insert(testScores, 23)

testScores.subject = "science"

function love.draw()
    love.graphics.print(printTable(testScores))
    love.graphics.print(total(testScores),5,25)
    love.graphics.print(testScores.subject,5,50)
end

function printTable(printTab)
    local totalStr = ""
   for index, value in ipairs(printTab) do
      totalStr = totalStr .. " " .. value
   end 
   return totalStr
end

function total(tab)
    local result = 0
    for index, value in ipairs(tab) do
       result = result + value 
    end
    return result
end
