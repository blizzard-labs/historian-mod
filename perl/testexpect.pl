#!/usr/bin/env perl

use warnings;
use File::Temp;

die "Usage: $0 <prog> <args...> <expected>" unless @ARGV >= 3;
my $expectFail = 0;
if ($ARGV[$#ARGV] eq "-fail") {
    $expectFail = 1;
    pop @ARGV;
}
my $expected = pop @ARGV;
my ($prog, @args) = @ARGV;

die "Can't find file $expected" unless -e $expected;

my $fh = File::Temp->new();
my $fname = $fh->filename;

system "$prog @args >$fname";
my $exitCode = $?;

my $diff = `diff $fname $expected`;

if ($exitCode && !$expectFail) {
    print "`$prog @args` returned exit code $exitCode\n";
    die;
} elsif (length $diff) {
    print "`$prog @args` does not match $expected:\n";
    print `diff -y $fname $expected`;
    print "not ok: `$prog @args`\n";
    die;
} else {
    print "ok: `$prog @args` matches $expected\n";
}
