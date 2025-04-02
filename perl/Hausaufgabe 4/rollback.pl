
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
use Mojo::DOM;

my $input = @ARGV >= 1 ? join(' ', @ARGV) : getUserInput();

$input = uri_escape($input);
my $url = "https://www.ecosia.org/chat?q=$input";
my $mech;
my $previous_content = '';
my $unchanged_cycles = 0;
initializeLogger();

eval {
    setupXvfb();
    createMechInstance();
    navigateToEcosiaChat();
    waitAndActivateChromium();
    extractAndPrintResults();
};

closeBrowser();
stopXvfb();  # Beende Xvfb nach Ausführung des Programms
stopChromium();

sub createMechInstance {
    say "Erstelle Mechanize-Instanz...";
    eval {
        $mech = WWW::Mechanize::Chrome->new(
            driver   => '/usr/bin/chromedriver',
            launch_exe => '/usr/bin/chromium',
            cookie_jar => HTTP::Cookies::Chrome->new(
                file => 'cookie.txt',
                autosave => 1,
            ),
            extra_capabilities => {
                "goog:chromeOptions" => {
                    args   => [
                        '--remote-debugging-port=9222',
                        '--remote-allow-origins=*',
                        '--disable-gpu',
                        '--no-sandbox',
                    ],
                },
            },
        );
        say "Mechanize-Instanz erfolgreich erstellt.";
     };
    if ($@) {
        say "Fehler beim Erstellen der Mechanize-Instanz: $@";
        # Füge mehr Debug-Informationen hinzu
        say "Chromium-Fehlerausgabe: ", $mech->chrome->stderr->getlines if $mech and $mech->chrome and $mech->chrome->stderr;
     }
    return $mech;
}

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

sub setupXvfb {
    say "Starte Xvfb im Hintergrund...";
    system("Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &");
    say "Xvfb-Prozess Erfolgreich gestartet";
    sleep(4);  # Warte einen Moment, um sicherzustellen, dass Xvfb gestartet wurde

    say "Starte Chromium im Hintergrund...";
    local $ENV{DISPLAY} = ":99";  # Setze das DISPLAY-Umgebungsvariable
    system("/usr/bin/chromium --remote-debugging-port=9222 --remote-allow-origins=* --enable-chrome-browser-cloud-management --disable-software-rasterizer --disable-accelerated-2d-canvas --disable-gpu --no-sandbox >/dev/null 2>&1 &");
    say "Chromium im Hintergrund gestartet.";
    sleep(4);
}

sub navigateToEcosiaChat {
    $mech->get($url);
    sleep(5);
}

sub waitAndActivateChromium {
    my $timeout = 5;  # Zeitlimit für das Warten auf das Laden der Seite in Sekunden
    my $start_time = time;
    my $unchanged_cycles = 0;

    while (time - $start_time < $timeout) {
        my $current_content = $mech->eval_in_page('document.querySelector("p").textContent');

        # Vergleiche den aktuellen Inhalt mit dem vorherigen
        if ($current_content ne $previous_content) {
            $unchanged_cycles = 0;
            $previous_content = $current_content;
            say "Wartezeit: ", sprintf("%.1f", time - $start_time), " Sekunden";
        } else {
            $unchanged_cycles++;
            last if $unchanged_cycles >= 2;  # Warte auf zwei aufeinanderfolgende Zyklen ohne Änderung
        }
        sleep(0.3);
    }

    # Führe nach dem Laden der Seite weitere Aktionen durch (falls erforderlich)
    processExtractedContent();
}

sub processExtractedContent {
    my $html_content = $mech->content();
    my $result = extractContent($html_content);

    say "Extrahierter Inhalt: $result";

    if (defined $result && $result ne '') {
        say "\n\nEcosiaGPT: $result\n";
    } else {
        say "Keine Ergebnisse gefunden.";
    }
}

sub extractContent {
    my $html_content = shift;

    # HTML-Parser initialisieren
    my $dom = Mojo::DOM->new($html_content);

    # Direkt auf das dritte <p>-Element zugreifen
    my $result = $dom->find('p')->[2];

    if ($result) {
        $result = $result->text;
        say "Extrahierter Inhalt: $result";
    } else {
        say "Kein Inhalt gefunden!";
        say "HTML-Inhalt: $html_content";  # Debug-Ausgabe des gesamten HTML-Inhalts
    }

    return $result;
}

sub extractAndPrintResults {
    my $html_content = $mech->content();
    my $result = extractContent($html_content);

    say "Extrahierter Inhalt: $result";

    if (defined $result && $result ne '') {
        say "\n\nEcosiaGPT: $result\n";
    } else {
        say "Keine Ergebnisse gefunden.";
    }
}

sub closeBrowser {
    # Versuche, das Fenster zu schließen
    eval {
        $mech->eval_in_page('window.close();');
        $mech->close();
    };

    if ($@) {
        say "";
    }
}

sub stopChromium {
    eval {
        # Beende alle Chromium-Prozesse
        system("pkill -f chromium");
    };
    say "Alle Chromium-Prozesse beendet.";
    if ($@) {
        say "";
    }
}

sub stopXvfb {
    # Finde den PID
