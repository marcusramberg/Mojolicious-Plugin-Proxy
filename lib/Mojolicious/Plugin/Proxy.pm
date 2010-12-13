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
               my ($msg,$error) = $tx->error;
	       $c->tx->res->headers->add('X-Remote-Status',$error.': '.$msg);	
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

Mojolicious::Plugin::Proxy - Proxy requests to a backend server

=head1 SYNOPSIS

   plugin 'proxy';

   get '/foo' => sub { shift->proxy_to('http://mojolicio.us/') };

=head1 DESCRIPTION

Proxy requests to backend URL using L<Mojo::Client>.

=head1 METHODS

=head2 proxy_to $url, [%options]

Proxies the current request to $url using the L<Mojo::Client> get method.
supports one parameter:

=over 4

=item with_query_params

If this parameter is set to 1, will get query parameters from the current 
request and proxy them to the backend.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008-2010, Marcus Ramberg.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut


=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Lite>
