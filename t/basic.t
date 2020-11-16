use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 11;
BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

plugin 'proxy';

get '/foo' => sub { shift->render(text => 'bar'); } => 'foo';
get '/bar' => sub { my $self=shift;$self->proxy_to($self->url_for('foo')->to_abs) };
get '/baz' => sub { die "ARGH" } => 'baz';
get '/fob' => sub { my $self=shift;$self->proxy_to($self->url_for('baz')->to_abs) };
get '/qux' => sub {
  my $self = shift;
  $self->proxy_to($self->url_for('foo')->to_abs);
  $self->render(text => 'quux');    # this will abort former proxy request
};

my $t=Test::Mojo->new;

$t->get_ok('/bar')->status_is(200)->content_like(qr/bar/);
$t->get_ok('/fob')
  ->status_is(500)
  ->content_is(qq/Failed to fetch data from backend/)
  ->header_is('X-Remote-Status','500: Internal Server Error');

# Check for error in callback
Mojo::IOLoop->singleton->reactor->unsubscribe('error');
my $err;
Mojo::IOLoop->singleton->reactor->once(
  error => sub { $err .= pop; Mojo::IOLoop->stop });

# no more than .1 secs
Mojo::IOLoop->timer(.1 => sub { Mojo::IOLoop->stop });

$t->get_ok('/qux')->status_is(200)->content_is('quux');
Mojo::IOLoop->start;
is $err, undef, 'no errors in reactor';
