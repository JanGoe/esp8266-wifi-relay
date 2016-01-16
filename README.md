# ESP8266-Wifi-Relay

## Spezifikation

- WLAN steuerbares 2-Port Relais
- optionale Schalter/Taster Unterstützung (inkl. Feedback)
- Firmware: [NodeMCU](https://github.com/nodemcu/nodemcu-firmware/blob/master/README.md) 

## Installation

![Anschluss](/pics/anschluss.png?raw=true)

![Achtung](/pics/achtung-red.png?raw=true) Sobald **L/N** (~230V) angeschlossen sind und **Netzspannung** anliegt, die Platine nicht mehr berühren!

## Konfiguration

### Quick Setup

A) Beim ersten Start des ESP8266-Wifi-Relay wird ein **HOTSPOT** (nach ca. 10 Sekunden leuchtet die Blaue LED am ESP8266 3x kurz / das Relais schaltet 3x) mit der SSID: **ESP_XXXX** erstellt. Sobald man mit diesem Hotspot verbunden ist, kann man auf `http://192.168.4.1/set` die Zugangsdaten des eigenen WLAN-Netzes eingeben. Nach dem Speichern der Daten, startet der ESP8266 neu und versucht sich zu verbinden. Im Fehlerfall (WLAN nicht erreichbar, Zugangsdaten falsch) beginnt das ESP8266-Wifi-Relay wieder bei Schritt **A)**

Sofern alles geklappt hat, startet der TCP-Server auf Port 9274 und es können Befehle ausführt werden (z.b. Dateien auf den ESP8266 übertragen - siehe Befehls-Tabelle weiter unten)

![HOTSPOT](/pics/ssid.jpg?raw=true)
![Config-Page](/pics/set.jpg?raw=true)

### Legacy Setup

