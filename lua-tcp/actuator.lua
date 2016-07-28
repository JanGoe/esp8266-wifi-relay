-- constants
ACTUATOR_VERSION = "0.4.0"
TMR_ACTUATOR_ID = 0
TMR_ACTUATOR_INTERVAL_IN_MS = 150
TMR_RELAY1_DELAY_ID = 6
TMR_RELAY2_DELAY_ID = 5
RELAY_STATE_OFF = 0
RELAY_STATE_ON = 1
SWITCH_STATE_CLOSED = gpio.LOW -- is 0
SWITCH_STATE_OPEN = gpio.HIGH -- is 1

-- user defined options
INTERLOCK_ENABLED = false -- if active, only one relay can be on at the same time
DELAY_TIMER_ENABLED = false -- timer to switch off relays after a specified time
RELAY1_DELAY_TIME_IN_SEC = 10 -- delay time to switch off in seconds for relay 1
RELAY2_DELAY_TIME_IN_SEC = 10 -- delay time to switch off in seconds for relay 2
RELAY1_SID = "Test_Light1" -- openhab itemname / shc sid of item
RELAY2_SID = "Test_Light2" -- openhab itemname / shc sid of item

-- config gpios
RELAY1_PIN = 4 -- GPIO2
RELAY2_PIN = 5 -- GPIO14
gpio.mode(RELAY1_PIN, gpio.OUTPUT)
gpio.mode(RELAY2_PIN, gpio.OUTPUT)
SWITCH1_PIN = 6 -- GPIO 12
SWITCH2_PIN = 7 -- GPIO 13
gpio.mode(SWITCH1_PIN, gpio.INPUT, gpio.PULLUP)
gpio.mode(SWITCH2_PIN, gpio.INPUT, gpio.PULLUP)

-- init variables with default values
relay1_state = 0 -- 0 is off
relay2_state = 0 -- 0 is off
tcp_server_started = false -- tcp server needs to be started after ESP got an IP
switch1_prev_state = SWITCH_STATE_OPEN
switch2_prev_state = SWITCH_STATE_OPEN

-----------------------------------------------
function relay1_switchOff()
  gpio.write(RELAY1_PIN, gpio.HIGH) -- NC version: HIGH is off
end

function relay1_switchOn()
  gpio.write(RELAY1_PIN, gpio.LOW) -- NC version: LOW is on
end

function relay2_switchOff()
  gpio.write(RELAY2_PIN, gpio.HIGH) -- NC version: HIGH is off
end

function relay2_switchOn()
  gpio.write(RELAY2_PIN, gpio.LOW) -- NC version: LOW is on
end

function updateOpenhab(host, port, relay_sid,state)
    print("INFO","Updating openhab, host:"..host..",port:"..port.." with: /CMD?"..relay_sid.."="..state)
    time_before  = tmr.now()
    conn=net.createConnection(net.TCP, 0) 
    -- show the retrieved web page
    conn:on("receive", function(conn, payload)
    print("INFO","Retrieved in "..((tmr.now()-time_before)/1000).." milliseconds. payload: "..payload)
    conn:close()
    end )
    -- when connected, request page (send parameters to a script)
    conn:on("connection", function(conn, payload) 
       post_length=string.len(state)
       conn:send("GET /CMD?"..relay_sid.."="..state.." HTTP/1.1\r\n"
        .."HOST: "..host..":"..port.."\r\n"
        .."content-length: "..post_length.."\r\n\r\n"
        ..""..state.."\"")
       end)        
    -- when disconnected, let it be known
    conn:on("disconnection", function(conn, payload) end)
    
    conn:connect(port,host) 
end

