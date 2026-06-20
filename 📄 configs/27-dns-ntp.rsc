###############################################################################
# CONFIG: 27-DNS-NTP.RSC
# Description: DNS and NTP configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 27: DNS & NTP"
:log info "================================================"

# DNS Configuration
/ip dns set servers=8.8.8.8,1.1.1.1,8.8.4.4,208.67.222.222
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB
/ip dns set max-concurrent-tcp-sessions=1000
/ip dns set max-concurrent-udp-sessions=1000
/ip dns set use-doh-server=https://cloudflare-dns.com/dns-query
/ip dns set use-doh=yes

# DNS Static Entries
/ip dns static add name=router.local address=192.168.20.1
/ip dns static add name=hotspot.local address=10.100.0.1
/ip dns static add name=mail.local address=10.99.0.10
/ip dns static add name=radius.local address=10.1.200.2
/ip dns static add name=web.local address=10.99.0.10
/ip dns static add name=dns.local address=10.99.0.10
/ip dns static add name=ntp.local address=10.99.0.10

# DNS Cache Settings
/ip dns set cache-size=20480KiB
/ip dns set cache-max-ttl=1w

# DNS Forwarding
/ip dns set allow-remote-requests=yes
/ip dns set max-udp-packet-size=4096

# NTP Configuration
/system ntp client set enabled=yes
/system ntp client servers add address=time.google.com
/system ntp client servers add address=pool.ntp.org
/system ntp client servers add address=bd.pool.ntp.org
/system ntp client servers add address=time.cloudflare.com

# NTP Server (if needed)
/system ntp server set enabled=yes

:log info "DNS and NTP configuration complete"