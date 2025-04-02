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
        extra_capabilities => {
            "goog:chromeOptions" => {
                args => [
                    '--remote-debugging-port=9222',
                    '--remote-allow-origins=*',
                    '--disable-gpu',
                    '--no-sandbox',
                    "--user-data-dir=/path/to/your/user/data/directory",
                    "--profile-directory=Profile1",
                ]
            }
        },
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
    my $max_attempts = 2000;  # Anzahl der Versuche
    my $max_wait_time = 30;  # Maximale Wartezeit in Sekunden
    my $wait_interval = 0.1;  # Wartezeit in Sekunden

    my $start_time = time;

    $mech->get($url);  # Webseite aufrufen

    while (1) {
        my $third_p_content = '';

        eval {
            say "Warte auf das Erscheinen des 3. <p>-Elements...";
            my $dom = Mojo::DOM->new($mech->content());
            my $third_p_element = $dom->find('p')->[2];

            if ($third_p_element) {
                $third_p_content = $third_p_element->text;
            }
        };

        if ($third_p_content && $third_p_content =~ /\w+/) {
            # Überprüfe, ob der Text sinnvoll ist (mindestens ein Wort enthalten)
            say "Das 3. <p>-Element ist jetzt vorhanden und enthält sinnvollen Text. Beginne mit der Überwachung der Stabilität.";
            last;
        }

        sleep($wait_interval);

        my $elapsed_time = time - $start_time;
        if ($elapsed_time >= $max_wait_time) {
            say "Maximale Wartezeit von $max_wait_time Sekunden erreicht. Das 3. <p>-Element wurde nicht gefunden oder enthält keinen sinnvollen Text. Programm wird beendet.";
            closeBrowser();
            exit;
        }

        $max_attempts--;
        if ($max_attempts <= 0) {
            say "Maximale Anzahl von Versuchen erreicht. Das 3. <p>-Element wurde nicht gefunden oder enthält keinen sinnvollen Text. Programm wird beendet.";
            closeBrowser();
            exit;
        }
    }
}
sub waitAndActivateChromium {
    my $result = extractContent($mech->content());

    my $stable_duration = 10;  # Minimale stabile Dauer in Sekunden
    my $max_duration = 20;    # Maximale Dauer in Sekunden
    my $stored_text = '';
    my $timing_started = 0;
    my $elapsed_time = 0;
    my $is_stable = 0;

    while (1) {
        if (defined $result && $result ne '') {
            $timing_started = 1;
        }

        my $current_content = $mech->eval_in_page('document.querySelector("p").textContent');
        my $dom = Mojo::DOM->new($current_content);
        my $third_p = $dom->find('p')->[2];
        # ...

        if ($third_p) {
            my $third_p_content = $third_p->text;
            say "Current Content: $third_p_content";  # Debugging-Ausgabe hinzugefügt

            # ...

            if ($third_p_content ne $stored_text) {
                $stored_text = $third_p_content;
                $is_stable = 0;
                say "Text has changed. Resetting is_stable to 0.";  # Debugging-Ausgabe hinzugefügt
                next;

            } else {
                $is_stable++;
                say "is_stable: $is_stable";  # Debugging-Ausgabe hinzugefügt

                if ($is_stable < 70) {
                    next;
                } else {
                    say "Stabiler extrahierter Inhalt: $stored_text";
                    closeBrowser();
                    exit;
                }
            }
        }

        $result = extractContent($mech->content());
        if (defined $result && $result ne '') {
            say "\n\nEcosiaGPT: $result\n";
            processStableContent($stored_text, $is_stable);
            return;  # Hier das Return, um die Funktion zu beenden
        }

        if ($timing_started) {
            sleep(0.1);  # Wartezeit für jeden Versuch
            $elapsed_time += 0.1;

            if ($elapsed_time >= $max_duration) {
                say "Maximale Dauer erreicht ($max_duration Sekunden). Programm wird beendet.";
                processStableContent($stored_text, $is_stable);
                closeBrowser();
                exit;
            }
        }
    }
}

sub processStableContent {
    my ($stored_text, $is_stable) = @_;

    while (1) {
        if ($stored_text) {
            say "Stabiler extrahierter Inhalt: $stored_text";
            last;  # Verlasse die Schleife, wenn stabiler Inhalt gefunden wurde
        } else {
            say "Keine stabilen Ergebnisse gefunden.";
            if ($is_stable >= 5) {  # Änderung: Reduziere die Anzahl der benötigten Stabilitätsiterationen
                closeBrowser();
                exit;
            } else {
                say "Continuing...";
                sleep(1);  # Warte eine Sekunde und versuche es erneut
            }
        }
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
    eval {
        $mech->eval_in_page('window.close();');
        sleep(1);  # Warte eine Sekunde, um sicherzustellen, dass der Browser alle Aktionen abschließen kann
        $mech->close();
    };

    if ($@) {
        say "Fehler beim Schließen des Browsers: $@";
    } else {
        say "Browser geschlossen.";
    }
}
sub stopChromium {
    eval {
        # Beende alle Chromium-Prozesse
        system("pkill -f chromium");
    };
    say "Alle Chromium-Prozesse beendet.";
    if ($@) {
        say "Fehler beim Beenden von Chromium: $@";
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