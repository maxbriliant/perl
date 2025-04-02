#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize::Chrome;
use HTTP::Cookies::Chrome;
use open qw(:std :utf8);
use Log::Log4perl;
use URI::Escape;
use feature 'say';
use IPC::System::Simple qw(systemx capture);
use autodie;

my $input = @ARGV >= 1 ? join(' ', @ARGV) : getUserInput();

$input = uri_escape($input);
my $url = "https://www.ecosia.org/chat?q=$input";

initializeLogger();

my $mech = createMechInstance();

eval {
    setupXvfb();
    navigateToEcosiaChat();
    waitAndActivateChromium();
    extractAndPrintResults();
};

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
        extra_capabilities => { "goog:chromeOptions" => { detach => 1 } },
    );
}

sub setupXvfb {
    say "Starte Chromium im Hintergrund...";
    system("Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &");
    sleep(1);  # Warte einen Moment, um sicherzustellen, dass Xvfb gestartet wurde
    system("export DISPLAY=:99; /usr/bin/chromium --remote-debugging-port=9222 --remote-allow-origins=* --disable-gpu --no-sandbox >/dev/null 2>&1 &");
    say "Chromium im Hintergrund gestartet.";
}

sub navigateToEcosiaChat {
    $mech->get($url);
    sleep(0.1);
}

sub waitAndActivateChromium {
    # Warte 1 Sekunde
    #sleep(3);

    my $result = extractContent($mech->content());

    # Überprüfe, ob ein Ergebnis vorliegt
    if (defined $result && $result ne '') {
        say "\n\nEcosiaGPT: $result\n";
        closeBrowser();
        exit;
    }

    # Führe nach dem Laden der Seite weitere Aktionen durch (falls erforderlich)
    # Aktiviere JS oder andere Aktionen
    $mech->eval_in_page('1');

    # Pausiere schrittweise länger und zeige die aktuelle Wartezeit an
    my $max_attempts = 300;
    my $wait_time = 0.3;  # Anfängliche Wartezeit in Sekunden
    for my $attempt (1 .. $max_attempts) {
        say "Wartezeit: $wait_time Sekunden";

        sleep($wait_time);

        $result = extractContent($mech->content());
        if (defined $result && $result ne '') {
            say "\n\nEcosiaGPT: $result\n";
            closeBrowser();
            exit;
        }

        # Verdopple die Wartezeit für den nächsten Versuch
        $wait_time += 0.3;
    }

    say "Keine Ergebnisse gefunden. Programm wird beendet.";
    closeBrowser();
    exit;
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

sub extractAndPrintResults {
    my $html_content = $mech->content();
    my $result = extractContent($html_content);

    if (defined $result && $result ne '') {
        say "\n\nEcosiaGPT: $result\n";
    } else {
        say "Keine Ergebnisse gefunden.";
    }
}

sub closeBrowser {
    $mech->eval_in_page('window.close();');
    $mech->close();
}


#sub stopXvfb {
#    # Finde den PID des Xvfb-Prozesses
#    my $xvfb_pid = qx/pgrep -f 'Xvfb :99 -screen 0 1024x768x24'/;
#    chomp($xvfb_pid);

#    if ($xvfb_pid) {
#        # Beende den Xvfb-Prozess
#        system("kill $xvfb_pid");
#        say "Xvfb-Prozess mit PID $xvfb_pid beendet.";
#    } else {
#        say "Xvfb-Prozess nicht gefunden.";
#    }
#}


#stopXvfb();