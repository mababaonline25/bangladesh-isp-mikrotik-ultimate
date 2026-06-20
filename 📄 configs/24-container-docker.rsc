###############################################################################
# CONFIG: 24-CONTAINER-DOCKER.RSC
# Description: Container (Docker) configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 24: CONTAINER (DOCKER)"
:log info "================================================"

:if ($enableContainer = "yes") do={

  # VETH Interface
  /interface veth add name=veth1 address=172.18.0.2/16 gateway=172.18.0.1 \
    comment="CONTAINER_VETH"
  
  # Create Container Directories
  /file mkdir containers/nginx
  /file mkdir containers/adguard
  /file mkdir containers/unbound
  /file mkdir containers/pi-hole
  /file mkdir containers/wireguard
  
  # Nginx Container
  /container add name=nginx image=nginx:latest interface=veth1 \
    root-dir=containers/nginx comment="NGINX_WEB_SERVER"
  /container start nginx
  
  # AdGuard Home Container
  /container add name=adguard image=adguard/adguardhome:latest interface=veth1 \
    root-dir=containers/adguard envs="TZ=Asia/Dhaka" \
    comment="ADGUARD_DNS"
  /container start adguard
  
  # Unbound DNS Container
  /container add name=unbound image=alpine/unbound:latest interface=veth1 \
    root-dir=containers/unbound comment="UNBOUND_DNS"
  /container start unbound
  
  # Pi-hole Container
  /container add name=pihole image=pihole/pihole:latest interface=veth1 \
    root-dir=containers/pi-hole envs="TZ=Asia/Dhaka, WEBPASSWORD=admin123" \
    comment="PI-HOLE"
  /container start pihole
  
  # Container Firewall Rules
  /ip firewall filter add chain=input in-interface=veth1 action=accept \
    comment="ACCEPT_CONTAINER"
  /ip firewall filter add chain=forward in-interface=veth1 action=accept \
    comment="ACCEPT_CONTAINER_FWD"
  
  # Container NAT
  /ip firewall nat add action=masquerade chain=srcnat out-interface=bridge-local \
    src-address=172.18.0.0/16 comment="CONTAINER_NAT"
  
  :log info "Container configuration complete"
} else={
  :log info "Container support is disabled"
}