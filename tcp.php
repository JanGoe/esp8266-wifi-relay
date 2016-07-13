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
@$filename = $argv[3];
$chipIP = $ip;

}

if($was == "update")
{
################################################################################
//$filename = "filebin/$filename";  //adds filebin/ for file IO
$out = file($filename);           // reads file into Array $out   
$filelines = count($out);			//  Number of lines in array
$header = "newfile";				//newfile indicates this is first part of file string.

$filesize = 0;						//rests vars
$x=0; 
$header = "**command**Newfile**\n";   //  headeer defaults to this  changed if looped to more data
//$filenametoESP = substr($filename,8,20)."\n";      // strips filebin
$filenametoESP = $filename."\n";
echo "filenametoESP: $filenametoESP\n";

$datatoESP = "";
	echo trim($filenametoESP);
	echo " Sent to ESP.";
	echo "\n\n";
	echo "************************ Start File *********************************";
	echo "\n";

foreach ($out as $t)
	{
		$filesize = $filesize + strlen($t);    // cumulative string size to trigger a break
		if($t == "\n") {$t = "  ";}				//  removes blank lines
		$datatoESP = $datatoESP.$t;             // builds file string
		$x++;
			if ($filesize > 1200)
				{
					sendtoESP($datatoESP,$header,$filenametoESP,$chipIP);     //  sends data to functon sentoESP resets filesize
					$filesize = 0;
					$datatoESP = "";
					$header = "**command**Apdfile**\n";                         // header now changed to append
				}
			if ($x == $filelines)												// stops the new file or apdfile at last element of array
				{
					if($datatoESP)
						{
			  			  sendtoESP($datatoESP,$header,$filenametoESP,$chipIP);
						}
				}
	}
## Hier nutzen für neustart!
	echo "************************ End File ***********************************\n";
echo "$filenametoESP";
echo "Sent to ESP!\n";
echo "Restart esp...\n";
sleep(5);
senden($ip,"0x0"); ## nach update restarten
exit;
#	echo "<META http-equiv='refresh' content='2;URL=.'>";
################################################################################
}
else{
echo senden($ip,$was);
}

function senden($ip,$was)
{
$fp = fsockopen($ip, "9274", $errno, $errstr, 1);
if (!$fp) {
   echo "$errstr ($errno)";
} else {
   fwrite($fp, $was);
   // folgende Zeile optional - Antwort ausgeben
   if($was == "0x0")
   {
   }
   else{
   while (!feof($fp)) return fgets($fp, 10);
   }
   fclose($fp);
}

}
function sendtoESP($datatoESP,$header,$filenametoESP,$chipIP)
{
	$fp = fsockopen($chipIP, 9274, $errno, $errstr, 10);
		$out = $header.$filenametoESP.trim($datatoESP);
		echo "..\n";
    #echo trim($out);
		fwrite($fp, $out);
    #echo"<b>$out<br>";
		fclose($fp);
		flush($fp); 
}
?>
