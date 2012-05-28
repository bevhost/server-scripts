#!/usr/bin/perl
#
# MailUsage.pl 
#
# Summary:
#         This PERL script reads Sendmail Log files from standard in
# and writes an HTML summary of the data to standard out.

require "./cgi-lib.pl";
$cgi_lib'writefiles = "/tmp";	#'
$ret = &ReadParse(*data);
&CgiDie("Error in reading and parsing of CGI input") if !defined $ret;
#&CgiDie("No data uploaded") if !ret;
#use CGI_Lite;
#$cgi = new CGI_Lite ();
#%data = $cgi->parse_form_data ();

#$stdin = STDIN;
$logfile = "info";
$filename = "/var/log/mail/";
$pathname = $filename;
$rate = 0.00000020;

$mailforwardsfile = "/tmp/mailforwards";
$virtusertable = "/etc/mail/virtusertable";
$mailertable = "/etc/mail/mailertable";
$accessfile = "/etc/mail/access";

#This command needs to be run as root to update the userlist file
#system "cat /home/*/.forward > /tmp/mailforwards";

print "MIME-Version: 1.0\n";
print "Content-Type: text/html\n\n";
($progname = $0) =~ s/.*\///;
# Output the Top of the Page
print "<HTML><HEAD><TITLE>";
print "New Approach Internet e-Mail Usage Report";
print "</TITLE>\n";
print "<!-- Internet Usage Reporter -->\n";
print "<!-- COPYRIGHT 1998 -->\n";
print "<!-- New Approach Systems & Software. -->\n";
print "<!-- All Rights Reserved. -->\n";
print "<!-- http://www.nass.com.au/ -->\n";
print "</HEAD>\n";
print "<BODY BGCOLOR=\"#ffffff\"><CENTER>";
print "<H2>Usage Report</H2>\n";

@Week_Days = ('Sunday','Monday','Tuesday','Wednesday',
              'Thursday','Friday','Saturday');

@Months = ('January','February','March','April','May','June','July',
           'August','September','October','November','December');

@Years = ('1999','2000','2001','2002','2003');

($Second,$Minute,$Hour,$Month_Day,
$Month,$Year,$Week_Day,$IsDST) = (localtime)[0,1,2,3,4,5,6,8];

$Year = $Year - 99;    # Subtract first $Years[] value & add 1900.
if ($Month_Day < 10) {
    $Month_Day = "0$Month_Day";
}

while (($key,$value) = each %data ) {
#       print "<p>$key = $value</p>";
        if ( $key eq "Month" ) { $Month = $value; }
        if ( $key eq "Year" ) { $Year = $value; }
}
$ClientName = $ENV{"REMOTE_HOST"};
$Month = $data{"Month"};
$Year = $data{"Year"};

open(FILE, $mailforwardsfile ) || print "Couldn't Open $mailforwardsfile";
while (<FILE>) {
        chomp;
        $user_relay_billable{$_} = 1;
}
close(FILE);

open(FILE, $virtusertable ) || print "Couldn't Open virtusertable";
while (<FILE>) {
        @line = split;
        $source = shift @line;
        $dest = shift @line;
        if (/@/) { $user_relay_billable{$dest} = 1; }
}
close(FILE);

open(FILE, $accessfile ) || print "Couldn't Open $accessfile";
while (<FILE>) {
        @line = split;
        $source = shift @line;
        $dest = shift @line;
        if (/RELAY/) { $host_relay_billable{$source} = 1;  }
}
close(FILE);