function send_to_visu(sid, cmd)
  local HOST = "192.168.0.54"
  local PLATFORM = "Openhab" -- SHC or Openhab
  local link = ""
  local port=8080

  if (PLATFORM == "SHC") then
    link = "/shc/index.php?app=shc&a&ajax=executeswitchcommand&sid="..sid.."&command="..cmd
    print("INFO","using link: "..link)
    local conn = net.createConnection(net.TCP, 0) -- 0 means unencrypted
      conn:on("connection", function(conn, payload)
        conn:send("GET "..link.. " "..
          "Host: "..HOST.. "\r\n"..
          "Accept: /\r\n"..
          "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
          "\r\n\r\n")
      end)
    
      time_before = tmr.now()
      conn:on("receive", function(conn, payload)
        print("INFO","Retrieved in "..((tmr.now()-time_before)/1000).." milliseconds. payload: "..payload)
        conn:close()
      end)
      conn:connect(port, HOST)
  end
  
  if (PLATFORM == "Openhab") then
    local switch
    if (cmd == 1) then
      switch = "ON"
    elseif (cmd == 0) then
      switch = "OFF"
    end
    updateOpenhab(HOST,port,sid,switch)
  end

end

function read_temp(pin)
  local status, temp, humi, temp_dec, humi_dec = dht.read(pin)
  if (status == dht.OK) then
    print(temp.."|"..humi)
  elseif (status == dht.ERROR_CHECKSUM) then
    print("DHT Checksum error.");
  elseif (status == dht.ERROR_TIMEOUT) then
    print("DHT timed out.");
  end
  -- temp and humi are -999 when an error occurs
  return temp, humi
end

function start_tcp_server()
  local TCP_PORT = 9274
  local TIMEOUT_IN_SEC = 1
  local CMD_RESTART = 0
  local CMD_SWITCH = 2
  local CMD_STATUS = 3
  local CMD_TEMP = 4
  local CMD_VERSION = 9

  local srv = net.createServer(net.TCP, TIMEOUT_IN_SEC)
  srv:listen(TCP_PORT, function(conn)
    conn:on("receive", function(conn, pl)
      print(pl)
      -- split payload (string indices start at 1 in Lua)
      local command_type = tonumber(string.sub(pl, 1, 1))
      local pin = tonumber(string.sub(pl, 3, 3)) -- only single-digit pins!
      local command = tonumber(string.sub(pl, 5, 5))
      if (command_type == CMD_RESTART) then
        node.restart()
      elseif (command_type == CMD_SWITCH) then
        if (command == 1) then
          print("cmd switch on")
          if (pin == RELAY1_PIN) then
            relay1_state = 1
          end
          if (pin == RELAY2_PIN) then
            relay2_state = 1
          end
        end
        if (command == 0) then
          print("cmd switch off")
          if(pin == RELAY1_PIN) then
            relay1_state = RELAY_STATE_OFF
          end
          if(pin == RELAY2_PIN) then
            relay2_state = RELAY_STATE_OFF
          end
        end
      elseif (command_type == CMD_STATUS) then
        conn:send(gpio.read(pin))
        print("request pin "..pin.."| state = "..gpio.read(pin))
      elseif (command_type == CMD_TEMP) then
        local temp, humi = read_temp(pin)
        conn:send(temp.."|"..humi)
      elseif (command_type == CMD_VERSION) then
        conn:send(ACTUATOR_VERSION)
      end
      if string.sub(pl, 0, 11) == "**command**"  then
        payload = pl
        tmr.stop(TMR_ACTUATOR_ID)
        dofile("wifi_tools.lua")
      end
    end)
  end)
end

function init_delay_timers()
  tmr.register(TMR_RELAY1_DELAY_ID, RELAY1_DELAY_TIME_IN_SEC*1000, tmr.ALARM_SEMI, function()
    if(DELAY_TIMER_ENABLED == true) then
      relay1_state = RELAY_STATE_OFF
    end
  end)

  tmr.register(TMR_RELAY2_DELAY_ID, RELAY2_DELAY_TIME_IN_SEC*1000, tmr.ALARM_SEMI, function()
    if(DELAY_TIMER_ENABLED == true) then
      relay2_state = RELAY_STATE_OFF
    end
  end)
end


-- start actuator
print("Actuator starting...")
init_delay_timers()

