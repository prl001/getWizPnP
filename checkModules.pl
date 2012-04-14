#!/usr/bin/perl
#!/opt/perlbrew/perls/perl-5.12.3/bin/perl

use strict;
use warnings;

use File::Spec::Functions qw(splitdir);

my %checkedModule;
my %osOptional = (
    Win32 => { Win32 => 1,  cygwin => 1 },
);

my %optional = (
    'IO::Socket::Multicast'
	=> 'you will need to use --host to connect to your Beyonwiz devices',
    'IO::Interface::Simple' =>
	=> '--longNames will use IP addresses instead'
	 . ' of the shorter host addresses',
    'Win32'
	=> 'getWizPnP will use a restricted port range for HTTP access' . "\n"
	 . '    and --check may run slower than if Win32 is available',
);

sub moduleName($) {
    my ($file) = @_;
    $file =~ s/\.pm$//;
    my @module = splitdir($file);
    return join '::', @module;
}

sub addLocalModule($) {
    my ($file) = @_;
    $checkedModule{moduleName($file)} = 1;
}

sub checkRequire(*$$) {
    my ($module, $type, $inFile) = @_;
    return 1 if($checkedModule{$module});
    $checkedModule{$module} = 1;
    eval "require $module";
    my $ok = 1;
    if($@) {
	chomp $@;
	$ok = 0;
	if($@ =~ /^Can't locate /) {
	    if((!exists $osOptional{$module} || $osOptional{$module}->{$^O})) {
		$@ = 'Can\'t locate ' . $module . ' in file ' . $inFile . "\n";
		if($type eq 'Beyonwiz::Utils::tryUse') {
		    $@ .= "    $module is optional";
		    $@ .= ", but\n    $optional{$module}"
		        if($optional{$module});
		    $ok = 1;
		} else {
		    $@ .= "    $module is required";
		}
	    } else {
		$@ = '';
		$ok = 1;
	    }
	}
	warn "$@\n" if($@);
    }
    return $ok;
}

sub process($) {
    my ($file) = @_;
    if(!open F, '<', $file) {
	warn "Can't open $file: $!\n";
	return 0;
    }

    my $moduleIdMatch = '[[:alpha:]_][[:word:]]*(::[[:alpha:]_][[:word:]]*)*';
    my $errors;

    while(<F>) {
	chomp;
	if(/^\s*(require|use)\s+($moduleIdMatch).*;\s*(#.*)?$/o
	|| /^.*(Beyonwiz::Utils::tryUse)\s+($moduleIdMatch).*;\s*(#.*)?$/o) {
	    $errors++ if(!checkRequire $2, $1, $file);
	}
    }
    return !$errors;
}

my $error;

@ARGV = map { glob $_ } @ARGV if($^O eq 'MSWin32');

foreach my $file (@ARGV) {
    addLocalModule $file if($file =~ /\.pm$/);
}

foreach my $file (@ARGV) {
    $error++ if(!process $file);
}

exit($error ? 1 : 0)
