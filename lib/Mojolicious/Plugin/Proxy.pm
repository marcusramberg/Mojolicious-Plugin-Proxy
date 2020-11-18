package Mojolicious::Plugin::Proxy;

use base 'Mojolicious::Plugin';

our $VERSION = '0.7';

sub register {
  my ($self, $app) = @_;

  $app->helper(
    proxy_to => sub {
      my $c    = shift;
      my $url  = Mojo::URL->new(shift);
      my %args = @_;
      $url->query($c->req->params) if ($args{with_query_params});

      if (Mojo::IOLoop->is_running) {
        $c->render_later;
        $c->ua->get(
          $url,
          sub {
            my ($self, $tx) = @_;
            _proxy_tx($c, $tx);
          }
        );
      }
      else {
        my $tx = $c->ua->get($url);
        _proxy_tx($c, $tx);
      }
    }
  );
}

sub _proxy_tx {
  my ($self, $tx) = @_;
  return unless (my $mtx = $self->tx);
  if (!$tx->error) {
    my $res = $tx->res;
    $mtx->res($res);
    $self->rendered;
  }
  else {
    my $error = $tx->error;
    $self->tx->res->headers->add('X-Remote-Status',
      $error->{code} . ': ' . $error->{message});
    $self->render(status => 500, text => 'Failed to fetch data from backend');
  }
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Proxy - (DEPRECATED) Proxy requests to a backend server

=head1 SYNOPSIS

   plugin 'proxy';

   get '/foo' => sub { shift->proxy_to('http://mojolicio.us/') };

=head1 DESCRIPTION

DEPRECATED!

This Plugin is deprecated in favor of the L<Mojolicious> core module L<Mojolicious::Plugin::DefaultHelpers>,
that adds a C<< proxy->get_p >> helper.
Please refer to L<< Mojolicious::Plugin::DefaultHelpers/"proxy->get_p" >>

Proxy requests to backend URL using L<Mojo::UserAgent>.

=head1 HELPERS 

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
