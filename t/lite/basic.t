use lib 't/lib';
use TestML;
use TestML::Compiler::Lite;
use TestMLBridge;

TestML->new(
    testml => '../testml/basic.tml',
    bridge => 'TestMLBridge',
    compiler => 'TestML::Compiler::Lite',
)->run;
