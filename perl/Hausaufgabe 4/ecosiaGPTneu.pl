#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize::Chrome;
use HTTP::Cookies::Chrome;
use open qw(:std :utf8);
use Log::Log4perl;
use URI::Escape;
use feature 'say';
use IPC::System::Simple qw(system systemx capture);
use autodie;

my $input;

# Check if ARG is given
if (@ARGV >= 1) {
    $input = join(' ', @ARGV[0..$#ARGV]);  # Konkateniere alle weiteren Elemente ab Index 1
} else {
    # If not, ask for Question
    print "\nBitte geben Sie Ihre Frage ein: ";
    $input = <STDIN>;
    chomp $input;  # Entferne die Zeilenumbrüche am Ende
}

# URL-Vorbereitung
$input = uri_escape($input);  # URL-Encoding
my $url = "https://www.ecosia.org/chat?q=$input";

## ANLEGEN EINES LOGFILE FÜR Log4Perl // Gezwungenermaßen
my $conf = q(
    log4perl.rootLogger = ERROR, LOGFILE
    log4perl.appender.LOGFILE.filename = /tmp/ecosia.log
    log4perl.appender.LOGFILE = Log::Log4perl::Appender::File
    log4perl.appender.LOGFILE.mode = write
    log4perl.appender.LOGFILE.layout = PatternLayout
    log4perl.appender.LOGFILE.layout.ConversionPattern = [%r] %F %L %c - %m%n
);
Log::Log4perl->init(\$conf);
my $logger = Log::Log4perl->get_logger("ecosia");

## ERZEUGUNG DES CHROMEDRIVERS IM GUI MODE MIT COOKIES UND JAVA
my $chromium_exe_path = '/usr/bin/chromium'; 
my $chrome_driver_path = '/usr/bin/chromedriver';
my $mech = WWW::Mechanize::Chrome->new(
    driver   => $chrome_driver_path,
    launch_exe => $chromium_exe_path,
    # headless => 1,  # Hintergrundmodus aktivieren
    cookie_jar => HTTP::Cookies::Chrome->new(
        file => 'cookie.txt',
        autosave => 1,
    ),
);

# Setze den User-Agent mit den Informationen aus dem Header
$mech->agent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');



## AUSBLENDEN DES BROWSERS ÜBER DAS ÜBERFÜHREN AUF EINEN ANDEREN XSERVER PROZESS 
eval {
    $ENV{'DISPLAY'} = ':99';
    local $SIG{__WARN__} = sub { };  # Unterdrückt Warnungen
    local *STDOUT;

# Starte Xvfb im Hintergrund
say "Starte Xvfb im Hintergrund...";
systemx("Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &");

 # Warte, bis Xvfb vollständig gestartet ist
my $xvfb_pid;
for (1 .. 10) {  # Versuche 10 Mal, den Prozess zu finden (warte maximal 10 Sekunden)
    $xvfb_pid = qx/pgrep -f 'Xvfb :99 -screen 0 1024x768x24'/;
    chomp($xvfb_pid);
    last if $xvfb_pid;  # Beende die Schleife, wenn der Prozess gefunden wurde
    sleep(1);
}

# Überprüfe, ob Xvfb gestartet wurde
if ($xvfb_pid) {
    say "Xvfb gestartet mit PID: $xvfb_pid";

    # Starte Chromium im Hintergrund und gib die Ausgabe auf dem Terminal aus
    my $chromium_cmd = "xvfb-run /usr/bin/chromium --remote-debugging-port=9222 --remote-allow-origins=* --disable-gpu --no-sandbox >/dev/null 2>&1 &";
    say "Starte Chromium im Hintergrund...";
    say "Chromium-Ausgabe: " . qx($chromium_cmd 2>&1);

    # Warte kurz, um sicherzustellen, dass Chromium gestartet ist
    say "Warte kurz...";
    sleep(3);

    my $ws_endpoint = $mech->chrome_ws_endpoint;
    say "WebSocket-Endpunkt: $ws_endpoint";

    #Aktiviere JS nachdem Chromium im Hintergrund gestartet wurde
    $mech->eval_in_page('1');  # JavaScript aktivieren


} else {
    say "Fehler beim Starten von Xvfb.";
  }
};



# Navigiere zur Ecosia-Chat Seite
$mech->get($url);

# Warte auf das Laden der Seite
sleep(3);

# Extrahiere die gesamte HTML-Antwort
my $html_content = $mech->content();

# Suche nach dem Text mit einem regulären Ausdruck
my @results;
while ($html_content =~ /<p>(.*?)<\/p>/sg) {
    push @results, $1;
}

# Gib die extrahierten Ergebnisse aus
say "\n\nEcosiaGPT: $results[2]\n";



# Schließe das aktuelle Tab über JavaScript
$mech->eval_in_page('window.close();');

# Schließe den Browser explizit
$mech->close();
