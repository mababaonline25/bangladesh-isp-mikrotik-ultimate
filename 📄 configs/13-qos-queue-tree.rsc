###############################################################################
# CONFIG: 13-QOS-QUEUE-TREE.RSC
# Description: QoS and queue tree configuration
# Version: 5.0.0
###############################################################################

:log info "================================================"
:log info "SECTION 13: QoS - QUEUE TREE"
:log info "================================================"

# Queue Types
/queue type add name="pcq-download" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="pcq-upload" kind=pcq pcq-rate=0 pcq-classifier=src-address
/queue type add name="pcq-premium-download" kind=pcq pcq-rate=100M pcq-classifier=dst-address
/queue type add name="pcq-premium-upload" kind=pcq pcq-rate=100M pcq-classifier=src-address
/queue type add name="pcq-business-download" kind=pcq pcq-rate=50M pcq-classifier=dst-address
/queue type add name="pcq-business-upload" kind=pcq pcq-rate=50M pcq-classifier=src-address

# CAKE and FQ_CODEL (if supported by RouterOS version)
/queue type add name="cake-download" kind=cake cake-diffserv=diffserv4 cake-flowmode=dual-srchost
/queue type add name="cake-upload" kind=cake cake-diffserv=diffserv4 cake-flowmode=dual-dsthost
/queue type add name="fq_codel-download" kind=fq_codel fq_codel-limit=1000 fq_codel-quantum=300
/queue type add name="fq_codel-upload" kind=fq_codel fq_codel-limit=1000 fq_codel-quantum=300

# Queue Tree - Root
/queue tree
add name="TOTAL_UPLOAD" parent=global packet-mark=upload queue=pcq-upload
add name="TOTAL_DOWNLOAD" parent=global packet-mark=download queue=pcq-download

# Queue Tree - PPPoE
add name="PPPOE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=upload-pppoe queue=pcq-upload
add name="PPPOE_DOWNLOAD" parent=TOTAL_DOWNLOAD packet-mark=download queue=pcq-download

# Queue Tree - Business Traffic
add name="B2B_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=b2b-traffic queue=pcq-premium-download
add name="B2B_UPLOAD" parent=TOTAL_UPLOAD packet-mark=b2b-traffic queue=pcq-premium-upload

# Queue Tree - Voice Traffic
add name="VOICE_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=voice-traffic queue=pcq-premium-download
add name="VOICE_UPLOAD" parent=TOTAL_UPLOAD packet-mark=voice-traffic queue=pcq-premium-upload

# Queue Tree - IPTV Traffic
add name="IPTV_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=iptv-traffic queue=pcq-premium-download

# Queue Tree - Guest Traffic
add name="GUEST_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=guest-traffic queue=pcq-business-download
add name="GUEST_UPLOAD" parent=TOTAL_UPLOAD packet-mark=guest-traffic queue=pcq-business-upload

# Queue Tree - Hotspot Traffic
add name="HOTSPOT_TRAFFIC" parent=TOTAL_DOWNLOAD packet-mark=hotspot-traffic queue=pcq-business-download
add name="HOTSPOT_UPLOAD" parent=TOTAL_UPLOAD packet-mark=hotspot-traffic queue=pcq-business-upload

# Simple Queue Limits - Global
/queue simple add name="TOTAL-LIMIT" target=$upstream1Interface max-limit=9500M/9500M \
  comment="TOTAL_10G_LIMIT"

:if ($enableFailover = "yes") do={
  /queue simple add name="BACKUP-LIMIT" target=$upstream2Interface max-limit=4500M/4500M \
    comment="BACKUP_5G_LIMIT"
}

# Per-User Queues (if needed)
/queue simple add name="USER-QUEUE" target=10.10.0.0/16 max-limit=100M/100M \
  comment="PER_USER_QUEUE"

:log info "QoS configuration complete"