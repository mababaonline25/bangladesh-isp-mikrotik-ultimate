📄 FAQ-BANGLA.md (আপডেটেড)
markdown
# সাধারণ জিজ্ঞাসা (FAQ) - বাংলা

## MikroTik ISP সেটআপ সম্পর্কে সাধারণ প্রশ্ন ও উত্তর

---

## ১. ইনস্টলেশন সম্পর্কিত

### প্রশ্ন: কোন MikroTik রাউটার ব্যবহার করব?
**উত্তর:** ইউজার সংখ্যার উপর নির্ভর করে:
- **৫০০ ইউজার:** RB1100AHx4, CCR1009
- **৫,০০০ ইউজার:** CCR1036, CCR1072
- **৫০,০০০+ ইউজার:** CCR2216 বা একাধিক CCR

### প্রশ্ন: RouterOS কোন ভার্সন ব্যবহার করব?
**উত্তর:** RouterOS 7.x ব্যবহার করুন। এতে নতুন ফিচার এবং সিকিউরিটি আপডেট আছে।

### প্রশ্ন: স্ক্রিপ্ট রান করার পর রাউটার রিবুট হয় কেন?
**উত্তর:** স্ক্রিপ্টের শেষে রিবুট কমান্ড আছে। এটি অপশনাল। চাইলে রিমুভ করতে পারেন।

---

## ২. ভেরিয়েবল সম্পর্কিত

### প্রশ্ন: সব ফিচার কি ডিফল্টভাবে চালু থাকে?
**উত্তর:** হ্যাঁ! নতুন ভার্সনে **সব ফিচার ডিফল্টভাবে YES (চালু)** থাকে।

