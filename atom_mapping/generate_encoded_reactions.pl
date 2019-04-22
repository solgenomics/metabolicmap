
use strict;
use Data::Dumper;

my $file = shift;

open(my $F, "<", $file) || die "Can't open file $file. Sorry.\n";

my @s;
while (<$F>) {
    chomp;
    if (/^\/\//) {
	my $out = parse_record(@s);
	print $out."\n";
	@s = ();
    }
    else { 
	push @s, $_;
    }
}
    
sub parse_record {
    my @lines = @_;

    my @from;
    my @to;
    my @index;
    my $out;
    
    foreach my $l (@lines ) {
	if ($l =~ m/^REACTION/) {
	    print STDERR "processing reaction $l...\n";
	}

	my @infos;
	if ($l =~ m/^FROM-SIDE/) {
	    #print STDERR "processing line $l...\n";
	    @from = parse_line($l);
	    foreach my $f (@from) {
		#print STDERR "FROM: ".Dumper($f);
		$out .= convert($f, @index);
		$out .= " ";
	    }
	}

	if ($l =~ m/^TO-SIDE/) {
	    $out .= " ---> ";
	    #print STDERR "processing line $l...\n";
	    @to = parse_line($l);
	    foreach my $t (@to) {
		#print STDERR "TO: ".Dumper($t);
		$out .=  convert($t, @index);
		$out .= " ";
	    }
	}
	
	if ($l =~ m/^INDICES/) {
	    @index = split / /, $l;
	    shift @index; shift @index;
	}
    }
    return $out;
    
}

sub convert {
    my ($info, @index) = @_;
    my $conversion = "";
    foreach my $i ($info->{start}.. $info->{end}) {
	#print STDERR "converting... $index[$i] ".chr($i+65)."\n";
	$conversion .= chr($i+65);
    }
    return $conversion;
}



sub parse_line {
    my $line = shift;
    my @tokens = tokenize($line);
    foreach (1..2) { shift @tokens; } # remove row label
    my @infos;
    my $info;
    my $index =0;
    foreach my $t (@tokens) {
	#print STDERR "processing token $t...\n";
	if ($t eq "(") {
	    $info = {};
	    $index = 0;
	}
	elsif ($t eq ")") {
	    push @infos, $info;
	    $info = {};
	    $index = 0;
	}
	
	else {
	    $index++;   
	    if ($index == 1) { $info->{compound} = $t; }
	    if ($index == 2) { $info->{start} = $t; }
	    if ($index == 3) { $info->{end} = $t; }
	    
	}
    }
    #print STDERR "Infos: ".Dumper(\@infos);
    return @infos;
}
	
		    
    
sub tokenize {
    my $s = shift;

    my @chars = split//, $s;

    my @tokens;
    my @token;
    for (my $n=0; $n<@chars; $n++) {
	if ($chars[$n] eq " ") {
	    if (@token) { push @tokens, join("", @token); }
	    @token = ();
	}

	elsif ($chars[$n] eq "(") {
	    @token = ();
	    push @tokens, "(";
	}

	elsif ($chars[$n] eq ")") {
	    push @tokens, join("", @token);
	    @token = ();
	    push @tokens, ")";
	}

	else {
	    push @token, $chars[$n];
	}
    }

    #print STDERR Dumper(\@tokens);
    return @tokens;
}
       
