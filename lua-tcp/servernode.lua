wifi.sta.disconnect()
tmr.delay(1000)
wifi.setmode(wifi.STATIONAP)
tmr.delay(1000)

pl = nil;
count = 0
-- create a server
sv = net.createServer(net.TCP, 10)
-- server listen on 80
sv:listen(80, function(conn)
  conn:on("receive", function(conn, pl)
    payload = pl;
    print(pl.."\n")
    ------------------------------------------------------------------------
    if string.find(pl, "set") then
      file.open("set.html", "r")
      conn:send("\n")
      conn:send(file.read())
      file.close("set.html")
    end
    
    if string.find(pl, "set1") then
      test = {string.find(pl, "ssid=")}
      test2 = {string.find(pl, "&pwd=")}
      test3 = {string.find(pl, "&senden=")}
      ssid = string.sub(pl, test[2]+1, test2[1]-1)
      pwd = string.sub(pl, test2[2]+1, test3[1]-1)

      print("SSID:"..ssid.." PWD:"..pwd)
      
      wifi.setmode(wifi.STATION)
      wifi.sta.config(ssid,pwd)   ---   SSID and Password for your LAN DHCP here
      wifi.sta.connect()
      
      node.restart()
    end
    conn:close()
    collectgarbage()
  end)
end)
print("Server running...")