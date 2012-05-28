#! /usr/bin/perl
# $Id: sm.logger,v 1.3 92/08/25 16:00:34 drich Exp Locker: drich $
#
# Copyright (C) 1992  Daniel Rich
#
# Author: Daniel Rich (drich@lerc.nasa.gov)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# A copy of the GNU General Public License can be obtained from this
# program's author (send electronic mail to ange@hplb.hpl.hp.com) or from
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA
# 02139, USA.
#
# sm.logger - parse the sendmail log and produce a summary
#
# $Log:	sm.logger,v $
# Revision 1.3  92/08/25  16:00:34  drich
# Fixed divide by zero error if no mail either delivered or sent.
# 
# Revision 1.2  92/08/05  14:03:14  drich
# Replaced '=' with '-' in output report
# 
# Revision 1.1  92/07/22  16:36:54  drich
# Logfile processor for sendmail
#
#
# Written by Dan Rich - drich@lerc.nasa.gov
#     Wed July 22, 1992
#

require "./cgi-lib.pl";
$cgi_lib'writefiles = "/tmp";
$ret = &ReadParse(*data);
&CgiDie("Error in reading and parsing of CGI input") if !defined $ret;
#&CgiDie("No data uploaded") if !ret;
#use CGI_Lite;
#$cgi = new CGI_Lite ();
#%data = $cgi->parse_form_data ();

$logfile = "maillog";
$filename = "/var/log/sendmail/";
$pathname = $filename;

# Change the following for the appropriate system type.
$systype = "Linux";		# Valid are Ultrix, Sun, SGI, RS6000, Solaris
# Linux Added by David Beveridge davidb@nass.com.au April 1999.

# Change the following to the local sendmail domain
$local_domain = "nass.com.au";

if (! ($MAILLOG = shift)) {
LOOP: {
    if ( $systype eq "SGI")    { $MAILLOG = "/usr/adm/SYSLOG"; 
				 last LOOP; }
    if ( $systype eq "Ultrix") { $MAILLOG = "/usr/spool/mqueue/syslog";
				 last LOOP; }
    if ( $systype eq "Sun")    { $MAILLOG = "/var/adm/messages";
				 last LOOP; }
    if ( $systype eq "Linux")  { $MAILLOG = "/var/log/maillog";
				 last LOOP; }
    if ( $systype eq "Solaris"){ $MAILLOG = "/var/log/syslog";
				 last LOOP; }
    if ( $systype eq "RS6000") { $MAILLOG = "/var/adm/messages";
				 last LOOP; }
    print "This script does not support the system type: $systype"; exit(1);
}
}

sub parse_mail_addr {
    local($addr) = @_;
    # Attempt to parse an address down to an *originating* user and host.
    # Assume the address takes one of the following forms:
    #     user@host.domain
    #     host!host!host!user
    #     host!host!host!user@host.domain
    #	  @host.domain:user@host.domain

    $user = "";
    $host = "";
    $domain = "";

    # Get rid of <> in address
    $addr =~ s/\<//g;
    $addr =~ s/\>//g;

    # Get rid of (Real Name)
    $addr =~ s/\(.*\)//;

    # Strip spaces
    $addr =~ s/ //g;

    # Split user and host
    if ( $addr =~ /[@!]/ ) {		# If we have and @ or ! address
        if ( (($user,$host) = ($addr =~ /@.*:(.*)@(.*)/ )) || 
	     (($user,$host) = ($addr =~ /(.*)@(.*)/ )) ) {
            if ( $user =~ /!/ ) {
	        ( $host, $user ) = ( $user =~ /([^!]*)!([^!]*)$/ );
            }
        } else {			# Ok, it is uucp format
            if ( $addr =~ /!/ ) {
	        ( $host, $user ) = ( $addr =~ /([^!]*)!([^!]*)$/ );
            }
        }
    } else {				# This had better be local...
        $user = $addr;
	$host = "";
	$domain = "";
    }

    # Split host and domain
    if ( $host =~ /\./ ) {
        ($host,$domain) = ( $host =~ /([^.]*)\.(.*)/ );
    }

    return ($user, $host, $domain);
}

sub format_addr {
    local($username, $host, $domain) = @_;

    $addr = "";
    $username =~ tr/A-Z/a-z/;
    $host =~ tr/A-Z/a-z/;
    $domain =~ tr/A-Z/a-z/;

    if ((length($domain) != 0) && ($domain ne $local_domain)) {
        $addr = $username. "@" . $host . "." . $domain;
    } elsif (length($host) != 0 ) {
	$addr = $username. "@" . $host;
    } else {
        $addr = $username;
    }
    return $addr;
}

sub format_host {
    local($host, $domain) = @_;

    $addr = "";
    $host =~ tr/A-Z/a-z/;
    $domain =~ tr/A-Z/a-z/;

    if (($domain eq $local_domain) || 
	(($host . "." . $domain) eq $local_domain) ||
	(length($domain) == 0)) {
        $addr = "local";
    } else {
        $addr = $host . "." . $domain;
    }
    return $addr;
}
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

