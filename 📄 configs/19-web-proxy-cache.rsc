###############################################################################
# CONFIG: 19-WEB-PROXY-CACHE.RSC
# Description: Web proxy and cache configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 19: WEB PROXY + CACHE"
:log info "================================================"

:if ($enableProxy = "yes") do={

  # Web Proxy
  /ip proxy set enabled=yes port=8080 max-cache-size=unlimited \
    cache-drive=system comment="WEB_PROXY"
  /ip proxy set cache-path=/cache
  /ip proxy set max-cache-object-size=10000KiB
  /ip proxy set max-client-connections=1000
  /ip proxy set max-server-connections=500
  /ip proxy set cache-ignore-no-cache=yes
  /ip proxy set cache-on-disk=yes
  
  # Proxy Access Rules - Allow
  /ip proxy access add action=allow dst-host=*.youtube.com
  /ip proxy access add action=allow dst-host=*.facebook.com
  /ip proxy access add action=allow dst-host=*.google.com
  /ip proxy access add action=allow dst-host=*.wikipedia.org
  /ip proxy access add action=allow dst-host=*.bdix.net
  /ip proxy access add action=allow dst-host=*.bdix.com
  /ip proxy access add action=allow dst-host=*.microsoft.com
  /ip proxy access add action=allow dst-host=*.apple.com
  /ip proxy access add action=allow dst-host=*.cloudflare.com
  
  # Proxy Access Rules - Deny
  /ip proxy access add action=deny
  
  # Transparent Proxy - Redirect HTTP
  /ip firewall nat add action=redirect chain=dstnat dst-port=80 protocol=tcp \
    to-ports=8080 comment="REDIRECT_HTTP_TO_PROXY"
  
  # HTTPS Proxy (optional)
  /ip firewall nat add action=redirect chain=dstnat dst-port=443 protocol=tcp \
    to-ports=8443 comment="REDIRECT_HTTPS_TO_PROXY"
  
  # Proxy Mangle
  /ip firewall mangle add chain=prerouting protocol=tcp dst-port=80 \
    action=mark-packet new-packet-mark=proxy-traffic comment="MARK_PROXY_TRAFFIC"
  
  # Cache Settings
  /ip proxy set cache-size=unlimited
  /ip proxy set max-cache-size=unlimited
  /ip proxy set cache-drive=system
  
  # Cache Management
  /ip proxy set max-memory-cache-size=2048MiB
  
  :log info "Web proxy configuration complete"
} else={
  :log info "Web proxy is disabled"
}