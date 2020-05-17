#!/usr/bin/perl
#
#
# OK, here is a very experimental LNB temperature calculator. Temperature calculation based on QO-100 center beacon shift.
# Assuming, QO-100 center PSK beacon is stable and our LNB has no TCXO.
# You still have to calibrate it. Just measure weather temperature few times when it's stable and note beacon offset (in Hz) 
# i.e you can measure it at night and day.
#
# LY3FF, 2020
#
# 
# $f1 - night time frequency
# $f2 - cloudy day time frequency.
#
# $t1 - night time weather temperature (in celsius)
# $t2 - day time weather temperature
#

use strict;

my $freq = shift;
if ($freq eq '') {
    print "lnb_temp.pl beacon_frequency_in_hz \n";
    exit 1;
}

#my $freq = 10489726500;

my $f1 = 10489708844;
my $f2 = 10489711296;
#my $f2 = 10489725642;
my $t1 = 1.06;
my $t2 = 2.31;

my $VERBOSE=1;
#my $t2 = 11.0;

my $dt = $t2 - $t1;
my $df = $f2 - $f1;


my $temperature = get_temperature($freq);

test();
display_info();

printf"temp=%.02f\n", $temperature;


#returns temperature in Celsius
sub get_temperature{
    my $freq = shift;
    my $k = $dt / $df;
    return ($k * ($freq-$f1) + $t1);
}

# returns frequency in Hz
sub get_freq{
    my $temp = shift;
    my $k = $dt / $df;
    return (($temp-$t1) / $k + $f1);
}


# unit test
sub test {
    my $freq = 10489726500;
    my $calc_t = get_temperature($freq);
    my $calc_f = get_freq($calc_t);
    print "
Input freq            : $freq
Calculated temperature: $calc_t
Calculated frequency  : $calc_f
";
    if ($calc_f == $freq){
	print "test PASSED\n"
    } else { print "test FAILED\n"}
    print "\n";
}

sub display_info{
    my $freq_0 = get_freq(0);
    my $freq_1 = get_freq(1);
    my $daliklis = 10;
    print "DT: $dt  DT/$daliklis = " . $dt/$daliklis . "\n";
    print "DF: $df  DF/$daliklis = " . $df/$daliklis . "\n";
    print "DT/DF = $dt/$df = " . $dt/$df . "\n";
    print "Freq at 0 'C: " . $freq_0   . " Hz\n";
    print "Freq at 25'C: " . get_freq(25)  . " Hz\n";
    print "Frequency shift per 1 'C :" . ($freq_1 - $freq_0) . " Hz \n\n";
}
