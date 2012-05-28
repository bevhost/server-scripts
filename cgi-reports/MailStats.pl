#!/usr/bin/perl
#
# Reporter Viewer
#
require "./cgi-lib.pl";
$cgi_lib'writefiles = "/tmp";	#'
$ret = &ReadParse(*data);
&CgiDie("Error in reading and parsing of CGI input") if !defined $ret;
#&CgiDie("No data uploaded") if !ret;
#use CGI_Lite;
#$cgi = new CGI_Lite ();
#%data = $cgi->parse_form_data ();

$pathname = "/var/log/sendmail/";

print "Content-Type: text/html\n\n";
($progname = $0) =~ s/.*\///;
# Output the Top of the Page
print "<HTML><HEAD><TITLE>";
print "Proxy Usage Report";
print "</TITLE>\n";
print "<!-- Report Viewer -->\n";
print "<!-- COPYRIGHT 1998 -->\n";
print "<!-- New Approach Systems & Software. -->\n";
print "<!-- All Rights Reserved. -->\n";
print "<!-- http://www.nass.com.au/ -->\n";
print "<!-- Y2K-OK! -->\n";
print "</HEAD>\n";
print "<BODY BGCOLOR=\"#ffffff\">";
print "<H2>Mail Statistics Report</H2>\n";

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

while (($key,$value) = each %ENV) {
#       print "<p>$key = $value</p>\n";
	if ( $key eq "REMOTE_HOST" ) { $ClientName = $value; }
}
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
#print "<p>$filename</p>";
opendir(DIR,$filename);
@files = readdir(DIR);
closedir(DIR);

foreach (@files) {

    if (/mailstats/) {


        print "<h3>$_</h3>";
        print "<pre>";
        $logfilename = $filename . "/" . $_;
        open(FILE, $logfilename) || print "Couldn't Open $logfilename : $!";
        $fd = FILE;

        while (<$fd>) {

            print "<p>$_</p>";

        }
        print "</pre>";

        close(FILE);
    }
}

print "</BODY></HTML>\n";