open(FILE, $mailertable ) || print "Couldn't Open $mailertable";
while (<FILE>) {
        @line = split(/[[]/);
        $host = shift @line;
        $host = shift @line;
        chop $host;
        chop $host;
        $host_relay_billable{$host} = 1;
}
close(FILE);

print "<FORM METHOD=\"POST\" ACTION=\"$progname\">";
print "<SELECT NAME=\"Month\">\n";
$m = 0;
foreach (@Months) {
        print "<OPTION ";
        if ($Months[$Month] eq $_ ) { print "SELECTED "; }
        print "VALUE=\"$m\">$_\n";
        $m += 1;
}
print "</SELECT>\n";

print "<SELECT NAME=\"Year\">\n";
$y = 0;
foreach (@Years) {
        print "<OPTION ";
        if ($Years[$Year] eq $_ ) { print "SELECTED "; }
        print "VALUE=\"$y\">$_\n";
        $y += 1;
}
print "</SELECT>\n";
print "<INPUT TYPE=\"SUBMIT\" VALUE=\"Display Report\">";
print "</FORM>\n";


$filename = $pathname . $Years[$Year] . "/" . $Months[$Month];
 	#print "<p>$filename</p>";

$filename = "/var/log";

opendir(DIR,$filename);
@files = readdir(DIR);
closedir(DIR);


foreach (@files) {

    if (/maillog/) {


    	#print "<p>$_</p>";
	$logfilename = $filename . "/" . $_;
	open(FILE, $logfilename) || print "Couldn't Open $logfilename : $!";
	$fd = FILE;

	while (<$fd>) {

	    if (/ipop3d/) {
		next;		# Skip over POP3 Log Entries.
	    }  


	    # Grab the current line
	    @line = split;
    
	    $month = shift @line;
	    $day = shift @line;
	    $time = shift @line;
	    $catagory = shift @line;
	    $program = shift @line;
	    $queueid = shift @line;


	    # Skip unqueued mail / errors
	    if ($queueid eq "NONQUEUE:") {
		next;
	    }

#	    $multiplier = substr($bytestr,-1,1);
#	    if ($multiplier eq 'K') { $bytes = $bytestr * 1024; }
#	    elsif ($multiplier eq 'M') { $bytes = $bytestr * 1048576; }
#	    elsif ($multiplier eq 'G') { $bytes = $bytestr * 1073741824; }
#	    else { $bytes = $bytestr; }
	$to="";		$from="";	$cltaddr="";	$delay="";
	$xdelay="";	$mailer="";	$relay="";	$stat="";
	$bytes=0;	$class="";	$nrcpts=0;	$msgid="";
	$proto="";
	    $datastr = shift @line;
	    while ( $datastr ) {
	        $last_char = substr($datastr,-1,1);
	        while ($last_char ne ',') {
		  $addonstr = shift @line;
		  if ($addonstr) { $datastr .= $addonstr; }
		  else { $datastr .= ','; }
	          $last_char = substr($datastr,-1,1);
#		  print "$datastr";
	      	}
		chop($datastr);
		$_ = $datastr;
		if (/to=/) { $to = substr($datastr,3); }
		elsif (/from=/) { $from = substr($datastr,5); }
		elsif (/cltaddr=/) { $cltaddr = substr($datastr,8); }
		elsif (/delay=/) { $delay = substr($datastr,6);  }
		elsif (/xdelay=/) { $xdelay = substr($datastr,7);  }
		elsif (/mailer=/) { $mailer = substr($datastr,7); }
		elsif (/relay=/) { $relay = substr($datastr,6); }
		elsif (/stat=/) { $stat = substr($datastr,5); }
		elsif (/size=/) { $bytes = substr($datastr,5); }
		elsif (/class=/) { $class = substr($datastr,6); }
		elsif (/nrcpts=/) { $nrcpts = substr($datastr,7); }
		elsif (/msgid=/) { $msgid = substr($datastr,6); }
		elsif (/proto=/) { $proto = substr($datastr,6); }
	        $datastr = shift @line;
	    }

	    
	    if (substr($to,0,1) eq '<') { $to = substr($to,1); }
	    if (substr($to,-1,1) eq '>') { chop($to); }

	    if (substr($from,0,1) eq '<') { $from = substr($from,1); }
	    if (substr($from,-1,1) eq '>') { chop($from); }

	    if ($bytes) { $inbound = "TRUE"; $incount++; }
	    else { $inbound = ''; $outcount++; }
	    # Add this line to the Totals
 	    if ($bytes) {
	    	$message_size{$queueid} = $bytes;
		$message_from{$queueid} = $from;
#			print "$bytes from $from";
#			print " to $to relay $relay mailer $mailer \n";
		if ($relay) {
		    $relay_from_count{$relay}++;
		    $relay_from_total{$relay} += $bytes;
		}
	    } else {
		$bytes = $message_size{$queueid};
		if ($to) {
		$msgfrom = $message_from{$queueid};
		@HostParts = split(/\@/,$msg_from);
	    	$delivered_count{$queueid}++;
#		$msgfrom = shift @HostParts;
#		$msgfrom = shift @HostParts;
		$user_from_count{$msgfrom}++;
		$user_from_total{$msgfrom} += $bytes;
		if ($mailer eq "local") {
		    $host_local_count{$to}++;
		    $host_local_total{$to} += $bytes;
		} else {
		    $_ = $relay;
		    if (/compuserve/) {$relay = "compuserv.com"; }
                    if ( substr($stat,0,4) eq "Sent" )
                    {
                        $host_relay_count{$relay}++;
                        $host_relay_total{$relay} += $bytes;
                        $user_relay_count{$to}++;
                        $user_relay_total{$to} += $bytes;
		    }
#if ($relay) {
#	print "$bytes from $message_from{$queueid}";
#	print " to $to relay $relay mailer $mailer \n";
#}
		}
		}
	    }
	}

	close(FILE);
    }
}
	print "\nMail In:$incount, Out:$outcount\n";

	print "<H2>Delivered to Local Mailbox</H2>";
	print "<CENTER>\n";
	print "<table border=\"1\" width=\"90%\">\n";
	print "<tr align=\"CENTER\">";
	print "<td>MailBox</td>";
	print "<td>Count</td>";
	print "<td>Total (Bytes)</td>";
	print "<td>Total Cost</td>";
        print "<td>inc GST</td>";
	print "</tr>\n";
	$total_cost = 0;
	foreach $key (keys %host_local_total) {
		$cost = $host_local_total{$key} * $rate;
		print "<tr align=\"RIGHT\">";
		print "<td align=\"CENTER\">$key</td>";
		print "<td>$host_local_count{$key}</td>";
		print "<td>$host_local_total{$key}</td>";
		print "<td>$cost</td>";
                $cost *= 1.1;
                print "<td>$cost</td>";
		print "</tr>\n";
	}
	print "</table>\n";
	print "</CENTER>\n";

        print "<H2>Relay to User</H2>";
        print "<CENTER>\n";
        print "<table border=\"1\" width=\"90%\">\n";
        print "<tr align=\"CENTER\">";
        print "<td>Relay To User</td>";
        print "<td>Count</td>";
        print "<td>Total (Bytes)</td>";
        print "<td>Total Cost</td>";
        print "<td>inc GST</td>";
        print "</tr>\n";
        $total_cost = 0;
        foreach $key (keys %user_relay_total) {
                if ( $user_relay_billable{$key} == 1 )
                {
                        $cost = $user_relay_total{$key} * $rate;
                        print "<tr align=\"RIGHT\">";
                        print "<td align=\"CENTER\">$key</td>";
                        print "<td>$user_relay_count{$key}</td>";
                        print "<td>$user_relay_total{$key}</td>";
                        print "<td>$cost</td>";
                        $cost *= 1.1;
                        print "<td>$cost</td>";
                        print "</tr>\n";
                }
        }
        print "</table>\n";
        print "</CENTER>\n";


	print "<H2>Relay to Host</H2>";
	print "<CENTER>\n";
	print "<table border=\"1\" width=\"90%\">\n";
	print "<tr align=\"CENTER\">";
	print "<td>Relay To Host</td>";
	print "<td>Count</td>";
	print "<td>Total (Bytes)</td>";
	print "<td>Total Cost</td>";
        print "<td>inc GST</td>";
	print "</tr>\n";
	$total_cost = 0;
	foreach $key (keys %host_relay_count) {
	    @line = split(/[[]/,$key);
	    $host = shift @line;
	    chop $host;
            if ( $host_relay_billable{$host} == 1 )
            {
		$cost = $host_relay_total{$key} * $rate;
		print "<tr align=\"RIGHT\">";
		print "<td align=\"CENTER\">$key</td>";
		print "<td>$host_relay_count{$key}</td>";
		print "<td>$host_relay_total{$key}</td>";
		print "<td>$cost</td>";
                $cost *= 1.1;
                print "<td>$cost</td>";
		print "</tr>\n";
	    }
	}
	print "</table>\n";
	print "</CENTER>\n";

        print "<H2>Received From Host</H2>";
        print "<CENTER>\n";
        print "<table border=\"1\" width=\"90%\">\n";
        print "<tr align=\"CENTER\">";
        print "<td>Relay From</td>";
        print "<td>Count</td>";
        print "<td>Total (Bytes)</td>";
        print "<td>Total Cost</td>";
        print "<td>inc GST</td>";
        print "</tr>\n";
        $total_cost = 0;
        foreach $key (keys %relay_from_total) {
	    @line = split(/[[]/,$key);
	    $host = shift @line;
	    $host = shift @line;
	    @line = split(/[]]/,$host);
	    $host = shift @line;
            if ( $host_relay_billable{$host} == 1 )
            {
                $cost = $relay_from_total{$key} * $rate;
                print "<tr align=\"RIGHT\">";
                print "<td align=\"CENTER\">$key</td>";
                print "<td>$relay_from_count{$key}</td>";
                print "<td>$relay_from_total{$key}</td>";
                print "<td>$cost</td>";
                $cost *= 1.1;
                print "<td>$cost</td>";
                print "</tr>\n";
	    }
        }
        print "</table>\n";
        print "</CENTER>\n";

        print "<H2>Mail Received by Sender more than 2 dollars</H2>";
        print "<CENTER>\n";
        print "<table border=\"1\" width=\"90%\">\n";
        print "<tr align=\"CENTER\">";
        print "<td>User From</td>";
        print "<td>Count</td>";
        print "<td>Total (Bytes)</td>";
        print "<td>Total Cost</td>";
        print "<td>inc GST</td>";
        print "</tr>\n";
        $total_cost = 0;
        foreach $key (keys %user_from_total) {
                $cost = $user_from_total{$key} * $rate;
	  if ($cost>2) {
                print "<tr align=\"RIGHT\">";
                print "<td align=\"CENTER\">$key</td>";
                print "<td>$user_from_count{$key}</td>";
                print "<td>$user_from_total{$key}</td>";
                print "<td>$cost</td>";
                $cost *= 1.1;
                print "<td>$cost</td>";
                print "</tr>\n";
          }
        }
        print "</table>\n";
        print "</CENTER>\n";



print "</BODY></HTML>\n";

#1;

