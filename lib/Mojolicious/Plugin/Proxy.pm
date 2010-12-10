package Mojolicious::Plugin::Proxy;

use base 'Mojolicious::Plugin';

use Mojo::Client;

our $VERSION='0.1';

sub register {
    my ($self,$app) = @_;
     
     
    $app->renderer->add_helper(
        proxy_to => sub {
           my $c = shift;
           my $url = Mojo::URL->new(shift);
           my %args = @_ ;
           $url->query($c->req->params) 
               if($args{with_query_params});
           my $tx=$c->client->get($url);
           if (my $res=$tx->success) {
               $c->tx->res($res);
	       $c->rendered;
           }
           else {
               $c->render(
                   status => 500,
                   text => 'Failed to fetch data from backend'
                   );
           }
    });
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Proxy - Proxy requests to 
