BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use Games::Chess qw(:constants :functions debug);
debug(1);
$loaded = 1;
print "ok 1\n";

use strict;
use UNIVERSAL 'isa';
$^W = 1;
my $n = 1;
my $success;

sub do_test (&) {
  my ($test) = @_;
  ++ $n;
  $success = 1;
  &$test;
  print 'not ' unless $success;
  print "ok $n\n";
}

sub fail {
  my ($mesg) = @_;
  print STDERR $mesg, "\n";
  $success = 0;
}

# Test algebraic_to_xy, xy_to_algebraic, xy_valid

do_test {
  my @squares = 
    qw(a1 0 0 a2 0 1 a3 0 2 a4 0 3 a5 0 4 a6 0 5 a7 0 6 a8 0 7
       b1 1 0 b2 1 1 b3 1 2 b4 1 3 b5 1 4 b6 1 5 b7 1 6 b8 1 7
       c1 2 0 c2 2 1 c3 2 2 c4 2 3 c5 2 4 c6 2 5 c7 2 6 c8 2 7
       d1 3 0 d2 3 1 d3 3 2 d4 3 3 d5 3 4 d6 3 5 d7 3 6 d8 3 7
       e1 4 0 e2 4 1 e3 4 2 e4 4 3 e5 4 4 e6 4 5 e7 4 6 e8 4 7
       f1 5 0 f2 5 1 f3 5 2 f4 5 3 f5 5 4 f6 5 5 f7 5 6 f8 5 7
       g1 6 0 g2 6 1 g3 6 2 g4 6 3 g5 6 4 g6 6 5 g7 6 6 g8 6 7
       h1 7 0 h2 7 1 h3 7 2 h4 7 3 h5 7 4 h6 7 5 h7 7 6 h8 7 7);
  my @non_squares = qw(a0 a9 @1 @8 h0 h9 i1 i8 A1 A8 H1 H8);
  while (@squares) {
    my ($sq,$x,$y) = splice @squares, 0, 3;
    my $SQ = xy_to_algebraic($x,$y);
    $sq eq $SQ
      or fail("xy_to_algebraic($x,$y) = $SQ (should be $sq)");
    my ($X,$Y) = algebraic_to_xy($sq);
    $x == $X and $y == $Y
      or fail("algebraic_to_xy($sq) = $X,$Y (should be $x,$y)");
    my $v = xy_valid($x,$y);
    defined $v and $v == 1
      or fail("xy_valid($x,$y) is $v (should be 1)");
  }
  local $Games::Chess::DEBUG = 0;
  foreach (@non_squares) {
    my @sq = algebraic_to_xy($_);
    @sq == 0 or fail("algebraic_to_xy($_) is (@sq) (should be none)");
  }
  foreach (0 .. 100) {
    my ($x,$y) = (rand(1000)-500,rand(1000)-500);
    next if $x==int $x and $y==int $y and 0<=$x and $x<8 and 0<=$y and $y<8;
    my $sq = xy_to_algebraic($x,$y);
    not defined $sq or fail("xy_to_algebraic($x,$y) = $sq (should be undef)");
    my $v = xy_valid($x,$y);
    not defined $v or fail("xy_valid($x,$y) is $v (should be undef)");
  }
};

# Check Piece->new when given no arguments.

do_test {
  my $p = Games::Chess::Piece->new;
  $p or fail("Piece->new returned undefined.");
  ord($$p) == 0 or fail("Piece->new should be 0.");
};

# Check Piece->new($arg) produces the correct representation in all three 
# cases: $arg a number, $arg a character or $arg a Piece.

