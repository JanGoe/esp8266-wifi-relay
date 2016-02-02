<body bgcolor="#393939" >
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg .tg-lkll{background-color:#cb0000;vertical-align:top}
.tg .tg-zes0{font-weight:bold;text-decoration:underline;background-color:#656565;color:#ffffff;vertical-align:top}
.tg .tg-y0xi{background-color:#32cb00;vertical-align:top}
</style>
<center>
<table class="tg" style="undefined;table-layout: fixed; width: 685px">
<colgroup>
<col style="width: 31px">
<col style="width: 101px">
<col style="width: 101px">
<col style="width: 151px">
<col style="width: 101px">
<col style="width: 100px">
<col style="witdh: 100px">
</colgroup>
  <tr>
    <th class="tg-zes0">ID</th>
    <th class="tg-zes0">ChipID</th>
    <th class="tg-zes0">Heap</th>
    <th class="tg-zes0">LastOnline</th>
    <th class="tg-zes0">IP</th>
    <th class="tg-zes0">Version</th>
    <th class="tg-zes0">Relay 1/2</th>
  </tr>
<?php
$con = mysql_connect("localhost", "USERNAME", "PASSWORD") or die("Verbindungs fehler:". mysql_error());
$db = mysql_select_db("esp8266") or die("Datenbank Select ERROR!". mysql_error()); 
$online = 0;
#echo '';
#echo'<center><table wihte="600"><tr><td >ID</td><td>chipID</td><td>Heap</td><td>Last Online</td><td>IP</td></tr>';
$action = $_GET[action];
if($action == "set" && !empty($_GET[ip]) && !empty($_GET[cmd]))  { senden($_GET[ip], $_GET[cmd]); $action=""; }

$sql = mysql_query("SELECT * FROM esp8266_online");
while($daten = mysql_fetch_array($sql))
{
	$r1 = ""; 
	$r2 = "";
$date = date("H:i:s d.m.y", $daten[time]);
if($daten[time] > time()-120) { 
	$class = "tg-y0xi"; 
	$online++;
	if(empty($_GET[fast])) {
		#$version = senden($daten[ip], "9x0");
		#$r1 = senden($daten[ip], "3x4");
		#$r2 = senden($daten[ip], "3x5");
			if($daten[r1] == 1) { $r11 = "AUS"; $cmd1="1"; } else { $r11 = "AN"; $cmd1="0"; } 
			if($daten[r2] == 1) { $r22 = "AUS"; $cmd2="1"; } else { $r22 = "AN"; $cmd2="0";} 
		$status = "<a href=?action=set&ip=$daten[ip]&cmd=2x4x$cmd1>$r11</a> / <a href=?action=set&ip=$daten[ip]&cmd=2x5x$cmd2>$r22</a>";
	}
}
else { $class= "tg-lkll"; $version=""; $status=""; }
#echo"<table><tr><td>$daten[id]</td><td>$daten[chipid]</td><td>$daten[heap]</td><td>$date</td><td>$daten[ip]</td></tr>";
echo"
  <tr>
    <td class=$class>$daten[id]</td>
    <td class=$class>$daten[chipid]</td>
    <td class=$class>$daten[heap]</td>
    <td class=$class>$date</td>
    <td class=$class>$daten[ip]</td>
    <td class=$class>$daten[version]</td>
    <td class=$class>$status</td>
  </tr>";

}
echo"</table><br><br><font face='Arial, sans-serif'> Online:<b>$online</b></face>";


function senden($ip,$was)
{
$fp = fsockopen($ip, "9274", $errno, $errstr, 1);
if (!$fp) {
   echo "$errstr ($errno)";
} else {
   fwrite($fp, $was);
   // folgende Zeile optional - Antwort ausgeben
   while (!feof($fp)) return fgets($fp, 10);
   fclose($fp);
}
}

?>