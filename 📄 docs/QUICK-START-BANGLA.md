📄 QUICK-START-BANGLA.md (আপডেটেড)
markdown
# 🇧🇩 কুইক স্টার্ট গাইড (বাংলা)

## MikroTik ISP সেটআপ - ৫ মিনিটে শুরু করুন

---

## 📋 প্রয়োজনীয়তা

1. **MikroTik RouterOS 7.x** সমর্থিত রাউটার
2. **WinBox** বা **SSH** অ্যাক্সেস
3. **ইন্টারনেট কানেকশন** (কনফিগ ডাউনলোডের জন্য)
4. **বেসিক নেটওয়ার্কিং জ্ঞান**

---

## 🚀 ধাপ ১: রাউটার প্রস্তুত করুন

### WinBox দিয়ে সংযোগ:
1. WinBox খুলুন
2. রাউটারের MAC বা IP এড্রেস দিন
3. ডিফল্ট ইউজার: `admin`, পাসওয়ার্ড: (ফাঁকা)
4. সংযোগ করুন

### SSH দিয়ে সংযোগ:
```bash
ssh admin@192.168.88.1
ফ্যাক্টরি রিসেট (অপশনাল):
bash
/system reset-configuration
⚙️ ধাপ ২: ভেরিয়েবল সেট করুন
ডিফল্ট সেটআপ (সব ফিচার চালু):
bash
# আপনার কোম্পানির নাম
:global companyName "MY-ISP-BD"

# রাউটার রোল (ডিফল্ট: all-in-one)
:global routerRole "all-in-one"

# আপস্ট্রিম আইপি
:global upstream1IP "103.xxx.xxx.1"
:global upstream1Interface "sfp-sfpplus1"

# BDIX পিয়ার IP
:global bdixPeerIP "172.16.100.1"
:global bdixPeerInterface "sfp-sfpplus3"

# RADIUS সেটআপ (যদি ব্যবহার করেন)
:global useRadius "yes"
:global radiusPrimaryIP "10.1.200.2"
:global radiusPrimarySecret "আপনার-সিক্রেট-কী"
✅ সব ফিচার ডিফল্ট YES
নতুন ভার্সনে সব ফিচার ডিফল্টভাবে YES (চালু) থাকে। চাইলে যেকোনো ফিচার বন্ধ করতে পারেন:

bash
# POP রাউটার বানাতে (শুধু কয়েকটি ফিচার বন্ধ)
:global routerRole "pop"
:global enableBGP "no"
:global enableOSPF "no"
:global enableVPN "no"
:global enableProxy "no"

# Border রাউটার বানাতে
:global routerRole "border"
:global enablePPPoE "no"
:global enableHotspot "no"
:global enableVPN "no"

# Core রাউটার বানাতে
:global routerRole "core"
:global enablePPPoE "no"
:global enableHotspot "no"
:global enableVPN "no"
📋 ফিচার অন/অফ করার নিয়ম:
bash
# যেকোনো ফিচার চালু করতে:
:global enableBGP "yes"

# যেকোনো ফিচার বন্ধ করতে:
:global enableBGP "no"

# রাউটার রোল পরিবর্তন করতে:
:global routerRole "pop"      # POP রাউটার
:global routerRole "border"   # Border রাউটার
:global routerRole "core"     # Core রাউটার
📥 ধাপ ৩: স্ক্রিপ্ট ডাউনলোড ও রান করুন
GitHub থেকে ডাউনলোড:
bash
/tool fetch url="https://raw.githubusercontent.com/yourusername/bangladesh-isp-ultimate-setup/main/main-script.rsc"
অথবা সরাসরি কপি-পেস্ট:
main-script.rsc ফাইলটি খুলুন

সব কন্টেন্ট কপি করুন

WinBox বা SSH-তে পেস্ট করুন

স্ক্রিপ্ট রান করুন:
bash
/import main-script.rsc
✅ ধাপ ৪: ভেরিফাই করুন
PPPoE সার্ভার চেক:
bash
/interface pppoe-server server print
/interface pppoe-server monitor 0
ইন্টারনেট টেস্ট:
bash
/ping 8.8.8.8
/ping google.com
টেস্ট ইউজার তৈরি:
bash
/ppp secret add name=testuser password=test123 profile=PKG-10-MBPS service=pppoe
ইউজার লগইন টেস্ট:
PPPoE কানেকশন তৈরি করুন

ইউজারনেম: testuser

পাসওয়ার্ড: test123

কানেক্ট করুন

🔍 ধাপ ৫: মনিটরিং চেক
অ্যাক্টিভ ইউজার দেখুন:
bash
/ppp active print
ব্যান্ডউইথ মনিটর:
bash
/tool bandwidth-test 8.8.8.8
সিস্টেম হেলথ:
bash
/system script run system-health
লগ চেক:
bash
/log print
🛡️ ধাপ ৬: নিরাপত্তা পরীক্ষা
সিকিউরিটি অডিট:
bash
/system script run security-audit
কুইক চেক:
bash
/system script run quick-security-check
🎉 সম্পন্ন!
আপনার ISP MikroTik রাউটার সম্পূর্ণ কনফিগার হয়ে গেছে!

পরবর্তী পদক্ষেপ:
📝 সম্পূর্ণ ম্যানুয়াল পড়ুন

🛠️ RADIUS সেটআপ করুন

💰 বিলিং ইন্টিগ্রেশন

🔧 ট্রাবলশুটিং

❓ সাধারণ সমস্যা
সমস্যা: রাউটার রিবুট হচ্ছে না
সমাধান: ম্যানুয়ালি রিবুট করুন

bash
/system reboot
সমস্যা: PPPoE কাজ করছে না
সমাধান: VLAN চেক করুন

bash
/interface vlan print
/interface bridge vlan print
সমস্যা: ইন্টারনেট নেই
সমাধান: আপস্ট্রিম চেক করুন

bash
/ping $upstream1IP
/ip route print
সমস্যা: RADIUS কাজ করছে না
সমাধান: RADIUS স্ট্যাটাস চেক করুন

bash
/radius print
/ppp aaa print
📞 সাপোর্ট
💬 GitHub Issues

📧 ইমেইল: support@yourisp.com

📱 টেলিগ্রাম: @Bangladesh_ISP_Community

<div align="center"> ⬆ [উপরে যান](#-কুইক-স্টার্ট-গাইড-বাংলা)
⭐ ভালো লাগলে স্টার দিন! ⭐

</div> ```