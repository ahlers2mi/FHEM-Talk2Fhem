#!/usr/bin/perl
# angelegt von Claude 04.11.2026: Talk2Fhem ohne FHEM laden und Saetze auswerten (nur Parser, nichts wird geschaltet)
# Aufruf: perl t/harness.pl <modul.pm> <talk_device.json> <saetze.txt>
use strict; use warnings; no warnings qw(redefine once uninitialized);
use JSON::PP;
package main;
use vars qw(%defs %attr %modules $init_done); $init_done = 1;
my ($modfile, $devjson, $satzfile) = @ARGV;
my $raw = do { local $/; open my $f, '<', $devjson or die $!; <$f> };
$raw = substr($raw, index($raw, '{'));
my $dev = JSON::PP->new->utf8(0)->decode($raw);
my $name = 'talk';
# Erwartet JSON mit {"def": "<DEF>", "attributes": {...}} (Format von get_device des FHEM-MCP)
$attr{$name} = $dev->{attributes};
sub Log3 { print STDERR "LOG$_[1]: $_[2]\n" if ($ENV{T2F_LOG}||0) >= $_[1]; }
sub AttrVal { my ($d,$a,$def)=@_; $d = $d->{NAME} if ref $d; return exists $attr{$d}{$a} ? $attr{$d}{$a} : $def; }
sub ReadingsVal { return $_[2] }
sub IsDisabled { 0 } sub asyncOutput {} sub notifyRegexpChanged {}
sub readingsSingleUpdate {} sub readingsBeginUpdate {} sub readingsBulkUpdate {} sub readingsEndUpdate {}
sub AnalyzeCommand { '' } sub AnalyzeCommandChain { '' } sub fhem { '' }
# Hilfsfunktionen aus 99_myUtils, die in answer-Ausdruecken stehen
sub T2F_answer { "<ANS:$_[0]>" } sub T2F_getInfo { "<INFO:$_[0]>" }
our $AUTOLOAD; sub AUTOLOAD { my $n=$AUTOLOAD; $n=~s/.*:://; return if $n eq 'DESTROY'; return "<$n>"; }
require $modfile;
Talk2Fhem_Initialize(\%{$modules{Talk2Fhem}});
my $hash = { NAME=>$name, TYPE=>'Talk2Fhem', DEF=>$dev->{def} };
$defs{$name} = $hash;
Talk2Fhem_loadList($hash, "T2F_keywordlist");
Talk2Fhem_loadList($hash, "T2F_modwordlist");
Talk2Fhem_Loadphrase($hash, "phrase", $hash->{DEF});
open my $s, '<', $satzfile or die $!;
while (my $txt = <$s>) {
  chomp $txt; next if $txt =~ /^\s*(#|$)/;
  my %res = Talk2Fhem_exec($txt, $hash, $name);
  print "## $txt\n";
  print "  cmd: ".($_->{cmd}//'')."\n" for @{$res{cmds}||[]};
  print "  ans: $_\n" for @{$res{answers}||[]};
  print "  err: $_\n" for @{$res{err}||[]};
}
