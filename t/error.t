use TestML -run,
    -bridge => 'TestMLTestBridge';
__DATA__
%TestML: 1.0

testml_stream.parse_testml().Catch().msg() == error;

=== No TestML meta directive
--- testml_stream
# A comment
foo == bar;
--- error: No TestML meta directive found
--- line: 2
