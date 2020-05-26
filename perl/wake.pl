#!/usr/bin/perl
use feature 'say';
use strict;
use warnings;

#use sudo

#backticks to use system commands from shell `cat` 
#double backslash to unmask

my $dmDirty = `grep '/usr/s\\?bin' /etc/systemd/system/display-manager.service`;
my $dirtyDm = reverse($dmDirty);
my $lastIndex = index($dirtyDm, '/');
my $dm = substr $dmDirty, length($dmDirty)- $lastIndex, length($dmDirty);

say $dm;

my $pathSleep = '/lib/systemd/system-sleep/dis';
#my $pathStart = '/etc/bin/
#`echo "#!/usr/bin/bash\n/usr/bin/dis" > $path`;
#`echo "#!/usr/bin/bash\n/usr/bin/dis" > `;

