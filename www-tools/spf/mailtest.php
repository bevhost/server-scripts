<?php

$client = $_REQUEST["client"];
switch( strlen( inet_pton( $client ) ) ) {
 case 16:
	$addr = "IPV6:".$client;
	$server = "[2607:f878:1:668::84]"; break;
 default:
	$addr = $client;
	$server = "96.9.149.84"; break;
}
$sender = $_REQUEST["sender"];
$recip  = "nobody@tools.bevhost.com";
$helo   = $_REQUEST["heloname"];

$ptr = gethostbyaddr($client);
if ($ptr==$client) {
	$ptr="unknown";
	$name=$helo;
} else $name=$ptr;
if (!$helo) $helo = $name;

function send($fp,$text) {
	echo htmlentities("$text\n");
	fputs($fp,"$text\n");
}
function receive($fp,$c=0) {
	echo fread($fp,1000);
}

echo "<pre>Connecting to $client\n";
$fp = fsockopen($server,25,$errno,$errtext,5);
fread($fp,1000);
fputs($fp,"EHLO test\n");
fread($fp,1000);
fputs($fp,"XCLIENT NAME=$helo ADDR=$addr\n");
receive($fp);
send($fp,"HELO $helo");
receive($fp);
send($fp,"MAIL FROM: <".$sender.">");
receive($fp);
send($fp,"RCPT TO: <".$recip.">");
receive($fp);
send($fp,"QUIT");
receive($fp);
fclose($fp);

?>
