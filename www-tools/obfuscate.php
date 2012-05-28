<html>
<head>
<meta http-equiv="Content-Type"
content="text/html; charset=iso-8859-1">
<LINK REL=stylesheet HREF="/html4.css">
<title>Email Address Obfuscator</title>
<style>body{font-family:arial,verdana;}</style>
</head>
<body>
<h1>Email Address Obfuscator</h1>
<hr>
<p>Use this form to create the HTML for placing your obfuscated email address onto web pages so no spammer can harvest it</p>
<form method=post>

    <blockquote>
        <p>Email Address:<br>
		<input type="text" size="50" maxlength="50" name="email" value="<?php echo $_REQUEST["email"]; ?>"> <br>
        </p>
    </blockquote>
    <p><input type="submit" value="Submit Form">
    <input type="reset" value="Reset Form">&nbsp;
    <a href="/cgi-bin/dnslookup">Clear Form</a></p>
    <blockquote>
        <p>(Optional) Display Name:<br>
		 <input type="text" size="50" maxlength="50" name="name" value="<?php echo $_REQUEST["name"]; ?>"> <br>
        </p>
	<p>(Optional) Spam Trap:<br>
		 <input type="text" size="50" maxlength="50" name="spamtrap" value="<?php echo $_REQUEST["spamtrap"]; ?>"> <br>
	</p>
    </blockquote>

</form>
<p>The generated code will only appear as a clickable mailto: link on java enabled browsers, otherwise just text</p>


<?php 

function hashed($str) {
        for ($i=0;$i<strlen($str);$i++) {
                $ch = substr($str,$i,1);
                $out .= "&#".ord($ch).";";
        }       
	return $out;
}       

if ($email=$_REQUEST['email']) {
        $name=$_REQUEST['name'];
        $bl=$_REQUEST['spamtrap'];
        list($box,$domain) = mb_split('@',$email);
        $hashbox = hashed($box);
        $pos = floor(strlen($domain)/2);
        $d1 = substr($domain,0,$pos);
	$d2 = substr($domain,$pos,1);
	$d3 = substr($domain,$pos+1,200);
	$h1 = hashed($d1);
	$h2 = hashed($d2);
	$h3 = hashed($d3);
	if (!$bl) $bl = "blacklistme@smtp.accesplus.com.au";
	$bl = " $bl ";
	$clr = "<span class='oe_first'><span>$hashbox</span><span class='oe_special'>$bl</span><span>".hashed('@')."</span></span>";
	$clr .= "<span class='oe_second'><span>$d1<span class='oe_special'>$bl</span>$d2</span><span>$h3</span></span>";
	$out = "<style type='text/css'>.oe_special{display:none;}.oe_first,.oe_second{display:inline;}</style>\n";
	$out .= "<noscript>";
	$out .= $clr;
	$out .= "</noscript>\n";
	$out .= "<script type='text/javascript'><!--\n";
	$out .= "document.write('<a href=\"');document.write('".hashed('mail')."');document.write('".hashed('to:')."');\n";
	$out .= "document.write('$hashbox');document.write('@$h1');document.write('$h2$h3');\n";
	$out .= "document.write('\">');";
	if (!$name) $name = $clr;
	$out .= "document.write(\"$name</a>\");";
	$out .= "\n--></script>\n";
	
	echo "<hr><blockquote>$out<br><textarea rows=10 cols=80>".htmlentities($out)."</textarea><br>";
	echo "<small>Click in the box then ^A ^C to Copy All</small></blockquote>";
	
}

?> 
<hr><a href="http://www.bevhost.net">www.bevhost.net</a> <a href="/">Other Tools</a>
</body>
</html>
