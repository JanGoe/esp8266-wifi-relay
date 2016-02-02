<?php
# debug.php
## mysql verbindung herstellen!
$con = mysql_connect("localhost", "USERNAME", "PASSWORD") or die("Verbindungs fehler:". mysql_error());
$db = mysql_select_db("esp8266") or die("Datenbank Select ERROR!". mysql_error()); 

# load vars
$chipid = mysql_real_escape_string($_GET[chipid]);
$heap = mysql_real_escape_string($_GET[heap]);
$version = mysql_real_escape_string($_GET[version]);
$ip = $_SERVER[REMOTE_ADDR];
$r1 = mysql_real_escape_string($_GET[r1]);
$r2 = mysql_real_escape_string($_GET[r2]);

## checken ob chip-id schon in db aktiv ist
$query = mysql_query("SELECT chipid,id FROM esp8266_online where chipid='$chipid'");
$daten = mysql_fetch_array($query);
if(empty($daten[id])) {
$time = time();
echo"new";
$insert = mysql_query("INSERT INTO `esp8266`.`esp8266_online` (`id`, `chipid`, `heap`, `time`, `ip`, `version`, `r1`,`r2`) VALUES (NULL, '$chipid', '$heap', '$time', '$ip', '$version','$r1', '$r2');");
}
if(!empty($daten[id])) {
echo"set=1&relay=1";
$time = time();
$update =mysql_query("UPDATE esp8266_online SET heap='$heap',time='$time',ip='$ip',version='$version',r1='$r1',r2='$r2' WHERE chipid=$chipid;");
}
?>