printf ("<H1>Sendmail activity report</H1>\n");

while (($key,$value) = each %data ) {
#       print "<p>$key = $value</p>";
        if ( $key eq "Month" ) { $Month = $value; }
        if ( $key eq "Year" ) { $Year = $value; }
}
$ClientName = $ENV{"REMOTE_HOST"};
$Month = $data{"Month"};
$Year = $data{"Year"};

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

$filename = "/var/log";

opendir(DIR,$filename);
@files = readdir(DIR);
closedir(DIR);

$start_date = "";
$start_time = "";

foreach (@files) {

    if (/maillog/) {


        #print "<p>$_</p>";
        $logfilename = $filename . "/" . $_;
        open(FILE, $logfilename) || print "Couldn't Open $logfilename : $!";
#open ( MAILLOG ) || die "failed to open log file: $!\n";
        $fd = FILE;

        while (<$fd>) {



#while ( <MAILLOG> ) {
    $line = "";
    ( $systype eq "SGI" ) && ( /sendmail\[[0-9]*\]:/ && ($line = $_) );
    ( $systype eq "Sun" ) && ( /sendmail\[[0-9]*\]:/ && ($line = $_) );
    ( $systype eq "Linux" ) && ( /sendmail\[[0-9]*\]:/ && ($line = $_) );
    ( $systype eq "Solaris" ) && ( /sendmail\[[0-9]*\]:/ && ($line = $_) );
    ( $systype eq "Ultrix") && ( /sendmail:/ && ($line = $_) );
    if ( length($line) == 0 ) {
	next;
    }

    if ( length($start_date) == 0 ) {
        ($start_date, $start_time) = 
	    ($line =~ /^([A-Z][a-z]* *[0-9]*) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9])/);
    }
    ($end_date, $end_time) = 
	($line =~ /^([A-Z][a-z]* *[0-9]*) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9])/);
	
    if (($ID, $addr) = ($line =~/: ([A-Za-z0-9]*): to=(.*), delay/)) {
        if ( $line =~ /stat=Sent/ ) {
            foreach $taddr (split(/,/, $addr)) {
                ($username, $host, $domain) = &parse_mail_addr($taddr);
                $user = &format_addr($username, $host, $domain);
                $host = &format_host($host, $domain);
                $userlist{$user} = 1;
                $delivered{$user} .= $ID . ' ';
    	        $hostlist{$host} = 1;
                $delivered{$host} .= $ID . ' ';
                # Check if it was deferred
                $IDlist = $deferred{$user};
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
    	                $deferred{$user} =~ s/$ID //g;
                    }
                }
                $IDlist = $deferred{$host};
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
    	                $deferred{$host} =~ s/$ID //g;
                    }
                }
            }
        } elsif ( $line =~ /stat=Deferred/ ) {
            foreach $taddr (split(/,/, $addr)) {
                ($username, $host, $domain) = &parse_mail_addr($taddr);
                $user = &format_addr($username, $host, $domain);
                $host = &format_host($host, $domain);
                $userlist{$user} = 1;
    	        $hostlist{$host} = 1;
                # Check if it was deferred earlier
                $IDlist = $deferred{$user};
		$IDdeferred = 0;
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
    	                $IDdeferred = 1;
                    }
                }
		if ( $IDdeferred == 0 ) {$deferred{$user} .= $ID . ' ';}
                $IDlist = $deferred{$host};
		$IDdeferred = 0;
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
    	                $IDdeferred = 1;
                    }
                }
		if ( $IDdeferred == 0 ) {$deferred{$host} .= $ID . ' ';}
            }
        } else {
            foreach $taddr (split(/,/, $addr)) {
                ($username, $host, $domain) = &parse_mail_addr($taddr);
                $user = &format_addr($username, $host, $domain);
                $host = &format_host($host, $domain);
                $IDlist = $deferred{$user};
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
                        $deferred{$user} =~ s/$ID //g;
                        last;
                    }
                }
                $IDlist = $deferred{$host};
                foreach $tID (split(/ /, $IDlist)) {
                    if ( $tID == $ID ) {
        		    $deferred{$host} =~ s/$ID //g;
                        last;
                    }
                }
            }
        }
    }
    if (($ID, $addr, $size) = ($line =~/: ([A-Za-z0-9]*): from=(.*), size=([0-9]*)/)) {
        ($username, $host, $domain) = &parse_mail_addr($addr);
        $user = &format_addr($username, $host, $domain);
	$host = &format_host($host, $domain);
        $userlist{$user} = 1;
        $sent{$user} .= $ID . ' ';
        $hostlist{$host} = 1;
        $sent{$host} .= $ID . ' ';
        $size{$ID} = $size;
    }
}
}
}

printf ("<p>Starting: %s %s<br>\n",$start_date,$start_time);
printf ("Ending: %s %s</p>\n",$end_date,$end_time);

