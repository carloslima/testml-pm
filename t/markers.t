use TestML;
use t::Bridge;

TestML->new(
    testml => 'testml/markers.tml',
    bridge => 't::Bridge',
)->run;
