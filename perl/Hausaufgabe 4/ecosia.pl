#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize::Chrome;
use HTTP::Cookies::Chrome;
use open qw(:std :utf8);
use Log::Log4perl;
use URI::Escape;
use feature 'say';
use IPC::System::Simple qw(systemx);
use autodie;

my $input = @ARGV >= 1 ? join(' ', @ARGV) : getUserInput();

$input = uri_escape($input);
my $url = "https://www.ecosia.org/chat?q=$input";

initializeLogger();

my $mech = createMechInstance();

eval {
    setupXvfb();
};

# Mit vorhandenem Chromium verbinden
my $ws_url = 'ws://127.0.0.1:9222/devtools/browser';
my $ws_client = Protocol::WebSocket::Client->new(url => $ws_url);
$ws_client->connect;

# Warte auf das vorhandene Chromium
waitAndActivateChromium();


navigateToEcosiaChat();
extractAndPrintResults();
closeBrowser();

sub getUserInput {
    print "\nBitte geben Sie Ihre Frage ein: ";
    chomp(my $input = <STDIN>);
    return $input;
}

sub initializeLogger {
    Log::Log4perl->init(\q(
        log4perl.rootLogger = ERROR, LOGFILE
        log4perl.appender.LOGFILE.filename = /tmp/ecosia.log
        log4perl.appender.LOGFILE = Log::Log4perl::Appender::File
        log4perl.appender.LOGFILE.mode = write
        log4perl.appender.LOGFILE.layout = PatternLayout
        log4perl.appender.LOGFILE.layout.ConversionPattern = [%r] %F %L %c - %m%n
    ));
}

sub createMechInstance {
    return WWW::Mechanize::Chrome->new(
        driver   => '/usr/bin/chromedriver',
        launch_exe => '/usr/bin/chromium',
        cookie_jar => HTTP::Cookies::Chrome->new(
            file => 'cookie.txt',
            autosave => 1,
        ),
    );
}

sub setupXvfb {
    say "Starte Chromium im Hintergrund...";
    system("Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &");
    sleep(1);
    system("export DISPLAY=:99; /usr/bin/chromium --remote-debugging-port=9222 --remote-allow-origins=* --disable-gpu --no-sandbox >/dev/null 2>&1 &");
    say "Chromium im Hintergrund gestartet.";
}



sub waitAndActivateChromium {
    my $timeout = 30;  # Zeitlimit für das Warten auf die Verbindung zum Chromium in Sekunden
    my $start_time = time;

    # Warte, bis die Verbindung zu Chromium hergestellt ist oder das Zeitlimit erreicht ist
    while (time - $start_time < $timeout) {
        last if $mech->eval_in_page('1');  # Teste, ob die Verbindung hergestellt ist
        sleep(0.5);
    }

    say "Verbindung zu Chromium hergestellt.";
}

sub navigateToEcosiaChat {
    $mech->get($url);
}

sub isPageLoaded {
    my $ready_state = $mech->eval_in_page('document.readyState');
    return defined $ready_state && $ready_state eq 'complete';
}

sub extractAndPrintResults {
    my $html_content = $mech->content();
    my $result;

    # Versuche, den Inhalt nach 1 Sekunde zu extrahieren
    sleep(1);
    $result = extractContent($html_content);

    # Wenn undef (Fehler) oder leerer String, warte 0.5 Sekunden und versuche erneut
    while (!defined $result || $result eq '') {
        sleep(0.5);
        $result = extractContent($mech->content());
    }

    say "\n\nEcosiaGPT: $result\n";
}

sub extractContent {
    my $html_content = shift;
    my @results;

    # Extrahiere den Inhalt
    while ($html_content =~ /<p>(.*?)<\/p>/sg) {
        push @results, $1;
    }

    # Gib den gewünschten Inhalt zurück (oder undef, wenn nicht gefunden)
    return defined $results[2] ? $results[2] : undef;
}

sub closeBrowser {
    $mech->eval_in_page('window.close();');
    $mech->close();
}