print "<pre>";
#
# User statistics
$totsent = 0;
$totdelivered = 0;
$totpctsent =0;
$totpctdelivered = 0;
$countsent = 0;
$countdelivered = 0;
$countdeferred = 0;
foreach $user (sort keys(%userlist)) {
    $totsent{$user} = 0;
    $totdelivered{$user} = 0;
    $countsent{$user} = 0;
    $countdelivered{$user} = 0;
    $countdeferred{$user} = 0;

    # Count total messages sent by each user
    $IDlist = $sent{$user};
    foreach $ID (split(/ /, $IDlist)) {
	$totsent{$user} += $size{$ID};
        $countsent{$user}++;
    }
    $totsent += $totsent{$user};
    $countsent += $countsent{$user};

    # Count total messages received by each user
    $IDlist = $delivered{$user};
    foreach $ID (split(/ /, $IDlist)) {
	$totdelivered{$user} += $size{$ID};
        $countdelivered{$user}++;
    }
    $totdelivered += $totdelivered{$user};
    $countdelivered += $countdelivered{$user};

    # Count deferred messages for each user
    $IDlist = $deferred{$user};
    foreach $ID (split(/ /, $IDlist)) {
        $countdeferred{$user}++;
    }
    $countdeferred += $countdeferred{$user};
}

printf ("\n\n");
$REPORTFMT = "%-20s %5s %8s\n";
$REPORTNUM = "%-20s %5d %8d\n";
printf ($REPORTFMT,"Message Status","Total","Size");
printf ("-----------------------------------\n");
printf ($REPORTNUM,"Received",$countsent,$totsent);
printf ($REPORTNUM,"Delivered",$countdelivered,$totdelivered);
printf ($REPORTNUM,"Deferred",$countdeferred);
printf ("\n\n</pre>");
printf ("<H2>User Statistics:</h2><pre>\n");
$REPORTFMT = "%-30s %6s %8s %7s %6s %8s %7s\n";
$REPORTNUM = "%-30s %6d %8d %6.2f%% %6d %8d %6.2f%%\n";
printf ($REPORTFMT,"User Name","# from","size","%","# to","size","%");
printf ($REPORTFMT,"---------","------","--------","------","------","--------","------");
foreach $user (sort keys(%userlist)) {
    $percent1 = 0;
    $percent2 = 0;

    $percent1 = ($totsent{$user}/$totsent)*100		    if ($totsent != 0);
    $percent2 = ($totdelivered{$user}/$totdelivered)*100    if ($totdelivered != 0);
    printf ($REPORTNUM,substr($user,0,30),
	$countsent{$user},$totsent{$user},$percent1,
	$countdelivered{$user},$totdelivered{$user},$percent2);
    $totpctsent += $percent1;
    $totpctdelivered += $percent2;
}
printf ("------------------------------------------------------------------------------\n");
printf ($REPORTNUM,"Totals",$countsent,$totsent,$totpctsent,$countdelivered,$totdelivered,$totpctdelivered);

# 
# Host statistics
foreach $host (sort keys(%hostlist)) {
    $totsent{$host} = 0;
    $totdelivered{$host} = 0;
    $countsent{$host} = 0;
    $countdelivered{$host} = 0;
    $countdeferred{$host} = 0;

    # Count total messages sent by each host
    $IDlist = $sent{$host};
    foreach $ID (split(/ /, $IDlist)) {
	$totsent{$host} += $size{$ID};
        $countsent{$host}++;
    }

    # Count total messages received by each host
    $IDlist = $delivered{$host};
    foreach $ID (split(/ /, $IDlist)) {
	$totdelivered{$host} += $size{$ID};
        $countdelivered{$host}++;
    }
}

printf ("\n\n</pre><h2>Host Statistics:</h2><pre>\n\n");
$REPORTFMT = "%-30s %6s %8s %7s %6s %8s %7s\n";
$REPORTNUM = "%-30s %6d %8d %6.2f%% %6d %8d %6.2f%%\n";
printf ($REPORTFMT,"Host Name","# from","size","%","# to","size","%");
printf ($REPORTFMT,"---------","------","--------","------","------","--------","------");
foreach $host (sort keys(%hostlist)) {
    $percent1 = 0;
    $percent2 = 0;

    $percent1 = ($totsent{$host}/$totsent)*100		    if ($totsent != 0);
    $percent2 = ($totdelivered{$host}/$totdelivered)*100    if ($totdelivered != 0);
    printf ($REPORTNUM,substr($host,0,30),
	$countsent{$host},$totsent{$host},$percent1,
	$countdelivered{$host},$totdelivered{$host},$percent2);
}
printf ("------------------------------------------------------------------------------\n");
printf ($REPORTNUM,"Totals",$countsent,$totsent,$totpctsent,$countdelivered,$totdelivered,$totpctdelivered);

        print "</pre>";
print "</BODY></HTML>\n";