do_test {
  my %tests = ( ' ' => [ &EMPTY, &EMPTY,  'empty square',  0 ],
		'p' => [ &BLACK, &PAWN,   'black pawn',   17 ],
		'n' => [ &BLACK, &KNIGHT, 'black knight', 18 ],
		'b' => [ &BLACK, &BISHOP, 'black bishop', 19 ],
		'r' => [ &BLACK, &ROOK,   'black rook',   20 ],
		'q' => [ &BLACK, &QUEEN,  'black queen',  21 ],
		'k' => [ &BLACK, &KING,   'black king',   22 ],
		'P' => [ &WHITE, &PAWN,   'white pawn',    9 ],
		'N' => [ &WHITE, &KNIGHT, 'white knight', 10 ],
		'B' => [ &WHITE, &BISHOP, 'white bishop', 11 ],
		'R' => [ &WHITE, &ROOK,   'white rook',   12 ],
		'Q' => [ &WHITE, &QUEEN,  'white queen',  13 ],
		'K' => [ &WHITE, &KING,   'white king',   14 ], );

  foreach my $k (keys %tests) {
    my $p = Games::Chess::Piece->new($k);
    my $q = Games::Chess::Piece->new($p);
    foreach ($p,$q) {
      unless ($_) {
	test(0,"Piece->new($k) returned undefined.");
	next;
      }
      my ($CODE,$COLO,$PIEC,$NAME,$NUMB,$CN,$PN) =
	($k,@{$tests{$k}},split(' ',$tests{$k}[2]));
      my ($code,$colo,$piec,$name,$numb,$cn,$pn) =
	($_->code,$_->colour,$_->piece,$_->name,ord($$_),$_->colour_name,$_->piece_name);
      $code eq $CODE or fail("Piece($k)->code is $code (should be $CODE).");
      $colo eq $COLO or fail("Piece($k)->colour is $colo (should be $COLO).");
      $piec eq $PIEC or fail("Piece($k)->piece is $piec (should be $PIEC).");
      $name eq $NAME or fail("Piece($k)->name is $name (should be $NAME).");
      $numb == $NUMB or fail("Piece($k) is $numb (should be $NUMB).");
      $cn eq $CN or fail("Piece($k)->colour_name is $cn (should be $CN).");
      $pn eq $PN or fail("Piece($k)->piece_name is $pn (should be $PN).");
    }
  }
};

# Check Position->new when given no arguments.

do_test {
  my $init_pos = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  my $p = Games::Chess::Position->new;
  $p or fail("Position->new returned undefined.");
  $p->to_FEN eq $init_pos or fail("Position->new->to_FEN is @{[$p->to_FEN]}.");
};

my %tests =
  ( 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1' =>
    <<END,
r n b q k b n r
p p p p p p p p
  .   .   .   .
.   .   .   .  
  .   .   .   .
.   .   .   .  
P P P P P P P P
R N B Q K B N R
END
    # The following three problems are from "The Chess Mysteries of
    # Sherlock Holmes" by Raymond Smullyan; they appear on pages 148, 78
    # and 145 respectively.
    '2b1k2r/1p1pppbp/pp3n2/8/3NB3/2P2P1P/P1PPP2P/RNB1K2R w Kk - 5 20' =>
    <<END,
  . b . k .   r
. p . p p p b p
p p   .   n   .
.   .   .   .  
  .   N B .   .
.   P   . P . P
P . P P P .   P
R N B   K   . R
END
    '2B5/8/6P1/6Pk/3P2qb/3p4/3PB3/2NrNKQR b - - 1 45' =>
    <<END,
  . B .   .   .
.   .   .   .  
  .   .   . P .
.   .   .   P k
  .   P   . q b
.   . p .   .  
  .   P B .   .
.   N r N K Q R
END
    'r3k3/8/8/8/8/8/5PP1/6bK w q - 4 65' =>
    <<END,
r .   . k .   .
.   .   .   .  
  .   .   .   .
.   .   .   .  
  .   .   .   .
.   .   .   .  
  .   .   P P .
.   .   .   b K
END
  );

# Check new, to_FEN, to_text and validate.
  
