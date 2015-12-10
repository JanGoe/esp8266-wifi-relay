--------------------------------------
print("start v.1")
manuel = 0
-------------------------------------------------------------------------------------------------function mqtt_start()
mqtt = mqtt.Client("WaschKueche", 0, "", "")

mqtt:on("connect", function(con) print ("connected") end)
mqtt:on("offline", function(con) 
     print ("reconnecting...") 
     print(node.heap())
     tmr.alarm(2, 2000, 0, function()
          mqtt:connect("192.168.0.43", 1883, 0)

     end)
end)
mqtt:connect("192.168.0.43", 1883, 0, function(conn) 
  print("connected")
  -- subscribe topic with qos = 0
  mqtt:subscribe("/home/#",0, function(conn) 
    -- publish a message with data = my_message, QoS = 0, retain = 0
    mqtt:publish("/home/light","WaschKueche",0,0, function(conn) 
      print("sent") 
    end)
  end)
  end)
mqtt:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
  print(data)
        if(topic == "/home/light/keller") then
            if(data == "ON") then
                gpio.write(4,gpio.LOW)
            end
            if(data == "OFF") then
                gpio.write(4,gpio.HIGH)
            end
        end

 end

end)

------------------------------------------------------------------------------------------------------------------end
-----------------------------------------------

-- wlan verbinden
-----------------------------------------------
-- STA Modus
--wifi.setmode(wifi.STATION)
-- SSID, Passwort
wifi.sta.config("SSID", "PASSWORD")
---------------------------------
print("wait")
-----------------------------------------------------
-- Code fuer befehle ueber TCP empfangen
-----------------------------------------------------
ipshow = 0 -- damit nach empfangen der ip tcp server startet
push = 0
change = 5
licht = 0 -- 0 = aus              
tmr.alarm(0, 150, 1, function()
     if wifi.sta.getip() == nil then
        --print("wait\n")
     elseif(ipshow == 0) then
        print("SS Running v0.4")
        print(wifi.sta.getip()) 
        ipshow = 1
        print("mqtt start")
       --mqtt_start()
    end

-----------------------------------------------------
-- Config fuer schalter !
-----------------------------------------------------
--schalterx(pin_relay,pin_eingang,"lisa1")

gpio.mode(7, gpio.HIGH)
gpio.write(7, gpio.HIGH)

schalter1 = gpio.read(7)

relay = 4
lampe_an = "\n status:" ..gpio.read(relay)
lampe_visu = gpio.read(relay)
sid = "Lampe SZ Test"
--gpio.mode(relay,gpio.OUTPUT)
--print(schalter1)

if(schalter1 == 0 and push ~= schalter1)  then
if(licht == 0) then
print("aus einschalten schalter1" ..lampe_an.. "\n")

licht=1 
make=0
manuel = 1
xyc=0
licht_value=nil
elseif(licht == 1) then
print("an ausschalten schalter1" ..lampe_an.. "\n")

licht=0 
make=1
manuel = 1
xyc=0
licht_value=nil
end
push = 0
elseif(schalter1 == 1 and push ~= schalter1) then
if(licht == 0) then
print("aus einschalten schalter1" ..lampe_an.. "\n")

licht=1 
manuel = 1
make=0
xyc=0 
licht_value=nil
elseif(licht == 1) then
print("an ausschalten schalter1" ..lampe_an.. "\n")

licht=0 
make=1
manuel = 1
xyc=0
licht_value=nil
end

push = 1
end

 end)

xyc = 0
tmr.alarm(2, 50, 1, function()
relay=4
        if(licht == 0 and xyc == 0) then
        
            xyc = 1
            --gpio.write(relay3,gpio.HIGH)
            if(manuel == 1) then
            --print("debug 203b manuel" ..lampe1.. " xyc: " ..xyc1)
                manuel = 0
                mqtt:publish("/home/light/keller","OFF",0,0, function(conn)
                print("done")
                end)
            end
        elseif(licht == 1 and xyc == 0) then
             xyc = 1
             --print("debug 214a" ..lampe1.. " xyc: " ..xyc1)
             if(manuel == 1) then
                manuel = 0
                --print("debug 214b manuel" ..lampe1.. " xyc: " ..xyc1)
                mqtt:publish("/home/light/keller","ON",0,0, function(conn)
                print("done")
                end)
             end
        --gpio.write(relay3,gpio.LOW)
        end


end)




       

