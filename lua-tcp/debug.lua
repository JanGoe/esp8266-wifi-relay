function send_to_visu()
-- senden an shc
link = "/debug.php?chipid=" ..node.chipid().. "&heap=" ..node.heap().. "&version="..version.. "&r1="..gpio.read(4).. "&r2=" ..gpio.read(5)
conn=net.createConnection(net.TCP, 0) 
conn:on("connection",function(conn, payload)
            conn:send("GET "..link.. " ".. 
                      "Host: 192.168.0.54\r\n"..
                      "Accept: */*\r\n"..
                      "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                      "\r\n\r\n") 
            end)
            
conn:on("receive", function(conn, payload)
    print('\nRetrieved in '..((tmr.now()-t)/1000)..' milliseconds.')
    --print(payload)
     local _, _, was = string.find(payload, "set\=([^&]+)")
     
     
        if(was == "1") then 
        local _, _, relay = string.find(payload, "relay\=([^&]+)")
            print("setze relay zu:" ..relay) 

        elseif(was == "ip") then
        local _, _, ip = string.find(payload, "ip\=([^&]+)")
            print("setze feste ip:" ..ip) 

        else
            print("set:" ..was) 
        end
    conn:close()
    end) 
t = tmr.now()    
conn:connect(80,'192.168.0.54') 
end
  -- funktion aufrufen 
tmr.alarm(2, 15000, 1, function()
send_to_visu()
end)