do_test {
  foreach my $c (keys %tests) {
    my $p = Games::Chess::Position->new($c);
    unless ($p) {
      fail("Piece->new($c) returned undefined.");
      next;
    }
    unless (isa($p,'Games::Chess::Position')) {
      fail("Position->new($c) didn't return a Games::Chess::Position");
      next;
    }
    next unless $p->validate;
    my ($FEN,$DIAGRAM) = ($c,$tests{$c});
    my ($fen,$diagram) = ($p->to_FEN, $p->to_text . "\n");
    $fen eq $FEN or fail("Position($FEN)->to_FEN is $fen");
    $diagram eq $DIAGRAM or fail("Position($FEN)->to_text is:\n$diagram");
  }
};

# Check Position->at and Position->sq against each other.

do_test {
  foreach my $c (keys %tests) {
    my $p = Games::Chess::Position->new($c);
    unless ($p) {
      fail("Position->new($c) returned undefined.");
      next;
    }
    unless (isa($p,'Games::Chess::Position')) {
      fail("Position->new($c) didn't return a Games::Chess::Position");
      next;
    }
    next unless $p->validate;
    my @pieces = (split '', $tests{$c})[map {2*$_} 0 .. 63];
    foreach my $x (0 .. 7) {
      foreach my $y (0 .. 7) {
	my $at = $p->at($x,$y);
	isa($at,'Games::Chess::Piece') or fail("$at not a chess piece");
	my $code = $pieces[8*(7-$y)+$x];
	$code = ' ' if $code eq '.';
	my $CODE = $at->code;
	$CODE eq $code 
          or fail("Position->new($c)->at($x,$y)->code=$CODE (should be $code)");
      }
    }
  }
};

# Check that the validate method can detect various infelicities.

do_test {
  my %tests =
    ( 'K1k5/pppppppp/8/8/8/8/p7/8 w - - 0 5'	    => 'Black has 9 pawns',
      'K1k5/P7/8/8/8/8/PPPPPPPP/8 w - - 0 5'	    => 'White has 9 pawns',
      'nbbbK2k/qqqrrrnn/8/8/8/8/ppppp3/8 w - - 0 5' => 'Black has more than 8',
      'NBBBK2k/QQQRRRNN/8/8/8/8/PPPPP3/8 w - - 0 5' => 'White has more than 8',
      'K7/8/8/8/8/8/8/8 w - - 0 50'		    => 'Black has 0 kings',
      '8/8/8/8/8/8/8/k7 w - - 0 50'		    => 'White has 0 kings',
      'P7/8/8/8/8/8/8/K1k5 w - - 0 50'		    => 'pawn on rank',
      'p7/8/8/8/8/8/8/K1k5 w - - 0 50'		    => 'pawn on rank',
      '8/8/8/8/8/8/8/K1k4P w - - 0 50'		    => 'pawn on rank',
      '8/8/8/8/8/8/8/K1k4p w - - 0 50'		    => 'pawn on rank',
    );
  foreach (keys %tests) {
    my $p = Games::Chess::Position->new($_);
    unless ($p) {
      fail("Position->new($_) returned undefined.");
      next;
    }
    unless (isa($p,'Games::Chess::Position')) {
      fail("Position->new($_) didn't return a Games::Chess::Position");
      next;
    }
    my $v = do {
      local $Games::Chess::DEBUG = 0;
      $p->validate;
    };
    not defined $v
      or fail("Position->new($_)->validate returned $v (should be undef)");
    my $e = Games::Chess::errmsg();
    0 <= index($e, $tests{$_})
      or fail("Position->new($_)->validate gave error $e");
  }
};


# Check Position->to_GIF;

do_test {
  my $m = 0;
  foreach my $c (keys %tests) {
    ++$m;
    my $p = Games::Chess::Position->new($c);
    next unless $p->validate;
    open(GIF, "> /tmp/$m.gif") or die "Couldn't open /tmp/$m.gif: $!";
    print GIF $p->to_GIF;
    close(GIF);
  }
};
