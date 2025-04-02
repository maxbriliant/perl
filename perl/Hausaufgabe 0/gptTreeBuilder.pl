use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;

my $url = 'https://www.ecosia.org/search?q=sudo%20mount%20remount%20rw&addon=opensearch';
my $ua = LWP::UserAgent->new;

$ua->default_header('Referer' => 'https://www.ecosia.org/');
$ua->default_header('Accept-Language' => 'en-US,en;q=0.5');

my $content = $ua->get($url)->decoded_content;
my $tree = HTML::TreeBuilder->new->parse($content);

# Extrahiere H1-Überschriften
my @headings_h1 = $tree->look_down('_tag', 'h1');

# Extrahiere H2-Überschriften
my @headings_h2 = $tree->look_down('_tag', 'h2');

# Ausgabe der H1-Überschriften
print "H1-Überschriften:\n";
foreach my $heading (@headings_h1) {
    my $heading_text = $heading->as_text || '';
    my $section_text = '';

    # Suche nach einem gemeinsamen Elternelement (z.B., ein Div-Tag)
    my $parent_element = $heading->parent;
    if ($parent_element) {
        # Extrahiere den Textinhalt des Elternelements
        $section_text = $parent_element->as_text || '';
    }

    # Kodiere die Ausgabe als UTF-8
    utf8::encode($heading_text);
    utf8::encode($section_text);

    print "Überschrift: $heading_text\nTextabschnitt: $section_text\n";
}

# Ausgabe der H2-Überschriften
print "\nH2-Überschriften:\n";
foreach my $heading (@headings_h2) {
    my $heading_text = $heading->as_text || '';
    my $section_text = '';

    # Suche nach einem gemeinsamen Elternelement (z.B., ein Div-Tag)
    my $parent_element = $heading->parent;
    if ($parent_element) {
        # Extrahiere den Textinhalt des Elternelements
        $section_text = $parent_element->as_text || '';
    }

    # Kodiere die Ausgabe als UTF-8
    utf8::encode($heading_text);
    utf8::encode($section_text);

    print "Überschrift: $heading_text\nTextabschnitt: $section_text\n";
}

# Wichtig: Den Baum erst nach der Verwendung zerstören
$tree->delete;