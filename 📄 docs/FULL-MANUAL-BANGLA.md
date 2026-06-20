📄 FULL-MANUAL-BANGLA.md (আপডেটেড)
markdown
# 🇧🇩 সম্পূর্ণ ম্যানুয়াল (বাংলা)

## MikroTik ISP আল্টিমেট কনফিগারেশন

---

## সূচিপত্র

1. [ভূমিকা](#ভূমিকা)
2. [সিস্টেম আর্কিটেকচার](#সিস্টেম-আর্কিটেকচার)
3. [ভেরিয়েবল তালিকা](#ভেরিয়েবল-তালিকা)
4. [ইনস্টলেশন](#ইনস্টলেশন)
5. [কনফিগারেশন ডিটেইলস](#কনফিগারেশন-ডিটেইলস)
6. [নেটওয়ার্ক ডিজাইন](#নেটওয়ার্ক-ডিজাইন)
7. [সিকিউরিটি কনফিগারেশন](#সিকিউরিটি-কনফিগারেশন)
8. [QoS ও ব্যান্ডউইথ ম্যানেজমেন্ট](#qos-ও-ব্যান্ডউইথ-ম্যানেজমেন্ট)
9. [মনিটরিং ও অ্যালার্টিং](#মনিটরিং-ও-অ্যালার্টিং)
10. [ব্যাকআপ ও রিকভারি](#ব্যাকআপ-ও-রিকভারি)
11. [ট্রাবলশুটিং](#ট্রাবলশুটিং)
12. [FAQ](#faq)

---

## ভূমিকা

এই ডকুমেন্টেশনটি বাংলাদেশের ISP-গুলোর জন্য MikroTik রাউটারের সম্পূর্ণ কনফিগারেশন গাইড। এখানে সব ধরনের ফিচার, কনফিগারেশন পদ্ধতি, এবং ট্রাবলশুটিং টিপস দেওয়া আছে।

### এই গাইডে যা আছে:
- সম্পূর্ণ ISP কনফিগারেশন
- PPPoE সার্ভার সেটআপ
- RADIUS ইন্টিগ্রেশন
- BDIX রাউটিং
- ফায়ারওয়াল ও সিকিউরিটি
- QoS ও ব্যান্ডউইথ ম্যানেজমেন্ট
- VPN সার্ভিস
- হটস্পট
- মনিটরিং ও অ্যালার্টিং
- ব্যাকআপ ও রিকভারি

---

## সিস্টেম আর্কিটেকচার

### নেটওয়ার্ক টপোলজি
┌─────────────────────────────────────┐
│ Internet (IIG) │
│ 103.xxx.xxx.1/30 (10Gbps) │
└──────────────┬──────────────────────┘
│
┌──────────────▼──────────────────────┐
│ Border Router (CCR1072) │
│ - BGP Peering │
│ - NAT │
│ - DDoS Protection │
│ - Firewall │
└──────────────┬──────────────────────┘
│
┌──────────────▼──────────────────────┐
│ Core Router (CCR1036) │
│ - OSPF Routing │
│ - MPLS │
│ - Load Balancing │
│ - VRRP │
└──────────────┬──────────────────────┘
│
┌────────────────────┼────────────────────┐
│ │ │
┌─────────▼─────────┐ ┌───────▼───────┐ ┌─────────▼─────────┐
│ POP Router 1 │ │ POP Router 2 │ │ POP Router 3 │
│ (RB1100AHx4) │ │ (RB1100AHx4) │ │ (RB1100AHx4) │
│ - PPPoE │ │ - PPPoE │ │ - PPPoE │
│ - Hotspot │ │ - Hotspot │ │ - Hotspot │
│ - VLAN │ │ - VLAN │ │ - VLAN │
└─────────┬─────────┘ └───────┬───────┘ └─────────┬─────────┘
│ │ │
┌────┴────┐ ┌────┴────┐ ┌────┴────┐
│ Clients │ │ Clients │ │ Clients │
└─────────┘ └─────────┘ └─────────┘

text

### VLAN ডিজাইন

| VLAN ID | নাম | ব্যবহার | সাবনেট |
|---------|-----|---------|---------|
| 10 | PPPoE | কাস্টমার PPPoE | 10.10.0.0/16 |
| 20 | Management | নেটওয়ার্ক ম্যানেজমেন্ট | 192.168.20.0/24 |
| 30 | Voice | IP PBX | 10.30.0.0/24 |
| 40 | B2B | এন্টারপ্রাইজ ক্লায়েন্ট | 10.40.0.0/24 |
| 50 | Guest | গেস্ট ওয়াইফাই | 10.50.0.0/24 |
| 60 | IPTV | আইপিটিভি সার্ভিস | 10.60.0.0/24 |
| 70 | Storage | NAS স্টোরেজ | 10.70.0.0/24 |
| 99 | OOB | আউট-অফ-ব্যান্ড | 10.99.0.0/24 |
| 100 | Hotspot | হটস্পট | 10.100.0.0/24 |
| 110 | CCTV | সিসিটিভি | 10.110.0.0/24 |
| 120 | IoT | আইওটি ডিভাইস | 10.120.0.0/24 |

---

## ভেরিয়েবল তালিকা (সব ডিফল্ট YES)

| ভেরিয়েবল | ডিফল্ট | বর্ণনা | বন্ধ করতে |
|-----------|--------|---------|-----------|
| `enablePPPoE` | ✅ YES | PPPoE সার্ভার | `:global enablePPPoE "no"` |
| `enableHotspot` | ✅ YES | হটস্পট | `:global enableHotspot "no"` |
| `enableVPN` | ✅ YES | VPN সার্ভিস | `:global enableVPN "no"` |
| `enableProxy` | ✅ YES | ওয়েব প্রোক্সি | `:global enableProxy "no"` |
| `enableBGP` | ✅ YES | BGP রাউটিং | `:global enableBGP "no"` |
| `enableOSPF` | ✅ YES | OSPF রাউটিং | `:global enableOSPF "no"` |
| `enableVRRP` | ✅ YES | VRRP HA | `:global enableVRRP "no"` |
| `enableBDIX` | ✅ YES | BDIX রাউটিং | `:global enableBDIX "no"` |
| `enableFailover` | ✅ YES | ফেইলওভার | `:global enableFailover "no"` |
| `enableWireGuard` | ✅ YES | WireGuard VPN | `:global enableWireGuard "no"` |
| `enableIPsec` | ✅ YES | IPsec VPN | `:global enableIPsec "no"` |
| `enableBonding` | ✅ YES | Bonding/LACP | `:global enableBonding "no"` |
| `enableMPLS` | ✅ YES | MPLS | `:global enableMPLS "no"` |
| `enableVPLS` | ✅ YES | VPLS | `:global enableVPLS "no"` |
| `enableDDNS` | ✅ YES | DDNS | `:global enableDDNS "no"` |
| `enableSNMP` | ✅ YES | SNMP মনিটরিং | `:global enableSNMP "no"` |
| `enableEmailAlerts` | ✅ YES | ইমেইল অ্যালার্ট | `:global enableEmailAlerts "no"` |
| `enableTelegramBot` | ✅ YES | টেলিগ্রাম বট | `:global enableTelegramBot "no"` |
| `enableIPv6` | ✅ YES | IPv6 সাপোর্ট | `:global enableIPv6 "no"` |
| `enableContainer` | ✅ YES | কন্টেইনার | `:global enableContainer "no"` |
| `useRadSec` | ✅ YES | RadSec | `:global useRadSec "no"` |
| `enableOpenRoaming` | ✅ YES | OpenRoaming | `:global enableOpenRoaming "no"` |

### রাউটার রোল পরিবর্তন:

```bash
# রাউটার রোল সেট করুন
:global routerRole "all-in-one"   # সব-ইন-ওয়ান
:global routerRole "border"       # বর্ডার গেটওয়ে
:global routerRole "core"         # কোর ব্যাকবোন
:global routerRole "pop"          # POP ডিস্ট্রিবিউশন
:global routerRole "service"      # সার্ভিস নোড
:global routerRole "access"       # অ্যাক্সেস CPE
ইনস্টলেশন
প্রয়োজনীয়তা
হার্ডওয়্যার
MikroTik RouterOS 7.x সমর্থিত রাউটার

ন্যূনতম 1GB RAM (সুপারিশ: 2GB+)

ন্যূনতম 1GB স্টোরেজ

ন্যূনতম 4 কোর CPU (সুপারিশ: 8+)

নেটওয়ার্ক
ইন্টারনেট কানেকশন (কনফিগ ডাউনলোডের জন্য)

ম্যানেজমেন্ট নেটওয়ার্ক

কাস্টমার নেটওয়ার্ক

ধাপে ধাপে ইনস্টলেশন
১. রাউটার প্রস্তুত করা
bash
# ফ্যাক্টরি রিসেট
/system reset-configuration

# বেসিক সেটআপ
/system identity set name="MY-ISP-ROUTER"
/system clock set time-zone-name=Asia/Dhaka
২. ভেরিয়েবল সেট করা
bash
:global companyName "MY-ISP-BD"
:global routerRole "all-in-one"
:global upstream1IP "103.xxx.xxx.1"
:global upstream1Interface "sfp-sfpplus1"
৩. ফাইল আপলোড করা
bash
# SCP দিয়ে আপলোড
scp main-script.rsc admin@192.168.88.1:/

# অথবা FTP দিয়ে
ftp 192.168.88.1
> put main-script.rsc
৪. স্ক্রিপ্ট রান করা
bash
/import main-script.rsc
৫. ভেরিফাই করা
bash
# কনফিগ চেক
/export
/export compact

# সার্ভিস চেক
/ip service print
/interface print
/ip address print
কনফিগারেশন ডিটেইলস
১. সিস্টেম বেসিক
routeros
# System Identity
/system identity set name="MY-ISP-DHAKA"

# Time Zone
/system clock set time-zone-name=Asia/Dhaka

# NTP
/system ntp client set enabled=yes primary-ntp=time.google.com

# DNS
/ip dns set servers=8.8.8.8,1.1.1.1
/ip dns set allow-remote-requests=yes
/ip dns set cache-size=20480KiB
২. ব্রিজ ও VLAN
routeros
# Main Bridge
/interface bridge add name=bridge-local protocol-mode=none

# VLANs
/interface vlan add name=vlan10-PPPoE vlan-id=10 interface=bridge-local
/interface vlan add name=vlan20-MGMT vlan-id=20 interface=bridge-local
৩. IP অ্যাড্রেসিং
routeros
# Management IP
/ip address add address=192.168.20.1/24 interface=vlan20-MGMT

# Upstream IP
/ip address add address=103.xxx.xxx.2/30 interface=sfp-sfpplus1

# PPPoE Server IP
/ip address add address=10.10.0.1/16 interface=vlan10-PPPoE
৪. DHCP সার্ভার
routeros
# DHCP Pool
/ip pool add name=dhcp-pool-mgmt ranges=192.168.20.10-192.168.20.250

# DHCP Server
/ip dhcp-server add name=dhcp-mgmt interface=vlan20-MGMT address-pool=dhcp-pool-mgmt

# DHCP Network
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=8.8.8.8
নেটওয়ার্ক ডিজাইন
স্কেলিং স্ট্রেটেজি
ছোট ISP (৫০০ ইউজার)
১টি রাউটার (All-in-One)

RADIUS লোকাল বা বাহ্যিক

১টি আপস্ট্রিম

মিডিয়াম ISP (৫,০০০ ইউজার)
২-৩টি রাউটার

Border + Core + POP

RADIUS সার্ভার

২টি আপস্ট্রিম + BDIX

বড় ISP (৫০,০০০+ ইউজার)
মাল্টিপল রাউটার

সম্পূর্ণ রিডানডেন্ট ডিজাইন

BGP + OSPF + MPLS

ডেডিকেটেড RADIUS ক্লাস্টার

মাল্টিপল আপস্ট্রিম + BDIX + আইইজি

সিকিউরিটি কনফিগারেশন
ফায়ারওয়াল বেস্ট প্র্যাকটিস
ডিফল্ট ড্রপ পলিসি

routeros
/ip firewall filter add chain=input action=drop
/ip firewall filter add chain=forward action=drop
এস্টাব্লিশড কানেকশন অ্যালাউ

routeros
/ip firewall filter add chain=input action=accept connection-state=established,related
ট্রাস্টেড নেটওয়ার্ক অ্যালাউ

routeros
/ip firewall address-list add address=192.168.20.0/24 list=TRUSTED
/ip firewall filter add chain=input action=accept src-address-list=TRUSTED
DDoS প্রোটেকশন

routeros
/ip firewall raw add chain=prerouting action=drop protocol=tcp tcp-flags=syn connection-limit=25,32
সার্ভিস হার্ডেনিং
অপ্রয়োজনীয় সার্ভিস বন্ধ করুন

routeros
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
সিকিউর সার্ভিস রেস্ট্রিক্ট করুন

routeros
/ip service set winbox address=192.168.20.0/24,10.99.0.0/24
/ip service set ssh address=192.168.20.0/24,10.99.0.0/24
SSH হার্ডেনিং

routeros
/ip ssh set strong-crypto=yes
/ip ssh set host-key-size=4096
QoS ও ব্যান্ডউইথ ম্যানেজমেন্ট
PCQ সার্কিট
routeros
# Download
/queue type add name=pcq-download kind=pcq pcq-classifier=dst-address

# Upload
/queue type add name=pcq-upload kind=pcq pcq-classifier=src-address
সার্কিট ট্রি
routeros
/queue tree add name=UPLOAD parent=global queue=pcq-upload
/queue tree add name=DOWNLOAD parent=global queue=pcq-download
ব্যান্ডউইথ প্রোফাইল
প্রোফাইল	Download	Upload	ব্যবহার
5Mbps	5M	5M	বেসিক
10Mbps	10M	10M	স্ট্যান্ডার্ড
20Mbps	20M	20M	প্রিমিয়াম
50Mbps	50M	50M	বিজনেস
100Mbps	100M	100M	এন্টারপ্রাইজ
Unlimited	0	0	আনলিমিটেড
মনিটরিং ও অ্যালার্টিং
নেটওয়াচ মনিটরিং
routeros
/tool netwatch add host=8.8.8.8 interval=10s timeout=2s \
    up-script=":log info \"INTERNET UP\"" \
    down-script=":log warning \"INTERNET DOWN\""
সিস্টেম হেলথ মনিটর
routeros
/system script add name=health-check source={
    :local cpu [/system resource get cpu-load]
    :if ($cpu > 80) do={:log warning "HIGH CPU: $cpu%"}
}
/system scheduler add name=health-check interval=5m on-event=health-check
ইমেইল অ্যালার্ট
routeros
/tool e-mail set server=10.99.0.10 port=25 from=noc@isp.com
/tool e-mail send to=admin@isp.com subject="ALERT" body="High CPU"
ব্যাকআপ ও রিকভারি
অটো ব্যাকআপ
routeros
/system scheduler add name=daily-backup start-time=02:00:00 interval=1d on-event={
    /export file=backup-([/system clock get date]).rsc
    /system backup save name=backup-([/system clock get date]).backup
}
ডিজাস্টার রিকভারি
Netinstall দিয়ে রিকভারি

Netinstall টুল ডাউনলোড করুন

রাউটার Netinstall মোডে বুট করুন

RouterOS রিইনস্টল করুন

ব্যাকআপ রিস্টোর করুন

ব্যাকআপ রিস্টোর

bash
# SCP দিয়ে ব্যাকআপ কপি
scp backup-2024-01-01.backup admin@192.168.20.1:/

# রিস্টোর
/system backup load name=backup-2024-01-01.backup
ট্রাবলশুটিং
সাধারণ সমস্যা ও সমাধান
১. PPPoE কানেক্ট হচ্ছে না
সমস্যা: ইউজার লগইন করতে পারছে না

চেক করুন:

bash
# PPPoE সার্ভার স্ট্যাটাস
/interface pppoe-server monitor 0

# অ্যাক্টিভ সেশন
/ppp active print

# লগ চেক
/log print where topics~"ppp"
সমাধান:

bash
# সার্ভার রিস্টার্ট
/interface pppoe-server server disable 0
/interface pppoe-server server enable 0

# ইউজার রিক্রিয়েট
/ppp secret remove [find name=testuser]
/ppp secret add name=testuser password=test123 profile=pppoe-default
২. ইন্টারনেট নেই
সমস্যা: ইন্টারনেট কানেকশন ডাউন

চেক করুন:

bash
# আপস্ট্রিম পিং
/ping $upstream1IP

# রাউটিং টেবিল
/ip route print

# NAT চেক
/ip firewall nat print
সমাধান:

bash
# ডিফল্ট রাউট রিমুভ ও অ্যাড
/ip route remove [find dst-address=0.0.0.0/0]
/ip route add dst-address=0.0.0.0/0 gateway=$upstream1IP

# NAT রিমুভ ও অ্যাড
/ip firewall nat remove [find action=masquerade]
/ip firewall nat add chain=srcnat action=masquerade out-interface=$upstream1Interface
<div align="center"> ⬆ [উপরে যান](#-সম্পূর্ণ-ম্যানুয়াল-বাংলা)
📚 আরও ডকুমেন্টেশন: ট্রাবলশুটিং | FAQ

</div> ```