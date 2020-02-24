use 5.010001;
use strict;
use warnings;
use Test2::V0;
use Types::Standard qw( Int );
use Sub::WrapInType qw( wrap_sub get_info );

subtest 'Create typed wrap_subymous subroutine' => sub {
  
  ok lives {
    wrap_sub [ Int, Int ], Int, sub {
      my ($x, $y) = @_;
      $x + $y;
    };
  };

  ok lives {
    wrap_sub +{ x => Int, y => Int }, Int, sub {
      my ($x, $y) = @{ shift() }{qw( x y )};
      $x + $y;
    };
  };
  
  ok lives {
    wrap_sub(
      params => [ Int, Int ],
      isa    => Int,
      code   => sub {
        my ($x, $y) = @_;
        $x + $y;
      },
    );
  };

  ok lives {
    wrap_sub(
      params => +{
        x => Int,
        y => Int,
      },
      isa    => Int,
      code   => sub {
        my ($x, $y) = @{ shift() }{qw( x y )};
        $x + $y;
      },
    );
  };

  ok dies { wrap_sub }, 'Too few arguments.';

  ok dies { wrap_sub \(my $wrap_sub), Int, sub {} };

  ok dies { wrap_sub [ 'Int', 'Int' ], 'Int', sub {} }, 'Arguments is not typeconstraint object.';
  
  ok dies {
    wrap_sub(
      params => [ Int, Int ],
      return => Int,
      code   => sub {
        my ($x, $y) = @_;
        $x + $y;
      },
    );
  }, 'Wrong key.';
  
};

subtest 'Run typed wrap_subymous subroutine' => sub {

  my $sum = wrap_sub [ Int, Int ], Int, sub {
    my ($x, $y) = @_;
    $x + $y;
  };
  is $sum->(2, 5), 7;

  my $sub = wrap_sub +{ x => Int, y => Int }, Int, sub {
    my ($x, $y) = @{ shift() }{qw( x y )};
    $x - $y;
  };
  is $sub->(x => 10, y => 5), 5;

};

subtest 'Confirm get_info' => sub {
  
  my $orig_info = +{
    params => [ Int, Int ],
    isa    => Int,
    code   => sub {
      my ($x, $y) = @_;
      $x + $y;
    },
  };
  my $typed_code = wrap_sub @$orig_info{qw( params isa code )};
  is $typed_code->returns . '', $orig_info->{isa} . '';
  is $typed_code->params . '', $orig_info->{params} . '';
  is $typed_code->code, $orig_info->{code};

};

done_testing;
