###############################################################################
# CONFIG: 17-HOTSPOT-WALLED-GARDEN.RSC
# Description: Hotspot walled garden configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 17: HOTSPOT - WALLED GARDEN"
:log info "================================================"

:if ($enableHotspot = "yes") do={

  # Walled Garden IPs
  /ip hotspot walled-garden ip
  add dst-address=8.8.8.8 action=accept comment="GOOGLE_DNS"
  add dst-address=1.1.1.1 action=accept comment="CLOUDFLARE_DNS"
  add dst-address=4.4.4.4 action=accept comment="GOOGLE_DNS2"
  add dst-address=8.8.4.4 action=accept comment="GOOGLE_DNS3"
  add dst-address=208.67.222.222 action=accept comment="OPENDNS"
  add dst-address=208.67.220.220 action=accept comment="OPENDNS2"
  
  # Walled Garden Hosts
  /ip hotspot walled-garden
  add dst-host=*.google.com action=accept comment="GOOGLE"
  add dst-host=*.googleapis.com action=accept comment="GOOGLE_APIS"
  add dst-host=*.gstatic.com action=accept comment="GOOGLE_STATIC"
  add dst-host=*.facebook.com action=accept comment="FACEBOOK"
  add dst-host=*.fb.com action=accept comment="FB"
  add dst-host=*.fbcdn.net action=accept comment="FB_CDN"
  add dst-host=*.apple.com action=accept comment="APPLE"
  add dst-host=*.microsoft.com action=accept comment="MICROSOFT"
  add dst-host=*.captive.apple.com action=accept comment="CAPTIVE_APPLE"
  add dst-host=*.android.com action=accept comment="ANDROID"
  add dst-host=*.cloudflare.com action=accept comment="CLOUDFLARE"
  add dst-host=*.bdix.net action=accept comment="BDIX"
  add dst-host=*.wikipedia.org action=accept comment="WIKIPEDIA"
  add dst-host=*.youtube.com action=accept comment="YOUTUBE"
  add dst-host=*.googlevideo.com action=accept comment="GOOGLE_VIDEO"
  add dst-host=*.whatsapp.com action=accept comment="WHATSAPP"
  add dst-host=*.messenger.com action=accept comment="MESSENGER"
  add dst-host=*.instagram.com action=accept comment="INSTAGRAM"
  add dst-host=*.twitter.com action=accept comment="TWITTER"
  add dst-host=*.x.com action=accept comment="X"
  
  # Walled Garden Ports
  /ip hotspot walled-garden
  add dst-port=80 action=accept comment="HTTP"
  add dst-port=443 action=accept comment="HTTPS"
  add dst-port=53 action=accept comment="DNS"
  add dst-port=123 action=accept comment="NTP"
  add dst-port=22 action=accept comment="SSH"
  
  :log info "Hotspot walled garden configuration complete"
} else={
  :log info "Hotspot is disabled"
}