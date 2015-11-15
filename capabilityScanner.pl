#!/usr/bin/perl -w

open (FILES, "find ./dasein[^.]* -name \"*Capabilities*java\"|") || die "find command is broken";
while (<FILES>) {
    chomp;
    s/^\.*\/*//;
    next if (/dasein-cloud-core/);
    scan_file($_);
}


print <<"EOT";
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>
Dasein Capabilities
</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
    <script type="text/javascript" src="gridviewScroll.min.js"></script>
    <link href="GridviewScroll.css" rel="stylesheet" />
    <style type="text/css">
        BODY,TD {
            font-family: Tahoma, Arial, Verdana;
            font-weight: normal;
            font-size: 12px;
            color: #333333;
        }
        .form-wrapper {
	    background-color: #F1F1F1;
	    border-color: #CCCCCC;
	    border-radius: 8px 8px 8px 8px;
	    border-style: solid;
	    border-width: 1px;
	    padding: 10px 10px 10px 10px;
            width: 720px;
        }
    </style>
</head>
<body>
EOT
foreach $capability_group (sort keys %provider) {
    $group = $capability_group;
    $group =~s/Capabilities$//;
    push (@groups, $capability_group);
    print <<"EOTH";
<H2>$capability_group</H2>
<DIV CLASS="form-wrapper">
<TABLE cellspacing="0" id="$capability_group" style="border-collapse:collapse;">
  <TR class="GridviewScrollHeader">
    <TD>Method</TD>
EOTH
    foreach $cloud (sort keys %clouds) {
        print "    <TD>$cloud</TD>\n";
    }
    print "  </TR>\n";
    foreach $method (sort keys ($provider{$capability_group})) {
        foreach $return (sort keys ($provider{$capability_group}{$method})) {
            $deprecated = 0;
            foreach $cloud (sort keys %clouds) {
                if ((defined $provider{$capability_group}{$method}{$return}{$cloud}{"annotations"}) && 
                    ($provider{$capability_group}{$method}{$return}{$cloud}{"annotations"} =~ /Deprecated/)) {
                    $deprecated = 1;
                }
            }
            if ($deprecated == 1) {
                print "    <TR class=\"GridviewScrollItem\">\n      <TD style=\"background-color:#EFEFEF;\"><del>$return<BR/> $method</del></TD>\n";
            } else {
                print "    <TR class=\"GridviewScrollItem\">\n      <TD style=\"background-color:#EFEFEF;\">$return<BR/>$method</TD>\n";
            }
            $group = "";
            foreach $cloud (sort keys %clouds) {
                $annotation = $provider{$capability_group}{$method}{$return}{$cloud}{"annotations"};
                $code = $provider{$capability_group}{$method}{$return}{$cloud}{"return value"};
                if (defined $provider{$capability_group}{$method}{$return}{$cloud}{"return value"}) {
                    $ret = $return;
                    $ret =~ s/</&lt;/g;
                    $ret =~ s/>/&gt;/g;
                    if ($code =~ /return/) {
                        $code =~ s#{([^{}]*?)}#&\#123;<div style="padding-left:25px;">$1</div>&\#125;#g;
                        $code =~ s#{([^{}]*?)}#&\#123;<div style="padding-left:25px;">$1</div>&\#125;#g;
                        $code =~ s#{([^{}]*?)}#&\#123;<div style="padding-left:25px;">$1</div>&\#125;#g;
                        $code =~ s#{([^{}]*?)}#&\#123;<div style="padding-left:25px;">$1</div>&\#125;#g;
                        $code =~ s/([{};])/$1<BR\/>/g;
                    }
            
                    if ($code =~ /^(NamingConstraints|FirewallConstraints)/) {
                        $code =~ s/([)])\./$1<BR\/>&nbsp;&nbsp;./g;
                    }
                    if ($annotation =~ /Nonnull/) {
                        if ($code =~ /^null$/) {
                            $code = "<font color=\"red\">$code</font>";
                        }
                    }
                    print "      <TD>$code</TD>\n";
                } else {
                    print "      <TD></TD>\n";
                }
            }
            print "    </TR>";
        }
    }
    print <<"EOTF";
    </TR>
  </TABLE>
</DIV>
EOTF
}

print <<"EOF";
  <script type="text/javascript">
    \$(document).ready(function () {
      gridviewScrollInit();
    });
	
    function gridviewScrollInit() {
EOF
foreach $group (@groups) {
    print <<"EOS";
      $group = \$('#$group').gridviewScroll({
        width: 720,
        height: 800,
        railcolor: "#F0F0F0",
        barcolor: "#CDCDCD",
        barhovercolor: "#606060",
        bgcolor: "#F0F0F0",
        freezesize: 1,
        arrowsize: 30,
        varrowtopimg: "Images/arrowvt.png",
        varrowbottomimg: "Images/arrowvb.png",
        harrowleftimg: "Images/arrowhl.png",
        harrowrightimg: "Images/arrowhr.png",
        headerrowcount: 1,
        railsize: 16,
        barsize: 8
      });
EOS
}
print <<"EOS2";
    }
  </script>

</BODY>
</HTML>

EOS2



sub scan_file {
    my ($file) = @_;
    $class = "UNKNOWN";
    ($class) = ($file =~ m#/([^/]+)\.java#);
    $clean_output = clean_file($file);
    ($cloud) = ($file =~ m#/dasein/cloud/([^/]+)/#);
    $cloud =~ s/^ci$/google/; # temp fix for ci being in the wrong place
    $clouds{$cloud} = 1;
    foreach $_ (split(/\n/, $clean_output)) {
        chomp;
        s/ public (\@[a-zA-Z]+) / $1 public /g;
        s/((\@Nonnull\s*|\@Override\s*|\@Nullable\s*|\@Deprecated\s*)*) *(public|private|import|static)/$3/g;
        $annotation = $1;

        if (/(public|private)\sclass/) { 
            if (!(($base) = (/implements ([^\s]*)/))) {
                ($base) = (/extends ([^\s]*)/);
            }
            $base =~ s/<.*>//;
        } elsif (/public/) {
            s/throws[^;]*//;
            s/\s*public\s+//;
            if (/^[^\s]+\(/) {
                next;
            }
            s/^[ \t]+//;
            if (s/(^[^{]*)\(\)/$1/) { # simple requirement
                ($type, $method) = split(/ /, $_);
                s/[^{]*\{(.*)\} *$/$1/;
                s/^\s*return //;
                s/^([^;]*);\s*$/$1/;
                s/^\s*//;
                s/\s*$//;
                $provider{$base}{$method}{$type}{$cloud}{"return value"} = $_;
            } else { # complex requirement
                if (s/^([^(]+)\(([^)]*?)\)//) {
                    $preamble = $1;
                    $param = $2;
                    s/^\s*//;
                    s/\s*$//;
                    s/^\{(.*)\}$/$1/;
                    s/^\s*return\s(.*)\s*;\s*$/$1/;
                    ($type, $method) = split(/\s+/, $preamble);
                    $type =~ s/^\s+//;
                    $type =~ s/\s+$//;
                    $method =~ s/^\s+//;
                    $method =~ s/\s+$//;
                    $param =~ s/^\s+//;
                    $param =~ s/\s+$//;
                    s/^\s+//;
                    s/\s+$//;
                    $provider{$base}{$method}{$type}{$cloud} = {"passed parameters" => $param, "return value" => $_};
                }
            }
            if ((defined $annotation) && ($annotation !~ "")) {
                $annotation =~ s/\s+/ /g;
                $annotation =~ s/\s+$//g;
                $annotation =~ s/^\s+//g;
                $provider{$base}{$method}{$type}{$cloud}{"annotations"} = $annotation;
            }
        }
    }
}


sub clean_file {
    my ($file) = @_;
    open(FILE, $file) || die "cannot open file $file for scanning";
    @f = <FILE>;
    close(FILE);

    $count = scalar(@f);
    $comment = 0;
    for ($l = 0; $l < $count; $l++) {
        $line = $f[$l];
        chomp($line);

        s#/\*.+\*/##;
        if ($line =~ s/.*\*\///) {
            $comment = 0;
        }
        if ($line =~ /\/\*.*/) {
            $comment = 1;
        }
        if ($comment == 1) {
            $line = "";
        }

        $line =~ s#//.*##;
        $f[$l] = $line;
    }
    $s = join('',@f);
    $s =~ s/\s+/ /g;
    $s =~ s/\s+\././g;
    $s =~ s/\.\s+/./g;

    $count = 0;
    $tag = "TAG$count" . "TAG";
    my $stack = [];
    while ($s =~ s/\{([^{}]*?)\}/$tag/s) {
        $pull = $1;
        $stack[$count] = $pull;
        $count++;
        $tag = "TAG$count" . "TAG";
    }

    for ($c = $count - 1; $c > -1; $c--) {
        $tag = "TAG$c" . "TAG";
        $s =~ s/$tag/ {$stack[$c]}/;
    }

    $s =~ s/((\@Nonnull\s*|\@Override\s*|\@Nullable\s*|\@Deprecated\s*)*) *(public|private|import|static)/\n$1 $3/g;
    $s =~ s/import[^\n]*;\n//g;
    $s =~ s/package[^\n]*;\n//g;
    $s =~ s/throws[^{]*//g;
    $s =~ s/static \n/static /g;
    $s =~ s/if\( /if (/g;
    $s =~ s/ \) /\)/g;
    $s =~ s/\}\}/}\n}/g;
    return $s;
}
