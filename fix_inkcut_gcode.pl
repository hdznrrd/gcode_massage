#!/usr/bin/perl
#
# 2019 hadez@infuanfu.de
#
# inkcut's gcode output is very... minimal
# using a CNC like stepcraft it requires a few more instructions
# to properly work. a key thing missing are feedrates as well as
# retracting between cutting and rapid moves.
# another major mixup is that the scaling factors are totally off.
# this script fixes all of those.
#
# it also fixes the comment style to be compatible with uccnc
#
# inkcut: "CMD; COMMENT"
# ucccnc: "CMD (COMMENT)"
#
# all further transmutation and insertions are explained in
# code comments further down
#
# ASSUMPTIONS:
# (1) machine z-zero is assumed to be the correct hight for cutting!
#     for non-cutting rapid movements the cutter is lifted by $LIFT mm first.
# (2) this translation can only be applied once. hence the script sets
#     a header marker in the processed output to prevent transmuting
#     an already transmuted file again.
#

use strict;

my $LIFT = 5;         # mm
my $CUTFEED = 1000;   # mm/min
my $RAPIDFEED = 3000; # mm/min

# state variable to track whether we're cutting or rapid-moving
my $pendown = 0;

# safety so we're not translating the same file twice
my $translationcheck = 0;
my $needstranslation = 1;

while(<>) {
	my $before = ''; # inserts stuff before the current command
	                 # (if you want to add a line, don't forget
			 # the newline!)
	my $after = '';  # inserts stuff after the current command
	                 # (if you want to add a line, don't forget
			 # the newline!)
	my $insert = ''; # appends something to the current command
	                 # line but does so before any comments that
			 # may or may not be there


	if(!$translationcheck) {
		if(m/\(TRANSLATED\)/) {
			# we already processed this file
			$needstranslation = 0;
		}
		$translationcheck = 1;
		$before = "(TRANSLATED)$/";
	}

	if(!$needstranslation) {
		# file was already processed once in the past.
		# just pass it through unmodifed
		print;
		next;
	}

	# now why the hell would inkcut output pixel coordinates or
	# something??? then again, they only resolution option is
	# imperial, go figure...
	if(m/X(\d+)/) {
		my $fix = $1 * 0.2857;
		s/X$1/X$fix/;
	}
	if(m/Y(\d+)/) {
		my $fix = $1 * 0.2857;
		s/Y$1/Y$fix/;
	}

	if(m/^G28/) {
		# not going home, ever
		# this is more of a hinderance than a feature
		next;
	}


	if(m/^G90/) {
		$after = "G21 (use metric like all sane people)$/";
	}

	if(m/^G00/) {
		# add missing rapid feed
		$insert = "F$RAPIDFEED";

		# if our cutter is currently down (we're cutting) we'll prefix
		# a command to rapidly retract the cutter to our lift height
		if($pendown) {
			$before = "G00 Z$LIFT F$RAPIDFEED (pen up)$/";
		}

		# cutter is now up
		$pendown = 0;	
	}

	if(m/^G01/) {
		# add missing cut feed
		$insert = "F$CUTFEED";

		# if our cutter is currently up (we've been moving
		# in rapid mode) we'll prefix a command to slowly
		# touch down the cutter again to zero height
		if(!$pendown) {
			$before = "G00 Z0 F$CUTFEED (pen down)$/";
		}

		# pen is now definitely down
		$pendown = 1;
	}



	if($insert) {
		# here's the magic to insert stuff between the command
		# and any comment that might be there
		m/^(.+?)(\(.*?\))?$/;
		$_ = "$1 $insert $2$/";
	}
	
	# assemble a new block based on the things we've found above
	print "$before$_$after";
}
