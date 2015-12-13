# ESP8266-Wifi-Relay

## Installation

![Anschluss](/anschluss.png?raw=true)

```

VORSICHT - Sobald L/N (~230V) angeschlossen sind und Netzspannung anliegt, die Platine nicht mehr berühren!

```
## Konfiguration

Als ersten Schritt **GND**, **RX**, **TX** mit einem [TTL-USB Adapter](http://www.elecfreaks.com/wiki/index.php?title=USB_to_RS232_Converter) verbinden. Dann **L**, **N** anschließen (siehe Anschlussplan).

Sobald Netz-Spannung anliegt, sollte der ESP8266 auf der Rückseite der Platine starten und Blau leuchten. Jetzt habt ihr die Möglichkeit die eigentliche Software ([init.lua](/lua-tcp/init.lua)) auf dem ESP8266 zu "Speichern".

Dazu bitte die [init.lua](/lua-tcp/init.lua) öffen, die WLAN Daten anpassen und die Datei mit dem [ESPlorer](http://esp8266.ru/esplorer/) auf den ESP8266 kopieren (über *Save* im ESPlorer). Nach dem erfolgreichen Übertragen, wird automatisch der TCP-Server gestartet und es wird die IP vom ESP8266 angezeigt (rechtes Fenster).

![ESPlorer](/esplorer.png?raw=true)

## SHC Schaltserver

Um aus der "Ferne" die Relais zu steuern, hat man die Möglichkeit in [SHC](http://rpi-controlcenter.de/) einen Schalterserver einzutragen mit der IP des ESP8266-Wifi-Relay und Port 9274 ( GPIO lesen JA, GPIO schreiben JA - geeignetes Model z.B. Arduino Nano ) 

Nun kann man unter *Schaltfunktionen* Ausgänge anlegen ( als Schalterserver den neu erstellen auswählen und als **GPIO4/5** )  

Damit in SHC auch die Rückmeldung funktioniert, wenn manuel schaltet geschaltet wird, muss in der [init.lua](/lua-tcp/init.lua) noch folgendes angepasst werden:

- In Zeile 6 und 8 bitte die IP eintragen unter der **SHC** erreichbar ist
- In Zeile 109,110 bitte **SID** anpassen  ( die SID findet ihr. wenn ihr euch mit Putty einloggt, in das Verzeichnis `/var/www/shc` geht und dort ein `php index.php app=shc -sw –l` eingebt. Nun wird euch eine Liste mit allen schaltbaren Elementen angezeigt, die SID jetzt bitte im [init.lua](/lua-tcp/init.lua) anpassen

## MQTT

Das ESP8266-Wifi-Relay lässt sich auch via [MQTT](https://primalcortex.wordpress.com/2015/02/06/nodemcu-and-mqtt-how-to-start/) steuern/abfragen. Hierfür bitte [init.lua](/lua-tcp/aktor.lua) und [aktor.lua](/lua-tcp/aktor.lua) verwenden (Achtung: die Dateien müssen angepasst werden).

## Manuelle Steuerung

Wollt ihr an der Platine einen Taster/Schalter anschliesen, bitte dafür **GND / GPIO12** und  **GND / GPIO13** nutzen ( schaltet nach **GND** ) 

## Alternative Steuerungen

Wer die Platine nicht mit SHC betreiben möchte, kann diese natürlich auch über einfache TCP Befehle steuern.

### PHP Script ([tcp.php](/tcp.php))

| Befehl  | Beschreibung | Antwort |
| ------------- | ------------- | ------------- |
| `php tcp.php 192.168.0.62 2x4x1` | Dieses Kommando schaltet **Relais 1** auf **AN** | |
| `php tcp.php 192.168.0.62 2x4x0` | Dieses Kommando schaltet **Relais 1** auf **AUS** | |
| `php tcp.php 192.168.0.62 3x4` | Status vom **Relais 1** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 2x5x1` | Dieses Kommando schaltet **Relais 2** auf **AN** | |
| `php tcp.php 192.168.0.62 2x5x0` | Dieses Kommando schaltet **Relais 2** auf **AUS** | |
| `php tcp.php 192.168.0.62 3x5` | Status vom **Relais 2** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 0x0` | ESP8266 neustarten | |

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

Auch hier für Rückmeldungen bitte die [OpenHab REST-API](https://github.com/openhab/openhab/wiki/REST-API) nutzen und die Zeilen 6, 8, 127, 132, 140, 144, 155, 159, 167, 171 anpassen.

Weitere Informationen über OpenHab findet sich in den [Ersten Schritten](https://openhabdoc.readthedocs.org/de/latest/Beispiel/).

## Sonstige Informationen

### Platinen Maße

- 48 mm breit (stark abgerundete Ecken)
- 48 mm lang
- 21 mm tief

### Neue Firmware flashen

Programmiermodus: **GPIO0** und **GND** mit einem Jumper verbinden, ESP8266 neu starten

## Erweiterungen/Ideen (ungetestet)

### Hardware

- Sicherung (z.B. Reichelt *MINI FLINK 1,0A*) vor dem *HLK-PM01* - [Teardown](http://lygte-info.dk/review/Power%20Mains%20to%205V%200.6A%20Hi-Link%20HLK-PM01%20UK.html)
- dahinter MOV (z.B. Reichelt *VDR-0,6 270*)
- Reedkontakt (z.B. Reichelt *KSK 1A66*) als "unsichtbarer" Resetschalter
- DS18B20 Temperatur Sensor

### Software

- regelmäßiger Restart vom ESP8266
  * Remote Neustart via Skript: `php tcp.php 192.168.0.62 0x0` (siehe oben)
