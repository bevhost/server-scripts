<?php
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-cache");
header("Cache-Control: post-check=0, pre-check=0");
header("Pragma: no-cache");


function reverse($ip_addr) {
        $addr = @inet_pton($ip_addr);
        $len = strlen($addr);
        if ($len==4) { //ip4
                list($a,$b,$c,$d) = explode(".",$ip_addr);
                $reverse = "$d.$c.$b.$a.in-addr.arpa";
        } else
        if ($len==16) { //ip6
                $reverse = "ip6.arpa";
                foreach(str_split($addr) as $char) {
                        $byte = str_pad(dechex(ord($char)), 2, '0', STR_PAD_LEFT);
                        foreach(str_split($byte) as $digit) {
                                $reverse = $digit . "." . $reverse;
                        }
                }
                echo "<br />\n";
        } else {
                $reverse="";
                echo "unexpect len $len";
        }
	return $reverse;
}

error_reporting(E_ALL ^ E_NOTICE);
if ($client = $_GET["client"]) {
	$addr = @inet_pton($client);
	$reverse = reverse($client);
	$host = 0;
	$PTRrecords = dns_get_record($reverse,DNS_ALL);
	foreach ($PTRrecords as $ptr) {
	    if ($ptr["type"]=="PTR") {
		$host = $ptr["target"];
		echo "$client resolves to hostname $host<br>";
		$records = dns_get_record($host);
		$ip = 0; $match = false;
		foreach ($records as $record) {
		    switch($record["type"]) {
			case "AAAA":
				if ($ip = $record["ipv6"]) {
					if (inet_pton($ip) == $addr) $match=true;
					$ips[$ip] = $ip;
				}
				break;
			case "A":
				if ($ip = $record["ip"]) {
					if (inet_pton($ip) == $addr) $match=true;
					$ips[$ip] = $ip;
				}
			default:
		    }
		}
		if (!$ip) echo "Unable to resolve $host back to an IP Address <img src='images/cross.gif' alt=''></img>";
		else {
			$ip = implode (", ",$ips); 
			echo "$host resolves to ip address $ip which is ";
			if (!$match) echo "NOT ";
			echo "a match <img src='images/";
			if (!$match) echo "cross"; else echo "tick";
			echo ".gif' alt=''></img><br>";
		}
	    } else echo $ptr["type"]." ".$ptr["host"]." ".$ptr["target"]."<br>\n";
	} 
	if (!$host) echo "Unable to resolve $client in the DNS <img src='images/cross.gif' alt=''></img>";
	echo "<a href=javascript:ajax(document.myform.client,'md.php?whois=','whois');>";
	echo "Lookup who owns this IP Address Space</a>";
}

if ($helo = $_GET["helo"]) {
	$records = dns_get_record($helo,DNS_ALL);
	$ip = 0;
	foreach($records as $record) {
	    switch($record["type"]) {
		case "AAAA":
			$ip = $record["ipv6"];
			break;
		case "A":
			$ip = $record["ip"];
		default:
	    }
	}
	if (!$ip) echo "Unable to resolve $helo in the DNS <img src='images/cross.gif' alt=''></img>";
	else {
		echo "$helo resolves to $ip<br>\n";
		$reverse = reverse($ip);
		$host = 0;
		$PTRrecords = dns_get_record($reverse,DNS_ALL);
		foreach ($PTRrecords as $ptr) {
		    if ($ptr["type"]=="PTR") {
			$host = $ptr["target"];
			echo "$ip resolves to $host which is ";
			if (strtolower($helo)<>strtolower($host)) echo "NOT ";
			echo "a match <img src='images/";
			if (strtolower($helo)<>strtolower($host)) echo "cross"; else echo "tick";
			echo ".gif' alt=''></img><br>";
		    }
		}
		if (!$host) echo "Unable to resolve $ip in the DNS <img src='images/cross.gif' alt='' title=''></img>";
	}
}


if ($helo = $_GET["spfhelo"]) {
	$ip = $_GET["ip"];
	$sender = $_GET["sender"];
	echo "<p>";
	passthru("/usr/bin/perl -MMail::SPF::Query -le 'print for Mail::SPF::Query->new(helo => shift, ipv4 => shift, sender => shift, myhostname => shift)->result' $helo $ip $sender tools.bevhost.com");	
	echo "</p>";
}

if ($whois = $_GET["whois"]) {
	echo "<pre><a href=javascript:document.getElementById('whois').innerHTML=''>hide</a>\n";
	passthru("whois $whois");	
	echo "</pre>";
}

$email = $_GET["email"];

if ($email) {
	$parts = mb_split("@",$email);
	if (count($parts)<>2) echo "Invalid Email Address <img src='images/cross.gif' alt=''></img><br>";
	else {
		$domain = $parts[1];
                if (!getmxrr($domain,$mx)) {
                        echo "No MX records found for $domain <img src='images/cross.gif' alt=''></img><br>";
                } else {
                        echo "Domain has MX records <img src='images/tick.gif' alt=''></img><br>";
                        foreach ($mx as $text) echo "$text<br>\n";
                }
		$rr = dns_get_record($domain,DNS_TXT);
		if (count($rr)) {
			echo "<b>DNS SPF TEXT Records </b><br>";
			foreach ($rr as $record) 
			foreach ($record as $type=>$value) {
				if ($type=="txt") {
					if (strpos($value,"spf"))
					echo $value."<br>\n";
				}
			}	
		}
	}
}
?>