Als ersten Schritt **GND**, **RX**, **TX** mit einem [TTL-USB Adapter](http://www.elecfreaks.com/wiki/index.php?title=USB_to_RS232_Converter) (**Achtung**: 3.3 Volt Pegel, bei 5 Volt muss ein [Pegelwandler](https://www.mikrocontroller.net/articles/Pegelwandler) "Levelshifter" verwendet werden) verbinden. **RX** wird mit **TX** verbunden und **TX** mit **RX**. Dann **L**, **N** anschließen (siehe Anschlussplan).

Sobald Netz-Spannung anliegt, sollte der ESP8266 auf der Rückseite der Platine starten und die blaue LED kurz aufblinken. Jetzt habt ihr die Möglichkeit die eigentliche Steuerungs-Software ([aktor.lua](/lua-tcp/aktor.lua)) auf dem ESP8266 zu übertragen.

Dazu bitte die [aktor.lua](/lua-tcp/aktor.lua) öffen, die WLAN Daten anpassen und die Datei mit dem [ESPlorer](http://esp8266.ru/esplorer/) auf den ESP8266 kopieren (über *Save* im ESPlorer). Nach dem erfolgreichen Übertragen, wird automatisch der TCP-Server gestartet und es wird die IP vom ESP8266 angezeigt (rechtes Fenster).

![ESPlorer](/pics/esplorer.png?raw=true)

## SHC Schaltserver

Um aus der "Ferne" die Relais zu steuern, hat man die Möglichkeit in [SHC](http://rpi-controlcenter.de/) einen Schalterserver einzutragen mit der IP des ESP8266-Wifi-Relay und Port 9274 ( GPIO lesen JA, GPIO schreiben JA - geeignetes Model z.B. Arduino Nano ) 

Nun kann man unter *Schaltfunktionen* Ausgänge anlegen ( als Schalterserver den neu erstellen auswählen und als **GPIO4/5** )  


Damit in SHC auch die Rückmeldung funktioniert, wenn manuel schaltet geschaltet wird, muss in der [aktor.lua](/lua-tcp/aktor.lua) noch folgendes angepasst werden:
- In Zeile 3 bitte platform="SHC"
- In Zeile 18 und 20 bitte die IP eintragen unter der **SHC** erreichbar ist
- In Zeile 154,155 bitte **SID** anpassen  ( die SID findet ihr. wenn ihr euch mit Putty einloggt, in das Verzeichnis `/var/www/shc` geht und dort ein `php index.php app=shc -sw –l` eingebt. Nun wird euch eine Liste mit allen schaltbaren Elementen angezeigt, die SID jetzt bitte im [init.lua](/lua-tcp/init.lua) anpassen

## MQTT

Das ESP8266-Wifi-Relay lässt sich auch via [MQTT](https://primalcortex.wordpress.com/2015/02/06/nodemcu-and-mqtt-how-to-start/) steuern/abfragen. Hierfür bitte [init.lua](/lua-mqtt/init.lua) und [aktor.lua](/lua-mqtt/aktor.lua) verwenden (Achtung: die Dateien müssen angepasst werden).

## Manuelle Steuerung

Wollt ihr an der Platine einen Taster/Schalter anschliesen, bitte dafür **GND / GPIO12** und  **GND / GPIO13** nutzen ( schaltet nach **GND** ) 

## Alternative Steuerungen

Wer die Platine nicht mit SHC betreiben möchte, kann diese natürlich auch über einfache TCP Befehle steuern.

### PHP Script ([tcp.php](/tcp.php))

| Befehl  | Beschreibung | Antwort |
| ------------- | ------------- | ------------- |
| `php tcp.php 192.168.0.62 2x4x1` | Dieses Kommando schaltet **Relais 1** auf **AN** | |
| `php tcp.php 192.168.0.62 2x4x0` | Dieses Kommando schaltet **Relais 1** auf **AUS** | |
| `php tcp.php 192.168.0.62 2x5x1` | Dieses Kommando schaltet **Relais 2** auf **AN** | |
| `php tcp.php 192.168.0.62 2x5x0` | Dieses Kommando schaltet **Relais 2** auf **AUS** | |
| `php tcp.php 192.168.0.62 3x4` | Status vom **Relais 1** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 3x5` | Status vom **Relais 2** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 4x1`  | DHT22 Daten abfragen | Temp;Luftfeuchte |
| `php tcp.php 192.168.0.62 9x0` | Version abfragen | 0.3.2 |
| `php tcp.php 192.168.0.62 0x0` | ESP8266 neustarten | |
| `php tcp.php 192.168.0.62 update datei.lua` | Datei 'datei.lua' hochladen und ESP8266neu starten | | 

*192.168.0.62 ist im obigen Beispiel die IP Adresse des ESP8266*

### HTTP Rückmeldung

Möchte man Rückmeldungen vom manuellen Schalten auswerten geht dieses via HTTP ( der ESP8266 sendet einen HTTP-GET-REQUEST an eine gewünschte Seite - dazu bitte die Zeilen ([init.lua](/lua-tcp/init.lua)) 6, 7, 8, 128, 133, 141, 145, 156, 160, 168, 172 anpassen.

### OpenHab

Beispiel für [OpenHab](http://www.openhab.org/) ( Benötigt PHP auf dem OpenHab Host und das [EXEC Binding](https://github.com/openhab/openhab/wiki/Exec-Binding) )

Bitte in der Items Datei (`<openhab_installation_dir>/configurations/items`) folgendes eintragen:

```
Switch Schalter "Lampe1" {exec=">[ON:php /var/www/tcp.php 192.168.0.62 2x3x1] >[OFF:php /var/www/tcp.php 192.168.0.62 2x3x0]"}
```

*192.168.0.62 ist im obigen Beispiel die IP Adresse des ESP8266*

Für Rückmeldungen in Openhab bitte in der [aktor.lua](/lua-tcp/aktor.lua) folgende zeilen anpassen:
- in Zeile 3 platform="Openhab"
- in zeile 18,20 die ip unter der openhab erreichbar ist
- in zeile 11 ggf den Port anpassen
- in zeile 154,155 die namen der Items die aktualisiert werden sollen


Weitere Informationen über OpenHab findet sich in den [Ersten Schritten](https://openhabdoc.readthedocs.org/de/latest/Beispiel/).

## Sonstige Informationen

### GPIO Mapping

| GPIO  | PIN | [IO index](https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#gpio-new-table--build-20141219-and-later) | Bemerkung |
| ------------- | ------------- | ------------- | ------------- |
| GPIO0 | 18 | 3 | Flashmodus (DS18D20 - ungetestet) |
| GPIO1 | 22 | 10 | UART TX|
| GPIO2 | 17 | 4 | LED (blau) |
| GPIO3 | 21 | 9 | UART RX |
| GPIO4 | 19 | 2 | Relais 1 |
| GPIO5 | 20 | 1 | Relais 2 (oder DHT22) |
| GPIO9 | 11 | 11 | *ungetestet* |
| GPIO10 | 12 | 12 | *ungetestet* |
| GPIO12 | 6 | 6 | Schalter/Taster 1 |
| GPIO13 | 7 | 7 | Schalter/Taster 2 |
| GPIO14 | 5 | 5 | *frei* |
| GPIO15 | 16 | 8 | *frei* |
| GPIO16 | 4 | 0 | *frei* |

![Pinout](/pics/esp8266-pin.png?raw=true)

### Platinen Maße

- 48 mm breit (stark abgerundete Ecken)
- 48 mm lang
- 21 mm tief

### Neue Firmware flashen

Programmiermodus: **GPIO0** und **GND** mit einem Jumper verbinden, ESP8266 neu starten

### ![Achtung](/pics/achtung-yellow.png?raw=true) 10A Erweiterung

Obwohl die Relais mit 10A belastet werden könnten, sind die Leiterbahnen zu den Schraubklemmen zu dünn und sind mit maximal 2A belastbar. Um die volle Belastbarkeit erreichen, muss man an der Unterseite der Platine die Leiterbahnen von den Relaisanschlüssen zur Schraubklemme mit tauglichen Drähten überbrücken/verstärken. (siehe [raspiprojekt.de](https://raspiprojekt.de/kaufen/shop/bausaetze/wifi-relais-zweifach.html))

![10A Erweiterung](/pics/esp8266-10a.png?raw=true)

## Erweiterungen/Ideen (ungetestet)

### Hardware

- Sicherung (z.B. Reichelt *MINI FLINK 1,0A*) vor dem *HLK-PM01* - [Teardown](http://lygte-info.dk/review/Power%20Mains%20to%205V%200.6A%20Hi-Link%20HLK-PM01%20UK.html)
- dahinter MOV (z.B. Reichelt *VDR-0,6 270*)
- Reedkontakt (z.B. Reichelt *KSK 1A66*) als "unsichtbarer" Resetschalter
- DS18B20 Temperatur Sensor
- DHT22 (an **GPIO5** - Pin 1 angeschlossen)
![Config-Page](/pics/dht22.jpg?raw=true)

### Software

- regelmäßiger Restart vom ESP8266
  * Remote Neustart via Skript: `php tcp.php 192.168.0.62 0x0` (siehe oben)
