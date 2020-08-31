# masquerade all outgoing traffic
define nftables::rules::masquerade(
  Pattern[/^[a-zA-Z0-9_]+$/]
    $rulename = $title,
  Pattern[/^\d\d$/]
    $order = '70',
  String[1]
    $chain = 'POSTROUTING',
  Optional[String[1]]
    $oif = undef,
  Optional[String[1]]
    $saddr = undef,
  Optional[String[1]]
    $daddr = undef,
  Optional[Pattern[/^(tcp|udp)$/]]
    $proto = undef,
  Optional[Variant[String,Integer[1,65535]]]
    $dport = undef,
  Enum['present','absent']
    $ensure = 'present',
) {

  $oifname = $oif ? {
    undef   => '',
    default => "oifname ${oif} ",
  }
  $src = $saddr ? {
    undef   => '',
    default => "ip saddr ${saddr} ",
  }
  $dst = $daddr ? {
    undef   => '',
    default => "ip daddr ${daddr} ",
  }

  if $proto and $dport {
    $protocol = ''
    $port     = "${proto} dport ${dport} "
  } elsif $proto {
    $protocol = "${proto} "
    $port     = ''
  } elsif $dport {
    $protocol = ''
    $port     = "tcp dport ${dport} "
  } else {
    $protocol = ''
    $port     = ''
  }

  nftables::rule{
    "${chain}-${rulename}":
      ensure  => $ensure,
      table   => 'ip-nat',
      order   => $order,
      content => "${oifname}${src}${dst}${protocol}${port}masquerade";
  }
}
