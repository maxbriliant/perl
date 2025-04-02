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

initializeLogger();

my $mech = createMechInstance();

eval {
    setupXvfb();
    navigateToEcosiaChat();
    waitAndActivateChromium();
    extractAndPrintResults();
};

closeBrowser();
stopXvfb();  # Beende Xvfb nach Ausführung des Programms
stopChromium();

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
        extra_capabilities => { "goog:chromeOptions" => { args => [ '--headless', '--disable-gpu' ] } },
    );
}

sub setupXvfb {
    say "Starte Chromium im Hintergrund mit Xvfb...";
    system("Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &");
    sleep(1);  # Warte einen Moment, um sicherzustellen, dass Xvfb gestartet wurde
    $ENV{DISPLAY} = ":99";
    say "Chromium im Hintergrund gestartet.";
}

sub navigateToEcosiaChat {
    $mech->get($url);
    sleep(0.1);
}

sub waitAndActivateChromium {
    # Warte 1 Sekunde
    sleep(9);

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

    my $stable_duration = 2;  # Minimale stabile Dauer in Sekunden
    my $max_duration = 20;    # Maximale Dauer in Sekunden
    my $stored_text = '';
    my $timing_started = 0;
    my $elapsed_time = 0;

    while ($elapsed_time < $max_duration) {
        if (defined $result && $result ne '' && !$timing_started) {
            $timing_started = 1;
        }

        my $current_content = $mech->eval_in_page('document.querySelector("p").textContent');

        my $dom = Mojo::DOM->new($current_content);

        my $third_p = $dom->find('p')->[2];

        if ($third_p) {
            my $third_p_content = $third_p->text;

            # Starte die Zeitmessung, wenn der echte String im 3. <p> scope erscheint
            if ($third_p_content) {
                $stored_text = $third_p_content;
            }

            # Vergleiche den aktuellen Inhalt mit dem vorherigen
            if ($third_p_content ne $stored_text) {
                $stored_text = $third_p_content;
            } else {
                last if $elapsed_time >= $stable_duration;  # Wenn die stabile Dauer erreicht ist, breche die Schleife ab
            }
        }

        $result = extractContent($mech->content());
        if (defined $result && $result ne '') {
            say "\n\nEcosiaGPT: $result\n";
            closeBrowser();
            exit;
        }

        if ($timing_started) {
            sleep(0.1);  # Wartezeit für jeden Versuch
            $elapsed_time += 0.1;
        }
    }

    say "Keine Ergebnisse gefunden. Maximale Dauer erreicht ($max_duration Sekunden). Programm wird beendet.";
    closeBrowser();
    exit;
}

sub processStableContent {
    my $stored_text = shift;

    my $html_content = $mech->content();
    my $result = extractContent($html_content);

    if (defined $result && $result ne '') {
        say "Stabiler extrahierter Inhalt: $result";
    } else {
        say "Keine stabilen Ergebnisse gefunden.";
    }
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
    # Finde den PID des Xvfb-Prozesses
    my $xvfb_pid = qx/pgrep -f 'Xvfb :99 -screen 0 1024x768x24'/;
    chomp($xvfb_pid);

    if ($xvfb_pid) {
        # Beende den Xvfb-Prozess
        system("kill $xvfb_pid");
        say "Xvfb-Prozess mit PID $xvfb_pid beendet.";
    } else {
        say "Xvfb-Prozess nicht gefunden.";
    }
}