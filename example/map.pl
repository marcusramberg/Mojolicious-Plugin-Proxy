use Mojolicious::Lite -signatures;

# This example is based on leaflet's tutorial (quick start guide)
# https://leafletjs.com/examples/quick-start/
#
# The only change here is that requests to the openstreetmap API that we are
# using are proxied through our backend, instead of been just sent by
# the browser (client) to openstreetmap.com
#
# Reasons to do this vary from allowing users without full internet access
# to use our app, or add authorization tokens in the backend
# instead of just pasting it into front-end code, where the risk for that
# token to be exposed is much bigger
#
plugin 'proxy';

get '/' => 'index';

get '/maps/:s/:z/:x/:y' => sub($c) {
  my ($s, $z, $x, $y) = @{$c->stash}{qw/s z x y/};
  $c->proxy_to("https://$s.tile.osm.org/$z/$x/$y.png", with_query_params => 1);
};

app->start;

__DATA__

@@ index.html.ep
<!DOCKTYPE html>
<html>
    <head>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
   integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
   crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
   integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
   crossorigin=""></script>
    </head>
    <body>
    <div id="mapid"></div>
    <style>
    #mapid { height: 180px; }
    </style>
    <script>
var mymap = L.map('mapid').setView([51.505, -0.09], 13);
L.tileLayer('/maps/{s}/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(mymap);
    </script>
    </body>
</html>
