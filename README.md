# ESP8266-Wifi-Relay

## Inhaltsverzeichnis

* [Spezifikation] (#spezifikation)
* [Installation] (#installation)
* [Konfiguration] (#konfiguration)
* [SHC Schaltserver] (#shc-schaltserver)
* [MQTT] (#mqtt)
* [piMatic Installations Anleitung] (#pimatic)
* [Manuelle Steuerung] (#manuelle-steuerung)
* [Alternative Steuerungen] (#alternative-steuerungen)
* [Sonstige Informationen] (#sonstige-informationen)

## Spezifikation

- WLAN steuerbares 2-Port Relais / oder nur mit 1 Relais bestückt
- optionale Schalter/Taster Unterstützung (inkl. Feedback)
- Firmware: [NodeMCU](https://github.com/nodemcu/nodemcu-firmware/blob/master/README.md) 
- Bestellung über [eBay](http://www.ebay.de/itm/-/322025590037?) in verschienden Varianten oder per [Mail](mailto:jan.andrea7@googlemail.com) Nur noch V.2 Verfügbar  / oder im Shop [1Fach] (http://iot-elektrik.de/shop/WiFi-Relay-1-Fach?github=1) [2Fach] (http://iot-elektrik.de/shop/WiFi-Relay-2-Fach?github=1) im Shop 10% Rabatt mit code **1823784**
 
## Installation

![Anschluss](/pics/anschluss.png?raw=true)

![Achtung](/pics/achtung-red.png?raw=true) Sobald **L/N** (~230V) angeschlossen sind und **Netzspannung** anliegt, die Platine nicht mehr berühren!

## Konfiguration

### Quick Setup

A) Beim ersten Start des ESP8266-Wifi-Relay wird ein **HOTSPOT** (nach ca. 10 Sekunden leuchtet die Blaue LED am ESP8266 3x kurz / das Relais schaltet 3x) mit der SSID: **RelaySetup** erstellt. Sobald man mit diesem Hotspot verbunden ist, kann man auf `http://192.168.4.1/` die Zugangsdaten des eigenen WLAN-Netzes eingeben. Nach dem Speichern der Daten, startet der ESP8266 neu und versucht sich zu verbinden. Im Fehlerfall (WLAN nicht erreichbar, Zugangsdaten falsch) beginnt das ESP8266-Wifi-Relay wieder bei Schritt **A)**

Sofern alles geklappt hat, startet der TCP-Server auf Port 9274 und es können Befehle ausführt werden (z.b. Dateien auf den ESP8266 übertragen - siehe Befehls-Tabelle weiter unten)

![HOTSPOT](/pics/ssid.jpg?raw=true)
![Config-Page](/pics/set.jpg?raw=true)

### Legacy Setup

Als ersten Schritt **GND**, **RX**, **TX** mit einem [TTL-USB Adapter](http://www.elecfreaks.com/wiki/index.php?title=USB_to_RS232_Converter) (**Achtung**: 3.3 Volt Pegel, bei 5 Volt muss ein [Pegelwandler](https://www.mikrocontroller.net/articles/Pegelwandler) "Levelshifter" verwendet werden) verbinden. **RX** wird mit **TX** verbunden und **TX** mit **RX**. Dann **L**, **N** anschließen (siehe Anschlussplan).

Sobald Netz-Spannung anliegt, sollte der ESP8266 auf der Rückseite der Platine starten und die blaue LED kurz aufblinken. Jetzt habt ihr die Möglichkeit die eigentliche Steuerungs-Software ([actuator.lua](/lua-tcp/actuator.lua)) auf dem ESP8266 zu übertragen.

Dazu bitte die [actuator.lua](/lua-tcp/actuator.lua) öffen, die WLAN Daten anpassen und die Datei mit dem [ESPlorer](http://esp8266.ru/esplorer/) auf den ESP8266 kopieren (über *Save* im ESPlorer). Nach dem erfolgreichen Übertragen, wird automatisch der TCP-Server gestartet und es wird die IP vom ESP8266 angezeigt (rechtes Fenster).

![ESPlorer](/pics/esplorer.png?raw=true)

## SHC Schaltserver

Um aus der "Ferne" die Relais zu steuern, hat man die Möglichkeit in [SHC](http://rpi-controlcenter.de/) einen Schalterserver einzutragen mit der IP des ESP8266-Wifi-Relay und Port 9274 ( GPIO lesen JA, GPIO schreiben JA - geeignetes Model z.B. Arduino Nano ) 

Nun kann man unter *Schaltfunktionen* Ausgänge anlegen ( als Schalterserver den neu erstellten auswählen und als **GPIO4/5** )  


Damit in SHC auch die Rückmeldung funktioniert, wenn manuell geschaltet wird, muss in der [actuator.lua](/lua-tcp/actuator.lua) noch folgendes angepasst werden:
- In der Funktion `send_to_visu` bitte PLATFORM = "SHC" setzen
- Bei HOST bitte die IP eintragen unter der **SHC** erreichbar ist
- Bei den "user defined options" (ganz oben) die **RELAY_SIDs** anpassen (die SID findet ihr. wenn ihr euch mit Putty einloggt, in das Verzeichnis `/var/www/shc` geht und dort ein `php index.php app=shc -sw –l` eingebt. Nun wird euch eine Liste mit allen schaltbaren Elementen angezeigt. Die SIDs jetzt bitte anpassen.)

## MQTT

Das ESP8266-Wifi-Relay lässt sich auch via [MQTT](https://primalcortex.wordpress.com/2015/02/06/nodemcu-and-mqtt-how-to-start/) steuern/abfragen. Hierfür bitte [init.lua](/lua-mqtt/init.lua) und [aktor.lua](/lua-mqtt/aktor.lua) verwenden (Achtung: die Dateien müssen angepasst werden).

## Pimatic

Um das ESP8266-Wifi-Relay via Pimatic anzusteuern, ist folgende anpassung erforderlich:

- Ändert in der [actuator.lua](/lua-tcp/actuator.lua) folgende Zeilen ab:

```
-- pimatic-edition 02.02.2016
ACTUATOR_VERSION = "0.4.0.pimatic"

-- user defined options
RELAY1_SID = "Licht_Arbeitszimmer"
RELAY1_SID = "Schlafzimmer_Lampe1"


-----------------------------------------------
function send_to_visu(sid, cmd)
  local PLATFORM = "Pimatic"
  local HOST = "192.168.8.200"
  local port = 80
  local link = ""
  local BASE_LOGIN_PIMATIC = "YWRtaW46YzRqc2luOGQ="
  if (PLATFORM == "Pimatic") then
    local switch
    if (cmd == 1) then
      switch = "true"
    elseif (cmd == 0) then
      switch = "false"
    end
    port = 80
    link = "/api/device/"..sid.."/changeStateTo?state="..switch..""
  end

  if (PLATFORM == "Openhab") then
    local switch
    if (cmd == 1) then
      switch = "ON"
    elseif (cmd == 0) then
      switch = "OFF"
    end
    port = 8080
    link = "/CMD?" ..sid.."=" ..switch
  end

  print(link)
  
  local conn = net.createConnection(net.TCP, 0) 
  conn:send("GET "..link.." HTTP/1.1\r\n")
  conn:send("Authorization: Basic "..BASE_LOGIN_PIMATIC.."\r\n")
  conn:send("Host: "..HOST.."\r\n")
  conn:send("Content-Type:application/json\r\n")
  conn:send("Connection: close\r\n")
  conn:send("Accept: */*\r\n\r\n")
  time_before = tmr.now()  
  conn:on("receive", function(conn, payload)
    print('Retrieved in '..((tmr.now()-time_before)/1000)..' milliseconds.\n')
    --print(payload)
    conn:close()
  end) 
    
  conn:connect(port, HOST)

end
-----------------------------------------------
```

- Konfiguriert nun folgede Zeilen und Speichert die actuator.lua auf dem ESP8266:
  - RELAY1_SID         -- device-id des Pimatic-Schalters, der Relais 1 schalten soll
  - RELAY2_SID         -- (falls vorhanden) device-id des Pimatic-Schalters, der Relais 2 schalten soll
  - HOST               -- IP eures Pimatic-Servers
  - BaseLoginPimatic   -- Base64-codierter String des Loginschemas "user:passwort" -> Um die Base64Login-Daten zu erhalten, gebt eure Loginschema auf https://www.base64encode.org/ ein und drückt "encode"
 
- Kopiert nun die tcp.php auf euer RaspberryPi (hier im Beispiel /home/pi/tcp.php) z.b. mit  ```wget https://raw.githubusercontent.com/JanGoe/esp8266-wifi-relay/master/tcp.php```
- Stellt sicher dass php5 am RaspberryPi installiert ist (ggf. "sudo apt-get install php5") 
- Anschließend fügt ihr folgende Device der Pimatic-Konfiguration an:

  ```
      {
      "id": "Licht_Arbeitszimmer",
      "name": "Lamp",
      "class": "ShellSwitch",
      "onCommand": "php /home/pi/tcp.php 192.168.8.3 2x4x1",
      "offCommand": "php /home/pi/tcp.php 192.168.8.3 2x4x0",
      "getStateCommand": "echo false",
      "interval": 0
    }
  ```
  - id               -- muss mit der "sid" des ESP's übereinstimmen
  - name             -- kann frei gewählt werden
  - onCommand        -- Einschaltbefehl "php <pfad/der/tcp.php> <ip-des-esp> <funktion>" die Kommandos findet ihr im Abschnitt "PHP Script"
  - offCommand       -- Ausschaltbefehl
  - getStateCommand  -- Befehl, der zur Schalterzustandaktualisierung verwendet wird. Dieser muss nicht verwendet werden da der Schalter seinen Zustand an Pimatic übermittelt
  - interval         -- Häufigkeit der Abfrage des Schalterzustandes in Millisekunden

![pimatic-switch](http://www.youscreen.de/gxmqrhwb10.jpg)

Funktioniert alles Korrekt, sollten sich im ESPlorer nach manueller Betätigung von "Switch1" folgende Debugzeilen abbilden

![pimatic-switch-debug](http://www.youscreen.de/skuzwqbs61.jpg)

... und sich der Schalterzustand in Pimatic entsprechend anpassen.

Bei Umlegen des schalters in Pimatic erscheinen fogende Debugzeilen (im ESPlorer sichtbar):

![pimatic-switch-debug2](http://www.youscreen.de/yovpflqp16.jpg)

## Manuelle Steuerung

Wollt ihr an der Platine einen Taster/Schalter anschliesen, bitte dafür **GND / GPIO12** und  **GND / GPIO13** nutzen ( schaltet nach **GND** ) 

## Alternative Steuerungen

Wer die Platine nicht mit SHC betreiben möchte, kann diese natürlich auch über einfache TCP Befehle steuern.
Wer die Relais gegeneinander verriegeln möchte, bitte in der [actuator.lua](/lua-tcp/actuator.lua) `INTERLOCK_ENABLED = true` setzen, damit kann immer nur 1 Relais geöffnet sein.

### PHP Script ([tcp.php](/tcp.php))

| Befehl  | Beschreibung | Antwort |
| ------------- | ------------- | ------------- |
| `php tcp.php 192.168.0.62 2x4x1` | Dieses Kommando schaltet **Relais 1** auf **AN** | |
| `php tcp.php 192.168.0.62 2x4x0` | Dieses Kommando schaltet **Relais 1** auf **AUS** | |
| `php tcp.php 192.168.0.62 2x5x1` | Dieses Kommando schaltet **Relais 2** auf **AN** | |
| `php tcp.php 192.168.0.62 2x5x0` | Dieses Kommando schaltet **Relais 2** auf **AUS** | |
| `php tcp.php 192.168.0.62 3x4` | Status vom **Relais 1** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 3x5` | Status vom **Relais 2** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 4x1`  | DHT22 Daten von Pin 1 abfragen | Temp;Luftfeuchte |
| `php tcp.php 192.168.0.62 9x0` | Version abfragen | 0.4.0 |
| `php tcp.php 192.168.0.62 0x0` | ESP8266 neustarten | |
| `php tcp.php 192.168.0.62 update datei.lua` | Datei 'datei.lua' hochladen und ESP8266neu starten | | 

*192.168.0.62 ist im obigen Beispiel die IP Adresse des ESP8266*

### HTTP Rückmeldung

Möchte man Rückmeldungen vom manuellen Schalten auswerten geht dieses via HTTP ( der ESP8266 sendet einen HTTP-GET-REQUEST an eine gewünschte Seite - dazu bitte die Funktion `send_to_visu` in der ([actuator.lua](/lua-tcp/actuator.lua)) anpassen.

### OpenHab

Beispiel für [OpenHab](http://www.openhab.org/) ( Benötigt PHP auf dem OpenHab Host und das [EXEC Binding](https://github.com/openhab/openhab/wiki/Exec-Binding) )

Bitte in der Items Datei (`<openhab_installation_dir>/configurations/items`) folgendes eintragen:

```
Switch Schalter "Lampe1" {exec=">[ON:php /var/www/tcp.php 192.168.0.62 2x3x1] >[OFF:php /var/www/tcp.php 192.168.0.62 2x3x0]"}
```

*192.168.0.62 ist im obigen Beispiel die IP Adresse des ESP8266*

Für Rückmeldungen in Openhab bitte in der [actuator.lua](/lua-tcp/actuator.lua) folgende Zeilen anpassen:
- In der Funktion `send_to_visu` PLATFORM = "Openhab" setzen
- IP unter der openhab erreichbar ist
- ggf. den Port anpassen
- Bei den "user defined options" (ganz oben) die **RELAY_SIDs** anpassen auf die Namen der Items die aktualisiert werden sollen


Weitere Informationen über OpenHab findet sich in den [Ersten Schritten](https://openhabdoc.readthedocs.org/de/latest/Beispiel/).

## Sonstige Informationen

### Stromverbrauch

- Version 2 - NC Version (Standardversion): zwischen 0.6 (Standby) und 1.2 Watt
- Version 2 - NO Version (Spezialversion): zwischen 0.3 (Standby) und 1.2 Watt

### GPIO Mapping

| GPIO  | PIN | [IO index](https://nodemcu.readthedocs.io/en/dev/en/modules/gpio/) | Bemerkung |
| ------------- | ------------- | ------------- | ------------- |
| GPIO0 | 18 | 3 | Flashmodus (wenn auf GND) (DS18D20 - ungetestet) |
| GPIO1 | 22 | 10 | UART TX|
| GPIO2 | 17 | 4 | Relais 1 / LED (blau) |
| GPIO3 | 21 | 9 | UART RX |
| GPIO4 | 19 | 2 | *frei* |
| GPIO5 | 20 | 1 | *frei* |
| GPIO12 | 6 | 6 | Schalter/Taster 1 |
| GPIO13 | 7 | 7 | Schalter/Taster 2 |
| GPIO14 | 5 | 5 | Relais 2 |
| GPIO15 | 16 | 8 | *frei* |
| GPIO16 | 4 | 0 | sollte nicht genutzt werden (wird für Deep Sleep Mode verwendet) |

![Pinout](/pics/esp8266-pin.png?raw=true)

### Schaltplan / Schema

![Schema](/pics/schema.png?raw=true)

### Platinen Maße

- 48 mm breit (stark abgerundete Ecken)
- 48 mm lang
- 21 mm tief

### Neue Firmware flashen

Programmiermodus: **GPIO0** und **GND** mit einem Jumper verbinden, ESP8266 neu starten. Image mit [ESPTOOL](https://github.com/themadinventor/esptool) flashen:

#### MacOSX (im Beispiel wird NodeMCU "installiert")
````
python ./esptool.py --port=/dev/cu.SLAB_USBtoUART  write_flash  -fm=dio -fs=32m 0x00000 ../nodemcu-master-8-modules-2015-09-01-02-42-13-float.bin

Connecting...
Erasing flash...
Took 1.62s to erase flash block
Wrote 415744 bytes at 0x00000000 in 44.8 seconds (74.2 kbit/s)...

Leaving...
```

### 10A Erweiterung

~~Obwohl die Relais mit 10A belastet werden könnten, sind die Leiterbahnen zu den Schraubklemmen zu dünn und sind mit maximal 2A belastbar. Um die volle Belastbarkeit erreichen, muss man an der Unterseite der Platine die Leiterbahnen von den Relaisanschlüssen zur Schraubklemme mit tauglichen Drähten überbrücken/verstärken.~~ (siehe [raspiprojekt.de](https://raspiprojekt.de/kaufen/shop/bausaetze/wifi-relais-zweifach.html))

![10A Erweiterung](/pics/esp8266-10a.png?raw=true)

![Achtung](/pics/achtung-yellow.png?raw=true) angepasst mit Version 2

## Erweiterungen/Ideen (ungetestet)

### Hardware

- ~~Sicherung (z.B. Reichelt *MINI FLINK 1,0A*) vor dem *HLK-PM01* - [Teardown](http://lygte-info.dk/review/Power%20Mains%20to%205V%200.6A%20Hi-Link%20HLK-PM01%20UK.html)~~ umgesetzt mit Version 2
- dahinter MOV (z.B. Reichelt *VDR-0,6 270*)
- Reedkontakt (z.B. Reichelt *KSK 1A66*) als "unsichtbarer" Resetschalter
- ~~DS18B20 Temperatur Sensor~~  umgesetzt mit Version 2 (GPIO auf PIN Leiste)
- ~~DHT22 (an **GPIO5** - Pin 1 angeschlossen)~~  umgesetzt mit Version 2 (GPIO auf PIN Leiste)
![Config-Page](/pics/dht22.jpg?raw=true)

### Software

- regelmäßiger Restart vom ESP8266
  * Remote Neustart via Skript: `php tcp.php 192.168.0.62 0x0` (siehe oben)
