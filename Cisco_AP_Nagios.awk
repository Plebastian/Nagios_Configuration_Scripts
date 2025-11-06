function ip(s){
    if (match(s, /([0-9]{1,3}\.){3}[0-9]{1,3}/)) return substr(s, RSTART, RLENGTH); 
    return ""
}

function safe(s){
    gsub(/[^A-Za-z0-9._-]/, "_", s); return s 
}

function hostblock(h,ip){
    print "define host {";
    print " use                     generic-switch";
    print " host_name               " h;
    print " alias                   " h;
    print " address                 " ip;
    print " hostgroups              wireless-aps";
    print "}\n";
# Below refer to this reference https://www.tutorialspoint.com/nagios/nagios_hosts_and_services.htm as it may require adjustment depending on your own situation. 
    print "define services {";
    print " host_name               " h;
    print " Service_description PING";
    print " check_command_ping!100.0!,20%!500.0,60%";
    print " max_check_attempts      2";
    print " check_interval          2";
    print " retry_interval          2";
    print " check_period            24x7";
    print " check_freshness         1";
    print " contact_groups          admins";
    print "}\n";
}

/^AP[0-9]+/ {
    ipaddr = ip($0); if (!ipaddr) next;
    h= safe($1);
    
    if ((h) in seen) {
        split(ipaddr, o, ".");
        h = h "_" o[4];
    }
    seen(h)=1;
    hostblock(h,ipaddr);
}
AWK
