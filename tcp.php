<?php
if(!empty($_GET[0]))
{
$ip = $_GET['wo'];
$was = $_GET[was];
echo"$ip and $was";
}
if(!empty($argv[0]))
{

$ip = $argv[1];
$was = $argv[2];
}


echo senden($ip,$was);


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