```bash
:global enableBGP "yes"    # BGP চালু (ডিফল্ট)
:global enableVRRP "yes"   # VRRP চালু (ডিফল্ট)
:global enableIPv6 "yes"   # IPv6 চালু (ডিফল্ট)
আপনি চাইলে যেকোনো ফিচার NO করে বন্ধ করতে পারেন:

bash
:global enableBGP "no"     # BGP বন্ধ
:global enableVPN "no"     # VPN বন্ধ
প্রশ্ন: ফিচার অন/অফ করতে কি নতুন করে স্ক্রিপ্ট রান করতে হবে?
উত্তর: না! শুধু ভেরিয়েবল YES/NO করলেই হবে। স্ক্রিপ্ট পুনরায় রান করতে হবে না।

bash
# BGP বন্ধ করতে
:global enableBGP "no"

# BGP আবার চালু করতে
:global enableBGP "yes"
প্রশ্ন: POP রাউটার বানাতে কি করতে হবে?
উত্তর: শুধু এই কমান্ডগুলো দিন:

bash
:global routerRole "pop"
:global enableBGP "no"
:global enableOSPF "no"
:global enableVPN "no"
:global enableProxy "no"
এতেই হয়ে গেল! দ্বিতীয়বার স্ক্রিপ্ট রান করতে হবে না।

প্রশ্ন: রাউটারের রোল কয়েকবার পরিবর্তন করা যায়?
উত্তর: হ্যাঁ, যতবার ইচ্ছা পরিবর্তন করা যায়। শুধু ভেরিয়েবল পরিবর্তন করলেই হবে।

bash
# POP → Border
:global routerRole "border"
:global enableBGP "yes"

# Border → Core
:global routerRole "core"
:global enablePPPoE "no"
:global enableHotspot "no"
৩. কনফিগারেশন সম্পর্কিত
প্রশ্ন: VLAN কনফিগারেশন কিভাবে করব?
উত্তর:

bash
/interface vlan add name=vlan10-PPPoE vlan-id=10 interface=bridge-local
/interface vlan add name=vlan20-MGMT vlan-id=20 interface=bridge-local
প্রশ্ন: IP অ্যাড্রেসিং প্ল্যান কি?
উত্তর:

Management: 192.168.20.0/24

PPPoE: 10.10.0.0/16

B2B: 10.40.0.0/24

Guest: 10.50.0.0/24

Hotspot: 10.100.0.0/24

প্রশ্ন: DHCP সার্ভার কিভাবে কনফিগার করব?
উত্তর:

bash
/ip pool add name=dhcp-pool ranges=192.168.20.10-192.168.20.250
/ip dhcp-server add name=dhcp-server interface=vlan20-MGMT address-pool=dhcp-pool
/ip dhcp-server network add address=192.168.20.0/24 gateway=192.168.20.1
৪. PPPoE সম্পর্কিত
প্রশ্ন: PPPoE সার্ভার কিভাবে সেটআপ করব?
উত্তর:

bash
/ip pool add name=pppoe-pool ranges=10.10.1.2-10.10.255.254
/ppp profile add name=pppoe-default local-address=10.10.0.1 remote-address=pppoe-pool
/interface pppoe-server server add service-name="ISP-PPPoE" interface=vlan10-PPPoE
প্রশ্ন: কত ইউজার সাপোর্ট করে?
উত্তর: রাউটার মডেলের উপর নির্ভর করে। CCR সিরিজ ৫০,০০০+ ইউজার সাপোর্ট করে।

প্রশ্ন: ইউজার কিভাবে অ্যাড করব?
উত্তর:

bash
/ppp secret add name=username password=password profile=pppoe-default service=pppoe
৫. RADIUS সম্পর্কিত
প্রশ্ন: RADIUS ব্যবহার করব নাকি লোকাল?
উত্তর:

RADIUS: বড় ISP, বিলিং ইন্টিগ্রেশন, সেন্ট্রালাইজড ম্যানেজমেন্ট

লোকাল: ছোট ISP, সহজ সেটআপ, কম খরচ

প্রশ্ন: RADIUS কিভাবে কনফিগার করব?
উত্তর:

bash
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/ppp aaa set use-radius=yes accounting=yes interim-update=5m
প্রশ্ন: RADIUS ফেইলওভার কিভাবে করব?
উত্তর:

bash
/radius add address=10.1.200.2 secret=radius-secret service=ppp,hotspot
/radius add address=10.1.200.3 secret=radius-secret service=ppp,hotspot
/radius set [find] dead-time=5m
৬. BDIX সম্পর্কিত
প্রশ্ন: BDIX কিভাবে কনফিগার করব?
উত্তর:

bash
/ip address add address=172.16.100.2/30 interface=sfp-sfpplus3
/ip route add dst-address=103.0.0.0/8 gateway=172.16.100.1
প্রশ্ন: BDIX ট্রাফিক কিভাবে রাউট করব?
উত্তর: BDIX IP রেঞ্জগুলোর জন্য আলাদা রাউট যোগ করুন:

bash
/ip route add dst-address=103.0.0.0/8 gateway=$bdixPeerIP
/ip route add dst-address=202.0.0.0/8 gateway=$bdixPeerIP
৭. ফায়ারওয়াল সম্পর্কিত
প্রশ্ন: DDoS প্রোটেকশন কিভাবে করব?
উত্তর:

bash
/ip firewall raw add chain=prerouting action=drop connection-state=invalid
/ip firewall raw add chain=prerouting action=add-src-to-address-list \
    protocol=tcp psd=21,3s,3,1 address-list=DDOS-BLACKLIST
/ip firewall raw add chain=prerouting action=drop src-address-list=DDOS-BLACKLIST
প্রশ্ন: কোন পোর্ট খোলা রাখব?
উত্তর:

WinBox: 8291 (management)

SSH: 22 (management)

PPPoE: 10 (VLAN)

VPN: 1723, 1701, 443, 1194

Hotspot: 100 (VLAN)

৮. QoS সম্পর্কিত
প্রশ্ন: ব্যান্ডউইথ কিভাবে ম্যানেজ করব?
উত্তর:

bash
/queue type add name=pcq-download kind=pcq pcq-classifier=dst-address
/queue tree add name=TOTAL-DOWNLOAD parent=global queue=pcq-download
/queue simple add name=USER-10MBPS target=10.10.0.0/16 max-limit=10M/10M
প্রশ্ন: PCQ এবং Simple Queue এর মধ্যে পার্থক্য কি?
উত্তর:

PCQ: প্রতিটি ইউজার আলাদা, ফেয়ার শেয়ারিং

Simple Queue: গ্রুপ বা নির্দিষ্ট ইউজারের জন্য

৯. VPN সম্পর্কিত
প্রশ্ন: কোন VPN ব্যবহার করব?
উত্তর:

WireGuard: দ্রুত, আধুনিক (সুপারিশ)

OpenVPN: নিরাপদ, ক্রস-প্ল্যাটফর্ম

SSTP: Windows এ কাজ করে

L2TP: পুরানো ডিভাইসের জন্য

প্রশ্ন: VPN সিকিউরিটি কিভাবে নিশ্চিত করব?
উত্তর:

bash
/ppp profile set [find] use-encryption=required
/ip ipsec proposal add auth-algorithms=sha256 enc-algorithms=aes-256-cbc
১০. হটস্পট সম্পর্কিত
প্রশ্ন: হটস্পট কিভাবে সেটআপ করব?
উত্তর:

bash
/ip hotspot profile add name=hotspot-profile hotspot-address=10.100.0.1
/ip hotspot add name=hotspot1 interface=vlan100-Hotspot profile=hotspot-profile
প্রশ্ন: ওয়াল্ড গার্ডেন কিভাবে কনফিগার করব?
উত্তর:

bash
/ip hotspot walled-garden ip add dst-address=8.8.8.8 action=accept
/ip hotspot walled-garden add dst-host=*.google.com action=accept
১১. মনিটরিং সম্পর্কিত
প্রশ্ন: কিভাবে মনিটর করব?
উত্তর:

Netwatch: আপস্ট্রিম মনিটরিং

Scripts: সিস্টেম হেলথ

Schedulers: পর্যায়ক্রমিক চেক

SNMP: নেটওয়ার্ক মনিটরিং টুলের সাথে ইন্টিগ্রেশন

প্রশ্ন: অ্যালার্ট কিভাবে পাব?
উত্তর:

Email: /tool e-mail

Telegram: Telegram Bot API

Syslog: Remote syslog server

১২. ব্যাকআপ সম্পর্কিত
প্রশ্ন: ব্যাকআপ কিভাবে নেব?
উত্তর:

bash
# Manual
/export file=backup.rsc
/system backup save name=backup.backup

# Automated (daily at 2 AM)
/system scheduler add name=daily-backup start-time=02:00:00 interval=1d \
    on-event="/export file=backup-\$[/system clock get date].rsc"
প্রশ্ন: ব্যাকআপ কোথায় রাখব?
উত্তর:

লোকাল স্টোরেজ

FTP/SFTP সার্ভার

Cloud Storage (Google Drive, Dropbox)

Email backup

১৩. সিকিউরিটি সম্পর্কিত
প্রশ্ন: রাউটার সিকিউরিটি কিভাবে নিশ্চিত করব?
উত্তর:

শক্তিশালী পাসওয়ার্ড ব্যবহার করুন

অপ্রয়োজনীয় সার্ভিস বন্ধ রাখুন

DDoS প্রোটেকশন চালু রাখুন

নিয়মিত আপডেট দিন

লগিং চালু রাখুন

ব্যাকআপ রাখুন

প্রশ্ন: ডিফল্ট পাসওয়ার্ড কিভাবে পরিবর্তন করব?
উত্তর:

bash
/user set admin password=new-strong-password
১৪. আপগ্রেড সম্পর্কিত
প্রশ্ন: RouterOS কিভাবে আপগ্রেড করব?
উত্তর:

bash
/system package update check-for-updates
/system package update download
/system package update install
প্রশ্ন: আপগ্রেডের পর কনফিগ হারিয়ে যায়?
উত্তর: না, কনফিগ সংরক্ষিত থাকে। তবে ব্যাকআপ নিয়ে রাখা ভালো।

১৫. পারফরম্যান্স সম্পর্কিত
প্রশ্ন: রাউটার স্লো কেন?
উত্তর:

CPU/মেমোরি হাই

অনেক ফায়ারওয়াল রুল

অনেক কানেকশন

পুরানো হার্ডওয়্যার

প্রশ্ন: পারফরম্যান্স কিভাবে অপটিমাইজ করব?
উত্তর:

Fasttrack চালু করুন

ফায়ারওয়াল রুল কমিয়ে দিন

Connection tracking লিমিট সেট করুন

DNS ক্যাশিং চালু রাখুন

১৬. ট্রাবলশুটিং সম্পর্কিত
প্রশ্ন: PPPoE কাজ করছে না কেন?
উত্তর:

VLAN চেক করুন

ফায়ারওয়াল চেক করুন

RADIUS চেক করুন (যদি ব্যবহার করেন)

লগ চেক করুন

প্রশ্ন: ইন্টারনেট নেই কেন?
উত্তর:

আপস্ট্রিম চেক করুন

রাউটিং চেক করুন

NAT চেক করুন

DNS চেক করুন

প্রশ্ন: VPN কাজ করছে না কেন?
উত্তর:

সার্ভিস চালু আছে কিনা চেক করুন

ফায়ারওয়াল চেক করুন

পোর্ট ফরওয়ার্ডিং চেক করুন

ক্লায়েন্ট কনফিগ চেক করুন

<div align="center"> ❓ [Back to Top](#সাধারণ-জিজ্ঞাসা-faq---বাংলা) </div> ```