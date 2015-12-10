count = 0
pwm.setup(3,100,0)
tmr.alarm(0, 150, 1, function()
if(wifi.sta.getip() == nil) then
print("wait")
count = count+1
if(count == "50") then
node.restart()
end
else
tmr.stop(0)
dofile("aktor.lua")
end
end)