-- begin actuator timer to handle switches and relays
tmr.alarm(TMR_ACTUATOR_ID, TMR_ACTUATOR_INTERVAL_IN_MS, tmr.ALARM_AUTO, function()
  if wifi.sta.getip() == nil then
    print("No IP yet!")
  elseif (tcp_server_started == false) then
    print("Running version "..ACTUATOR_VERSION)
    print(wifi.sta.getip())
    tcp_server_started = true
    start_tcp_server()
  end
  -- read gpio states from switches and relays
  local switch1_gpio_state = gpio.read(SWITCH1_PIN)
  local switch2_gpio_state = gpio.read(SWITCH2_PIN)
  local relay1_gpio_state = gpio.read(RELAY1_PIN)
  local relay2_gpio_state = gpio.read(RELAY2_PIN)

  -- begin switch1
  if (switch1_gpio_state == SWITCH_STATE_CLOSED and switch1_prev_state ~= switch1_gpio_state) then
    switch1_prev_state = SWITCH_STATE_CLOSED
    --print("debug if 1")
    if (relay1_state == RELAY_STATE_OFF) then
      relay1_state = RELAY_STATE_ON
      --print("relay1_state = 1")
      send_to_visu(RELAY1_SID, relay1_gpio_state)

    elseif (relay1_state == RELAY_STATE_ON) then
      relay1_state = RELAY_STATE_OFF
      --print("relay1_state = 0")
      send_to_visu(RELAY1_SID, relay1_gpio_state)
    end
  elseif (switch1_gpio_state == SWITCH_STATE_OPEN and switch1_prev_state ~= switch1_gpio_state) then
    switch1_prev_state = SWITCH_STATE_OPEN
    --print("debug if 2")
    if (relay1_state == RELAY_STATE_OFF) then
      relay1_state = RELAY_STATE_ON
      -- print("relay1_state = 1")
      send_to_visu(RELAY1_SID, relay1_gpio_state)
    elseif (relay1_state == RELAY_STATE_ON) then
      relay1_state = RELAY_STATE_OFF
      --print("relay1_state = 0")
      send_to_visu(RELAY1_SID, relay1_gpio_state)
    end
  end
  -- end switch1

  -- begin switch2
  if (switch2_gpio_state == SWITCH_STATE_CLOSED and switch2_prev_state ~= switch2_gpio_state) then
    switch2_prev_state = SWITCH_STATE_CLOSED
    --print("debug2 if 1")
    if (relay2_state == RELAY_STATE_OFF) then
      relay2_state = RELAY_STATE_ON
      --print("relay2_state = 1")
      send_to_visu(RELAY2_SID, relay2_gpio_state)
    elseif (relay2_state == RELAY_STATE_ON) then
      relay2_state = RELAY_STATE_OFF
      -- print("relay2_state = 0")
      send_to_visu(RELAY2_SID, relay2_gpio_state)
    end
  elseif (switch2_gpio_state == SWITCH_STATE_OPEN and switch2_prev_state ~= switch2_gpio_state) then
    switch2_prev_state = SWITCH_STATE_OPEN
    --print("debug2 if 2")
    if (relay2_state == RELAY_STATE_OFF) then
      relay2_state = RELAY_STATE_ON
      --print("relay2_state = 1")
      send_to_visu(RELAY2_SID, relay2_gpio_state)
    elseif (relay2_state == RELAY_STATE_ON) then
      relay2_state = RELAY_STATE_OFF
      -- print("relay2_state = 0")
      send_to_visu(RELAY2_SID, relay2_gpio_state)
    end
  end
  -- end switch2

  -- begin switching relays
  if (relay1_state == RELAY_STATE_ON) then
    if(INTERLOCK_ENABLED == true) then
      relay2_state = RELAY_STATE_OFF
    end
    if(DELAY_TIMER_ENABLED == true) then
      tmr.start(TMR_RELAY1_DELAY_ID)
    end
    relay1_switchOn()
    --print("switch relay1 on")
  end
  if (relay1_state == RELAY_STATE_OFF) then
    relay1_switchOff()
    --print("switch relay1 off")
  end

  if (relay2_state == RELAY_STATE_ON) then
    if(INTERLOCK_ENABLED == true) then
      relay1_state = RELAY_STATE_OFF
    end
    if(DELAY_TIMER_ENABLED == true) then
      tmr.start(TMR_RELAY2_DELAY_ID)
    end
    relay2_switchOn()
    --print("switch relay2 on")
  end
  if (relay2_state == RELAY_STATE_OFF) then
    relay2_switchOff()
    --print("switch relay2 off")
  end
  -- end switching relays

end) -- end actuator timer function
