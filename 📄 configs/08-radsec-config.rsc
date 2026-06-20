###############################################################################
# CONFIG: 08-RADSEC-CONFIG.RSC
# Description: RadSec (Secure RADIUS) configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 8: RADSEC CONFIGURATION"
:log info "================================================"

:if ($useRadSec = "yes") do={

  # Import Certificates
  /certificate import file-name=ca.cert.pem passphrase=""
  /certificate import file-name=client.cert.pem passphrase=""
  /certificate import file-name=client.key.pem passphrase=""
  
  # RadSec Server
  /radius add address=$radSecServer protocol=radsec \
    certificate=$clientCert \
    service=ppp,hotspot,wireless \
    authentication-port=$radSecPort \
    accounting-port=$radSecPort \
    secret="" timeout=3s comment="PRIMARY_RADSEC"
  
  # Backup RadSec Server
  /radius add address=$radSecServer protocol=radsec \
    certificate=$clientCert \
    service=ppp,hotspot,wireless \
    authentication-port=$radSecPort \
    accounting-port=$radSecPort \
    secret="" timeout=3s comment="BACKUP_RADSEC"
  
  # RadSec Incoming
  /radius incoming set accept=yes port=3799
  
  # RadSec TLS Settings
  /radius set [find protocol=radsec] tls-verify=yes
  
  :log info "RadSec configuration complete"
} else={
  :log info "RadSec is disabled"
}