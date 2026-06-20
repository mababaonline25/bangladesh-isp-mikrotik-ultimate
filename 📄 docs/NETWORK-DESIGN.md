📄 NETWORK-DESIGN.md (আপডেটেড)
markdown
# Network Design Document

## Bangladesh ISP MikroTik Ultimate Setup

---

## 1. Overview

This document describes the network design for a Bangladesh ISP using MikroTik routers. The design is scalable, redundant, and secure.

---

## 2. Network Topology

### 2.1 Physical Topology
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

### 2.2 Logical Topology
┌─────────────────────────────────────────────────────────────┐
│ Layer 3 Routing │
│ (OSPF + BGP) │
└─────────────────────────────────────────────────────────────┘
│
┌─────────────────────────────────────────────────────────────┐
│ Layer 2 Switching │
│ (VLAN + Bridge) │
└─────────────────────────────────────────────────────────────┘
│
┌─────────────────────────────────────────────────────────────┐
│ Physical Layer │
│ (Ethernet + SFP) │
└─────────────────────────────────────────────────────────────┘

text

---

## 3. VLAN Design

### 3.1 VLAN Table

| VLAN ID | VLAN Name | Purpose | Subnet | Gateway |
|---------|-----------|---------|--------|---------|
| 10 | PPPoE | Customer PPPoE | 10.10.0.0/16 | 10.10.0.1 |
| 20 | Management | Network Management | 192.168.20.0/24 | 192.168.20.1 |
| 30 | Voice | IP PBX | 10.30.0.0/24 | 10.30.0.1 |
| 40 | B2B | Enterprise Clients | 10.40.0.0/24 | 10.40.0.1 |
| 50 | Guest | Guest WiFi | 10.50.0.0/24 | 10.50.0.1 |
| 60 | IPTV | IPTV Service | 10.60.0.0/24 | 10.60.0.1 |
| 70 | Storage | NAS Storage | 10.70.0.0/24 | 10.70.0.1 |
| 99 | OOB | Out-of-Band Management | 10.99.0.0/24 | 10.99.0.1 |
| 100 | Hotspot | Hotspot Network | 10.100.0.0/24 | 10.100.0.1 |
| 110 | CCTV | CCTV Network | 10.110.0.0/24 | 10.110.0.1 |
| 120 | IoT | IoT Devices | 10.120.0.0/24 | 10.120.0.1 |

### 3.2 VLAN Trunking
[Border Router] ──Trunk── [Core Router] ──Trunk── [POP Router]
│ │
[Management] [PPPoE VLAN]
[B2B VLAN] [Hotspot VLAN]
[Guest VLAN] [CCTV VLAN]
[Voice VLAN] [IoT VLAN]
[IPTV VLAN]
[Storage VLAN]

text

---

## 4. IP Addressing Plan

### 4.1 Public IP Allocation

| Network | Purpose | Gateway |
|---------|---------|---------|
| 103.xxx.xxx.0/30 | Upstream 1 | 103.xxx.xxx.1 |
| 103.yyy.yyy.0/30 | Upstream 2 | 103.yyy.yyy.1 |
| 172.16.100.0/30 | BDIX Peering | 172.16.100.1 |

### 4.2 Private IP Allocation

| Network | Purpose | Gateway | Range |
|---------|---------|---------|-------|
| 10.10.0.0/16 | PPPoE Users | 10.10.0.1 | 10.10.1.2-10.10.255.254 |
| 192.168.20.0/24 | Management | 192.168.20.1 | 192.168.20.10-192.168.20.250 |
| 10.30.0.0/24 | Voice | 10.30.0.1 | 10.30.0.10-10.30.0.250 |
| 10.40.0.0/24 | B2B | 10.40.0.1 | 10.40.0.10-10.40.0.250 |
| 10.50.0.0/24 | Guest | 10.50.0.1 | 10.50.0.10-10.50.0.250 |
| 10.60.0.0/24 | IPTV | 10.60.0.1 | 10.60.0.10-10.60.0.250 |
| 10.70.0.0/24 | Storage | 10.70.0.1 | 10.70.0.10-10.70.0.250 |
| 10.99.0.0/24 | OOB | 10.99.0.1 | 10.99.0.10-10.99.0.250 |
| 10.100.0.0/24 | Hotspot | 10.100.0.1 | 10.100.0.10-10.100.0.250 |
| 10.110.0.0/24 | CCTV | 10.110.0.1 | 10.110.0.10-10.110.0.250 |
| 10.120.0.0/24 | IoT | 10.120.0.1 | 10.120.0.10-10.120.0.250 |

