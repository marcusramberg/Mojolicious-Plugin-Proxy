use Mojolicious::Lite;
use Test::More;
use Test::Mojo;

plugin 'proxy';

get '/foo' => sub { shift->render(text => 'bar'); } => 'foo';
get '/bar' => sub { my $self = shift; $self->proxy_to($self->url_for('foo')->to_abs) };
get '/baz' => sub { die "ARGH" } => 'baz';
get '/fob' => sub { my $self = shift; $self->proxy_to($self->url_for('baz')->to_abs) };

post '/c1' => sub { shift->render(text => 'c1'); } => 'c1';
post '/c2' => sub { my $self = shift; $self->proxy_to($self->url_for('c1')->to_abs) };

del '/h1' => sub { my $self = shift; $self->render(text => 'h1: ' . ($self->param('p') || 'default')) } => 'h1';
del '/h2' => sub { my $self = shift; $self->proxy_to($self->url_for('h1')->to_abs, with_query_params => 1) };
del '/h3' => sub { my $self = shift; $self->proxy_to($self->url_for('h1')->to_abs, with_query_params => 0) };

my $t = Test::Mojo->new;

$t->get_ok('/bar')->status_is(200)->content_like(qr/bar/);
$t->get_ok('/fob')
    ->status_is(500)
    ->content_is('Failed to fetch data from backend')
    ->header_is('X-Remote-Status', '500: Internal Server Error');
$t->post_ok('/c2')->status_is(200)->content_is('c1');
$t->delete_ok('/h2?p=123')->status_is(200)->content_is('h1: 123');
$t->delete_ok('/h3?p=123')->status_is(200)->content_is('h1: default');

done_testing();
