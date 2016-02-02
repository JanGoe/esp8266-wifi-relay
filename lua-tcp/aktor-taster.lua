-- openhab support added 22.12.2015
version = "0.3.2"
verriegelung = 0 -- 0 = inaktiv 1=aktiv
sid1 = "21" -- fuer openhab itemname fuer shc sid des items
sid2 = "22" -- fuer openhab itemname fuer shc sid des items
-----------------------------------------------
function send_to_visu(sid, cmd)
  host = "192.168.0.27"
  platform = "SHC"

  if (platform == "SHC") then
    port = 80
    link = "/shc/index.php?app=shc&a&ajax=executeswitchcommand&sid="..sid.."&command="..cmd
  end
  
  if (platform == "Openhab") then
    if (cmd == 1) then switch="ON" elseif (cmd == 0) then switch="OFF" end
    port = 8080
    link = "/CMD?" ..sid.."=" ..switch
  end
  
  print(link)
  
    conn=net.createConnection(net.TCP, 0) 
    conn:on("connection",function(conn, payload)
    conn:send("GET "..link.. " ".. 
    "Host: "..host.. "\r\n"..
    "Accept: /\r\n"..
    "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
    "\r\n\r\n") 
    end)

    conn:on("receive", function(conn, payload)
    print('\nRetrieved in '..((tmr.now()-t)/1000)..' milliseconds.')
    --print(payload)
    conn:close()
    end) 
    t = tmr.now()

    conn:connect(80,host)

end
-----------------------------------------------
function read_temp(pin)
  --pin = 4
  status, temp, humi, temp_decimial, humi_decimial = dht.read(pin)
  print("DHT Temperature:"..temp..";".."Humidity:"..humi)
  if (status == dht.OK) then
  elseif (status == dht.ERROR_CHECKSUM) then
    print("DHT Checksum error.");
  elseif (status == dht.ERROR_TIMEOUT) then
    print("DHT Time out.");
  end

  return temp_decimial, humi_decimial, temp, humi
end

--------------------------------------------------
-- wlan verbinden
-----------------------------------------------

---------------------------------
print("wait")
-----------------------------------------------------
-- befehle ueber TCP empfangen
-----------------------------------------------------
ipshow = 0 -- damit nach empfangen der ip, tcp server startet
push = 0
change = 5
p1 = 0
p2 = 0

lampe1 = 0 -- 0 = aus
lampe2 = 0

-- config fuer gpios!
gpio.mode(6, gpio.HIGH)
gpio.write(6, gpio.HIGH)
gpio.mode(7, gpio.HIGH)
gpio.write(7, gpio.HIGH)

relay1 = 4
relay2 = 5
gpio.mode(relay1, gpio.OUTPUT)
gpio.mode(relay2, gpio.OUTPUT)

tmr.alarm(0, 150, 1, function()
  if wifi.sta.getip() == nil then
  --print("wait\n")
  elseif (ipshow == 0) then
    print("SS Running "..version)
    print(wifi.sta.getip())
    ipshow = 1
    
    sv = net.createServer(net.TCP, 1) -- anpassen das schneller beendet wird 1sek
    sv:listen(9274, function(c)
      c:on("receive", function(c, pl)
        print(pl) -- gibt empfangen daten in console aus!
        -- empfangen daten zerlegen
        typ = string.sub(pl, 0, 1)
        pin = string.sub(pl, 3, 3) -- geht nur mit einstelligen pins!
        befehl = string.sub(pl, 5, 5)
        -- type = 0 node.restart!
        -- Type 2 = Ausgang
        if (typ == "2") then
          gpio.mode(pin, gpio.OUTPUT)
          if (befehl == "1") then
            print("low")
            --gpio.write(pin, gpio.LOW)
            if (pin == "4") then
              lampe1 = 1
            end
            if (pin == "5") then
              lampe2 = 1
            end
          end

          if (befehl == "0") then
            print("high")
            --gpio.write(pin, gpio.HIGH)
            if(pin == "4") then
              lampe1 = 0
            end
            if(pin == "5") then
              lampe2 = 0
            end

          end
          -- type 3 = eingang
        elseif (typ == "3") then
          c:send(gpio.read(pin))
          print("abfrage:"..gpio.read(pin).."\n next...")
        elseif (typ == "4") then
          read_temp(pin)
          t = temp
          h = humi
          c:send(t.."|"..h)
        elseif (typ == "9") then
        c:send(version)
        elseif (typ =="0") then
          node.restart()
        end
        if string.sub(pl, 0, 11) == "**command**"  then
          payload = pl
          tmr.stop(0)
          dofile("wifi_tools.lua")
        end
      end)
    end)
    -- end ipshow if
  end

  -- einstellungen fuer schalter
  


  schalter1 = gpio.read(6)
  schalter2 = gpio.read(7)

  status1 = gpio.read(4)
  status2 = gpio.read(5)

-- für TASTER lampe2
 if(schalter1 == 0 and p1 == 0) then 
    p1 = 1 
    if(lampe1 == 1) then 
        lampe1 = 0 
        send_to_visu(sid1, status1)
    elseif(lampe1 == 0) then 
        lampe1 = 1 
        send_to_visu(sid1, status1)
        end
 print("schalter1 = 0 und lampe2="..lampe1) 
 
 end
  if(schalter1 == 1 and p1 == 1) then 
   p1 = 0
  end

-- für TASTER lampe2
 if(schalter2 == 0 and p2 == 0) then 
    p2 = 1
    if(lampe2 == 1) then 
        lampe2 = 0 
        send_to_visu(sid2, status2)
    elseif(lampe2 == 0) then 
        lampe2 = 1 
        send_to_visu(sid2, status2)
        end
 print("schalter2 = 0 und lampe2="..lampe2) 
 end

 if(schalter2 == 1 and p2 == 1) then 
  p2 = 0
 end

  -- fuer relays schalten
  if (lampe1 == 1) then
    if(verriegelung == 1) then
        lampe2 = 0
    end 
    gpio.write(relay1, gpio.LOW)
    --print("s1 low")
  end
  if (lampe1 == 0) then
    gpio.write(relay1, gpio.HIGH)
    --print("s1 high")
  end

  if (lampe2 == 1) then
    if(verriegelung == 1) then
        lampe1 = 0
    end 
    gpio.write(relay2, gpio.LOW)
    --print("s2 low")
  end
  if (lampe2 == 0) then
    gpio.write(relay2, gpio.HIGH)
    --print("s2 high")
  end

  -- end tmr funktion
end)
