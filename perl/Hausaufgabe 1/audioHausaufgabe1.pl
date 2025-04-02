use strict;
use warnings;
use feature 'say';

sub process_audio_file {
    my (@args) = @_ ;

    foreach my $file (@args) {

        say "";
        say $file;
        $file = "'$file'";

        # ffprobe und Ausgabe in eine temporäre Datei
        `ffprobe $file > /tmp/ffprobe.tmp 2>&1; cat /tmp/ffprobe.tmp | grep bitrate > /tmp/ffprobe.tmp2 ; cat /tmp/ffprobe.tmp | grep Audio >> /tmp/ffprobe.tmp2`;

        # Dateigröße ermitteln
        my $size = `ls -l $file | awk '{print \$5}'`;
        $size = sprintf("%.2f", $size / 1024 / 1024) . " MB";

        # Dauer ermitteln
        my $duration = `awk 'NR==1 {print \$2}' /tmp/ffprobe.tmp2`;
        my @duration = split '', $duration;
        pop @duration;
        pop @duration;
        
        # Bedingung prüfen: Ist das erste und das zweite Element gleich '0'?
        if (($duration[0] + $duration[1]) == 0) {
            # Wenn ja, führe die Schleife dreimal aus
            for (1..3) {
                # Shift entfernt ein Element vom Anfang des Arrays
                shift @duration;
                pop @duration;
            }
        }

        my $formatted_duration = join('', @duration) . " Min";

        # Bitrate ermitteln
        my $bitrate = `awk 'NR==1 {print \$6\$7}' /tmp/ffprobe.tmp2`;
        my $bitrateNum = substr $bitrate, 0, 3;
        my $formatted_bitrate = "$bitrateNum Kb/s";

        # Dateityp ermitteln
        my $filetype = `awk 'NR==2 {print \$4}' /tmp/ffprobe.tmp2`;
        chop $filetype;
        chop $filetype;
        my $formatted_filetype = ucfirst $filetype;

        # Kanäle ermitteln
        my $channels = `awk 'NR==2 {print \$7}' /tmp/ffprobe.tmp2`;
        chop $channels;
        chop $channels;
        my $formatted_channels = ucfirst $channels;

        say "Dateigröße: $size";
        say "Dauer: $formatted_duration";
        say "Bitrate: $formatted_bitrate";
        say "Dateityp: $formatted_filetype";
        say "Kanäle: $formatted_channels";
}
}
# Beispielaufruf
#my $filepath = '/home/maksim/Musik/Hörbuch/Schröpfkopfbehandlung\ -\ Johann\ Abele\ -\ Haug\ Verlag/';
#my $filename = 'Kapitel\ 2\ -\ Schröpfkopfbehandlung\ Hörbuch.mp3';

process_audio_file(@ARGV);