---

## 5. Routing Design

### 5.1 Static Routes
Default Routes:

Primary: 0.0.0.0/0 -> 103.xxx.xxx.1 (Distance 1)

Backup: 0.0.0.0/0 -> 103.yyy.yyy.1 (Distance 2)

BDIX Routes:

103.0.0.0/8 -> 172.16.100.1 (Distance 1)

202.0.0.0/8 -> 172.16.100.1 (Distance 1)

110.0.0.0/8 -> 172.16.100.1 (Distance 1)

Internal Routes:

10.0.0.0/8 -> bridge-local (Distance 0)

192.168.20.0/24 -> bridge-local (Distance 0)

text

### 5.2 OSPF Design
Area 0 (Backbone):

Border Router

Core Router

POP Router 1

POP Router 2

POP Router 3

Area 1 (Stub):

Management Network

B2B Network

Guest Network

Voice Network

IPTV Network

Storage Network

OOB Network

Hotspot Network

CCTV Network

IoT Network

OSPF Redistribution:

Static Routes

Connected Routes

BGP Routes

text

### 5.3 BGP Design
BGP AS: 65001

BGP Peers:

Upstream 1: AS 65000

Upstream 2: AS 65000

BDIX: AS 65003

BGP Filtering:

Accept: All routes

Reject: RFC1918 routes

Reject: Default route

Set Community: 65001:100

BGP Networks:

10.0.0.0/8

192.168.20.0/24

text

---

## 6. Security Design

### 6.1 Firewall Zones
Zone 1: Untrusted (Internet)
Zone 2: DMZ (Public Services)
Zone 3: Trusted (Internal Network)
Zone 4: Management (Admin Network)

Security Levels:

Untrusted -> Trusted: Limited Access

Trusted -> Untrusted: Controlled Access

Management -> All: Full Access

All -> Management: Restricted Access

text

### 6.2 Security Policies
Default Deny Policy:

Drop all traffic by default

Allow only necessary traffic

Established Connections:

Allow established and related connections

Management Access:

Restrict to management network only

Use secure protocols (SSH, HTTPS, WinBox)

DDoS Protection:

SYN Flood Protection

UDP Flood Protection

ICMP Flood Protection

Port Scan Detection

Brute Force Protection:

SSH: 3 attempts/minute

WinBox: 3 attempts/minute

HTTP: 5 attempts/minute

Layer 7 Filtering:

Block P2P

Block Social Media (Optional)

Block Streaming (Optional)

text

---

## 7. QoS Design

### 7.1 Traffic Classes
Priority 1: Voice (SIP/RTP)
Priority 2: Video (IPTV)
Priority 3: Business Traffic (B2B)
Priority 4: Premium Customers
Priority 5: Standard Customers
Priority 6: Basic Customers
Priority 7: Guest WiFi
Priority 8: Hotspot Users
Priority 9: P2P/BitTorrent
Priority 10: Background

text

### 7.2 Bandwidth Allocation
Total Bandwidth: 10Gbps (Upstream 1) + 5Gbps (Upstream 2)

Allocation:

Voice: 200Mbps (Guaranteed)

IPTV: 500Mbps (Guaranteed)

B2B: 1Gbps (Guaranteed)

Premium: 3Gbps (Guaranteed)

Standard: 4Gbps (Best Effort)

Basic: 2Gbps (Best Effort)

Guest: 500Mbps (Limited)

Hotspot: 1Gbps (Limited)

P2P: 200Mbps (Low Priority)

Background: 100Mbps (Low Priority)

text

### 7.3 Queue Configuration
Queue Type: PCQ (Per Connection Queue)

Hierarchy:

