#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Temp ();
use File::Temp qw/ :seekable /;
use Hijk;

my $fh = File::Temp->new();
my $fd = do {
    local $/ = undef;
    my $msg = join(
        "\x0d\x0a",
        'HTTP/1.1 200 OK',
        'Date: Sat, 23 Nov 2013 23:10:28 GMT',
        'Last-Modified: Sat, 26 Oct 2013 19:41:47 GMT',
        'ETag: "4b9d0211dd8a2819866bccff777af225"',
        'Content-Type: text/html',
        'Server: Example',
        'Content-Length: 4',
        '',
        'OHAI'
    );

    print $fh $msg;
    $fh->flush;
    $fh->seek(0, 0);
    fileno($fh);
};

my (undef, $proto, $status, $head, $body) = Hijk::_read_http_message($fd, 10240);

is $proto, "HTTP/1.1";
is $status, 200;
is $body, "OHAI";

is_deeply $head, {
    "Date" => "Sat, 23 Nov 2013 23:10:28 GMT",
    "Last-Modified" => "Sat, 26 Oct 2013 19:41:47 GMT",
    "ETag" => '"4b9d0211dd8a2819866bccff777af225"',
    "Content-Type" => "text/html",
    "Content-Length" => "4",
    "Server" => "Example",
};


done_testing;
