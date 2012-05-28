<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<head><title>Mail Server Diagnostics - Accessplus</title>
<style type="text/css">
body { font-family: arial, verdana; }
div#whois { float: right; }
h3 { color:red; }
</style>
<script type="text/javascript">
<!--
function ajax(el,url,outputdiv)
{
var xmlHttp;

try
  // Firefox, Opera 8.0+, Safari
  { xmlHttp=new XMLHttpRequest(); }
catch (e)
  {
  // Internet Explorer
  try { xmlHttp=new ActiveXObject("Msxml2.XMLHTTP"); }
  catch (e)
    {
    try { xmlHttp=new ActiveXObject("Microsoft.XMLHTTP"); }
    catch (e)
      { alert("Your browser does not support AJAX!"); return false; }
    }
  }
  xmlHttp.onreadystatechange=function()
    {
    if(xmlHttp.readyState==4)
      {
        target = document.getElementById(outputdiv);
	target.innerHTML=xmlHttp.responseText;
	document.body.style.cursor = "default";
      }
    }
  xmlHttp.open("GET",url+el.value,true);
  xmlHttp.send(null);
  document.body.style.cursor = "wait";
}
function error(e,n) {
	alert('Please enter a valid '+n);
	e.focus();
}
function validate(f) {
	if (f.client.value.length<7) { error(f.client,"IP Address"); return false; }
	if (f.sender.value.length<5) { error(f.sender,"Sender"); return false; }
	if (f.heloname.value.length<1) { error(f.helo,"Computer Name"); return false; }
	return true;
}
function check_spf() {
    document.getElementById("spfdetails").innerHTML = "";
    if (validate(document.myform)) {
	helo = document.myform.heloname.value;
	client = document.myform.client.value;
	ajax(document.myform.sender,"md.php?spfhelo="+helo+"&ip="+client+"&sender=","spfdetails");
    }
}
function server_test() {
    document.getElementById("serverresponse").innerHTML = "";
    if (validate(document.myform)) {
        helo = document.myform.heloname.value;
        client = document.myform.client.value;
        ajax(document.myform.sender,"mailtest.php?heloname="+helo+"&client="+client+"&sender=","serverresponse");
    }
} 
-->
</script>
</head>
<body>
<div id=whois></div>


<h1>Beveridge Hosting - SPF Test</h1>

<noscript><h3>This page requires JavaScript to be Enabled</h3></noscript>

<form name=myform onsubmit="return validate(this);" method='post' action='mailtest.php'>

<h2>Email Origin</h2>
Sending IP Address
<input name=client onblur='ajax(this,"md.php?client=","clientdetails");'>
<div id=clientdetails></div>

<h2>Sender Details</h2>
Sender Email Address
<input name=sender onblur='ajax(this,"md.php?email=","senderdetails");'>
<div id=senderdetails></div>

<h2>Host Name HELO / EHLO</h2>
Senders Computer Name
<input name=heloname onblur='ajax(this,"md.php?helo=","helodetails");'>
<div id=helodetails></div>

<br>
<a href='javascript:check_spf()'>SPF Check</a>
<div id=spfdetails></div>
<br>
<a href='javascript:server_test()'>Perform Live Server Test</a>
<div id=serverresponse></div>
<br>

</form>

<hr><a href="http://www.bevhost.com">www.bevhost.com</a> <a href="/">Other Tools</a> by 
<a href="http://www.beveridge.id.au/david">David Beveridge</a>
<br><p><hr></p>
<?php include "../phplib/subnav.inc"; ?>
</body></html>