Global
├── Total Download (PCQ)
│ ├── Voice (Priority 1)
│ ├── IPTV (Priority 2)
│ ├── B2B (Priority 3)
│ ├── Premium (Priority 4)
│ ├── Standard (Priority 5)
│ ├── Basic (Priority 6)
│ ├── Guest (Priority 7)
│ ├── Hotspot (Priority 8)
│ ├── P2P (Priority 9)
│ └── Background (Priority 10)
└── Total Upload (PCQ)
├── Voice (Priority 1)
├── IPTV (Priority 2)
├── B2B (Priority 3)
├── Premium (Priority 4)
├── Standard (Priority 5)
├── Basic (Priority 6)
├── Guest (Priority 7)
├── Hotspot (Priority 8)
├── P2P (Priority 9)
└── Background (Priority 10)

text

---

## 8. High Availability Design

### 8.1 Hardware Redundancy
Dual Power Supplies

Dual Upstream Connections

Multiple POP Routers

Backup RADIUS Server

Backup DNS Server

text

### 8.2 Network Redundancy
VRRP for Gateway Redundancy

OSPF for Route Redundancy

BGP for Peering Redundancy

LACP for Link Redundancy

Failover Scripts

text

### 8.3 Data Redundancy
Daily Backups

Weekly Backups

Monthly Backups

Offsite Backups

Configuration Management

text

---

## 9. Monitoring Design

### 9.1 Monitoring Tools
Netwatch (ICMP Monitoring)

Scripts (System Health)

Schedulers (Periodic Checks)

Logging (Event Recording)

Email Alerts (Notifications)

SNMP (Network Monitoring)

Graphing (Traffic Visualization)

Telegram Bot (Real-time Alerts)

text

### 9.2 Key Metrics
System Metrics:

CPU Usage (%)

Memory Usage (%)

Disk Usage (%)

Temperature (°C)

Uptime (Days)

Network Metrics:

Interface Traffic (bps)

Session Count

Connection Count

Packet Loss (%)

Latency (ms)

Service Metrics:

PPPoE Sessions

Hotspot Users

VPN Sessions

DHCP Leases

DNS Queries

text

---

## 10. Disaster Recovery Plan

### 10.1 Recovery Procedures
Hardware Failure:

Replace failed hardware

Restore from backup

Verify functionality

Configuration Corruption:

Restore from backup

Verify configuration

Test functionality

Network Outage:

Switch to backup upstream

Check connectivity

Monitor restoration

Security Breach:

Isolate affected systems

Investigate incident

Apply security patches

Restore from clean backup

text

### 10.2 Backup Strategy
Daily Backups (2:00 AM)

Weekly Backups (3:00 AM Sunday)

Monthly Backups (4:00 AM 1st of month)

On-Demand Backups (Before major changes)

Offsite Backups (Cloud storage)

text

---

## 11. Capacity Planning

### 11.1 Current Capacity
User Capacity: 5,000

Bandwidth Capacity: 10Gbps

Session Capacity: 10,000

Hardware: CCR1072 (Border), CCR1036 (Core), RB1100AHx4 (POP)

text

### 11.2 Growth Plan
Year 1: 5,000 users (Current)
Year 2: 10,000 users (Add 1 POP)
Year 3: 15,000 users (Add 2 POPs)
Year 4: 20,000 users (Upgrade Core)
Year 5: 25,000 users (Add Border Router)

text

---

## 12. SLA Requirements

### 12.1 Service Targets
Availability: 99.9% (8.76 hours downtime/year)

Latency: < 50ms (Internal)

Packet Loss: < 1%

Jitter: < 10ms

Throughput: Minimum 80% of bandwidth

text

### 12.2 Support Levels
Level 1: L1 Support (8am-8pm, 7 days)
Level 2: L2 Support (24x7, On-call)
Level 3: L3 Support (24x7, On-call)

text

---

## 13. Security Compliance

### 13.1 Standards
ISO 27001 (Information Security)

PCI-DSS (Payment Card Industry)

GDPR (Data Protection)

IT Act 2000 (Bangladesh)

BDIX Compliance

IIG Requirements

text

### 13.2 Audits
Weekly: Security Audit (Automated)

Monthly: Compliance Audit (Manual)

Quarterly: Penetration Test

Annually: Full Security Assessment

text

---

<div align="center">
📊 [Back to Top](#network-design-document)
</div>