# ESP8266 Wiki Relay

## Installation

![Anschluss](/anschluss.png?raw=true)

Zum "Debuggen" bitte **GND**, **RX**, **TX** mit [TTL-USB Adapter](http://www.elecfreaks.com/wiki/index.php?title=USB_to_RS232_Converter) verbinden, und **L**, **N** oben Links anschließen.

```

VORSICHT - Sobald L/N (~230V) angeschlossen sind und Netzspannung anliegt, die Platine nicht mehr berühren!

```
## Konfiguration

Sobald Netz-Spannung anliegt, sollte der ESP8266 auf der Rückseite der Platine starten und Blau leuchten, jetzt habt ihr die Möglichkeit die eigentliche Software ([init.lua](/init.lua)) auf dem ESP8266 zu "Speichern".


Dazu bitte die [init.lua](/init.lua) öffen ([alternativer Download](https://drive.google.com/file/d/0ByLsbjUPhHlycGx1UG9objRaZVE/view?usp=sharing)), die WLAN Daten anpassen und die Datei mit dem [ESPlorer](http://esp8266.ru/esplorer/) auf den ESP8266 kopieren ( über Save im ESPlorer ), ist das erfolgreich wird im ESPlorer, der TCP-Server gestartet und es wird die IP vom esp8266 angezeigt


## SHC Schaltserver

Um aus der "Ferne" die Relais zu steuern, hat man die Möglichkeit in [SHC](http://rpi-controlcenter.de/) einen Schalterserver einzutragen mit der IP des WIFI-Relais und Port 9274 ( GPIO lesen JA, GPIO schreiben JA - geeignetes Model z.B. Arduino Nano ) 

Nun kann man unter *Schaltfunktionen* Ausgänge anlegen ( als Schalterserver den neu erstellen auswählen und als GPIO 4/5 )  
Wollt ihr an der Platine einen Taster/Schalter anschliesen, bitte dafür **GND / GPIO12** und  **GND / GPIO13** nutzen ( schaltet nach **GND** ) 

Damit in SHC auch die Rückmeldung funktioniert, wenn manuel schaltet geschaltet wird, muss in der [init.lua](/init.lua) noch folgendes angepasst werden:

- In Zeile 6 und 8 bitte die IP eintragen unter der **SHC** erreichbar ist
- In Zeile 127, 132, 140, 144, 155, 159, 167, 171 bitte **SID** anpassen  ( die SID findet ihr. wenn ihr euch mit Putty einloggt, in das Verzeichnis `/var/www/shc` geht und dort ein `php index.php app=shc -sw –l` eingebt. Nun wird euch eine Liste mit allen schaltbaren Elementen angezeigt, die SID jetzt bitte im [init.lua](/init.lua) anpassen

## Alternative Steuerung

Wer die Platine nicht mit SHC betreiben möchte, kann diese natürlich auch über einfache TCP Befehle steuern.

### PHP Script ([tcp.php](/tcp.php))

Befehl: `php tcp.php 192.168.0.36 2x4x1`
Dieses Kommando schaltet **relay1** auf **AN**

Befehl: `php tcp.php 192.168.0.36 2x4x0`
Dieses Kommando schaltet **relay1** auf **AUS**

Mit `php tcp.php 192.168.0.36 3x4` kann man den status vom relay abfragen antwort wäre `1/0`.

Anstelle von **PIN 4* kann man bei der 2-fach Version auch **PIN 5** verwenden.

Mit `php tcp.php 192.168.0.36 0x0` kann man den ESP8266 neustarten.

### HTTP Rückmeldung

Möchte man Rückmeldungen vom manuellen Schalten auswerten geht dieses via HTTP ( der ESP8266 sendet einen HTTP-GET-REQUEST an eine gewünschte Seite - dazu bitte die Zeilen ([init.lua](/init.lua)) 6, 8, 127, 132, 140, 144, 155, 159, 167, 171 anpassen.

### OpenHab

Beispiel für [OpenHab](http://www.openhab.org/) ( Benötigt PHP auf dem OpenHab Host und das [EXEC Binding](https://github.com/openhab/openhab/wiki/Exec-Binding) )

Bitte in der Items Datei (`configurations/items`) folgendes eintragen:

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
