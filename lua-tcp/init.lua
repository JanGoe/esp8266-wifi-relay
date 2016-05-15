TMR_IP_CHECK_ID = 0
TMR_IP_CHECK_INTERVAL_IN_MS = 150
IP_CHECK_MAX_TIMES = 50 -- how often should IP be checked before AP starts
RELAY1_PIN = 4 -- GPIO2
RELAY2_PIN = 5 -- GPIO14

relay1_state = 0 -- 0 is off

function init_gpios()
  gpio.mode(RELAY1_PIN, gpio.OUTPUT)
  gpio.mode(RELAY2_PIN, gpio.OUTPUT)
end

function relay1_switchOff()
  gpio.write(RELAY1_PIN, gpio.HIGH) -- NC version: HIGH is off
end

function relay1_switchOn()
  gpio.write(RELAY1_PIN, gpio.LOW) -- NC version: LOW is on
end

function relay1_toggle()
  if (relay1_state == 0) then
    relay1_switchOn()
    relay1_state = 1
  else
    relay1_switchOff()
    relay1_state = 0
  end
end

function autotoggle_relay()
  local TMR_AUTOTOGGLE_ID = 0
  local TMR_AUTOTOGGLE_INTERVAL_IN_MS = 1000
  local TOGGLE_TIMES = 3 -- on and off cycles
  local toggle_count = 0

  relay1_switchOff() -- ensure that relay1 is switched off before toggling
  tmr.alarm(TMR_AUTOTOGGLE_ID, TMR_AUTOTOGGLE_INTERVAL_IN_MS, tmr.ALARM_AUTO, function()
    relay1_toggle()
    toggle_count = toggle_count + 1
    if (toggle_count == TOGGLE_TIMES * 2) then
      tmr.unregister(TMR_AUTOTOGGLE_ID)
    end
  end)
end

function startAP()
  print("AP-Mode starting...")
  autotoggle_relay()
  dofile("servernode.lua")
end


-- start init process
print("Starting init process...")
init_gpios()
print("Connecting to Wi-Fi...")
wifi.setmode(wifi.STATION)
wifi.sta.connect()

-- check if ESP got an IP, otherwise start AP
local ip_check_count = 0

tmr.alarm(TMR_IP_CHECK_ID, TMR_IP_CHECK_INTERVAL_IN_MS, tmr.ALARM_AUTO, function()
  if (wifi.sta.getip() == nil) then
    ip_check_count = ip_check_count + 1
    print("Connecting to Wi-Fi - "..ip_check_count)
    if (ip_check_count == IP_CHECK_MAX_TIMES) then
      tmr.unregister(TMR_IP_CHECK_ID)
      startAP() -- got no IP, start AP
    end
  else
    print("Connected to Wi-Fi")
    tmr.unregister(TMR_IP_CHECK_ID)
    dofile("actuator.lua")
  end
end)
