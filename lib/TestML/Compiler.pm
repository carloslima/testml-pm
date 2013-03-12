package TestML::Compiler;
use TestML::Base;

use TestML::Runtime;

has code => ();
has data => ();
has text => ();
has directives => ();
has function => ();

sub compile {
    my ($self, $input) = @_;

    $self->preprocess($input, 'top');
    $self->compile_code;
    $self->compile_data;

    if ($self->directives->{DumpAST}) {
        XXX($self->function);
    }

    $self->function->outer(TestML::Function->new());
    return $self->function;
}

sub preprocess {
    my ($self, $input, $top) = @_;

    my @parts = split /^((?:\%\w+.*|\#.*|\ *)\n)/m, $input;

    $input = '';

    my $directives = $self->{directives} = {
        TestML => '',
        DataMarker => '',
        BlockMarker => '===',
        PointMarker => '---',
    };

    my $order_error = 0;
    for my $part (@parts) {
        next unless length($part);
        if ($part =~ /^(\#.*|\ *)\n/) {
            $input .= "\n";
            next;
        }
        if ($part =~ /^%(\w+)\s*(.*?)\s*\n/) {
            my ($directive, $value) = ($1, $2);
            $input .= "\n";
            if ($directive eq 'TestML') {
                die "Invalid TestML directive"
                    unless $value =~ /^\d+\.\d+\.\d+$/;
                die "More than one TestML directive found"
                    if $directives->{TestML};
                $directives->{TestML} = TestML::Str->new(value => $value);
                next;
            }
            $order_error = 1 unless $directives->{TestML};
            if ($directive eq 'Include') {
                my $runtime = $TestML::Runtime::singleton
                    or die "Can't process Include. No runtime available";
                my $include = ref($self)->new;
                $include->preprocess($runtime->read_testml_file($value));
                $input .= $include->text;
                $directives->{DataMarker} =
                    $include->directives->{DataMarker};
                $directives->{BlockMarker} =
                    $include->directives->{BlockMarker};
                $directives->{PointMarker} =
                    $include->directives->{PointMarker};
                die "Can't define %TestML in an Included file"
                    if $include->directives->{TestML};
            }
            elsif ($directive =~ /^(DataMarker|BlockMarker|PointMarker)$/) {
                $directives->{$directive} = $value;
            }
            elsif ($directive =~ /^(DebugPegex|DumpAST)$/) {
                $value = 1 unless length($value);
                $directives->{$directive} = $value;
            }
            else {
                die "Unknown TestML directive '$directive'";
            }
        }
        else {
            $order_error = 1 if $input and not $directives->{TestML};
            $input .= $part;
        }
    }

    if ($top) {
        die "No TestML directive found"
            unless $directives->{TestML};
        die "%TestML directive must be the first (non-comment) statement"
            if $order_error;

        my $DataMarker = $directives->{DataMarker} ||= $directives->{BlockMarker};
        my ($code, $data);
        if ((my $split = index($input, "\n$DataMarker")) >= 0) {
            $self->{code} = substr($input, 0, $split + 1);
            $self->{data} = substr($input, $split + 1);
        }
        else {
            $self->{code} = $input;
            $self->{data} = '';
        }

        $self->{code} =~ s/^\\(\\*[\%\#])/$1/gm;
        $self->{data} =~ s/^\\(\\*[\%\#])/$1/gm;
    }
    else {
        $self->{text} = $input;
    }
}

1;
