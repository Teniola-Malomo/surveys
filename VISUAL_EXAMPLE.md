# Visual Example - Step by Step

## Your Actual Scan Broken Down

### Step 1: The Starting Point
```
Ireland has these IP ranges (from MaxMind):
┌─────────────────────────────────────────┐
│ 1.178.7.0/24        → 256 IPs          │
│ 2.17.172.0/22       → 1,024 IPs        │
│ 2.18.236.0/22       → 1,024 IPs        │
│ ... (5,153 more ranges)                 │
│ 87.32.0.0/12        → 1,048,576 IPs    │
├─────────────────────────────────────────┤
│ TOTAL: 18,403,316 IP addresses          │
└─────────────────────────────────────────┘
```

### Step 2: ZMap Scans Port 25
```
ZMap to 1.2.3.1:  "Are you a mail server?" → No response
ZMap to 1.2.3.2:  "Are you a mail server?" → No response
ZMap to 1.2.3.3:  "Are you a mail server?" → No response
...
ZMap to 1.2.3.100: "Are you a mail server?" → "Yes! 220 ESMTP Ready"  ✓
ZMap to 1.2.3.101: "Are you a mail server?" → No response
...
(Repeats 18,403,316 times)

Result: ~700 mail servers found (expected)
Your scan: 0 found ✗
```

### Step 3: Save the Mail Server IPs
```
File: zmap.ips
───────────────
1.2.3.100
1.2.5.234
1.2.8.99
5.6.7.42
... (700 total)
```

### Step 4: FreshGrab Scans Each Mail Server
```
For mail server 1.2.3.100:

Port 22 (SSH):
  ┌──────────────────────────────────────┐
  │ Connecting to 1.2.3.100:22...        │
  │ Banner: SSH-2.0-OpenSSH_7.9p1        │
  │ Key: [long SSH key data...]          │
  │ Fingerprint: SHA256:aB3cD4eF5...     │
  └──────────────────────────────────────┘

Port 25 (SMTP):
  ┌──────────────────────────────────────┐
  │ Connecting to 1.2.3.100:25...        │
  │ Banner: 220 mail.example.com ESMTP   │
  │ Certificate: [TLS cert data...]      │
  │ Fingerprint: SHA256:xY9zA8bC7...     │
  └──────────────────────────────────────┘

Port 443 (HTTPS):
  ┌──────────────────────────────────────┐
  │ Connecting to 1.2.3.100:443...       │
  │ Banner: Server: nginx/1.14.0         │
  │ Certificate: CN=mail.example.com     │
  │ Fingerprint: SHA256:xY9zA8bC7...     │ ← Same as port 25!
  └──────────────────────────────────────┘

... (repeat for ports 110, 143, 587, 993)
```

### Step 5: Save All Data
```
File: records.fresh
──────────────────────────────────────────────────────
Line 1 (mail server 1):
{"ip":"1.2.3.100","p22":{"banner":"SSH-2.0-OpenSSH_7.9p1","fingerprint":"SHA256:aB3cD4eF5..."},"p25":{"banner":"220 mail.example.com","fingerprint":"SHA256:xY9zA8bC7..."},...}

Line 2 (mail server 2):
{"ip":"1.2.5.234","p22":{"banner":"SSH-2.0-OpenSSH_8.2p1","fingerprint":"SHA256:lM6nO7pQ8..."},"p443":{"banner":"Server: Apache","fingerprint":"SHA256:rS9tU1vW2..."},...}

... (700 lines total, one per mail server)
```

### Step 6: Analysis Finds Patterns

**Pattern 1: Key Shared Within One Server**
```
Server: mail.company.com (1.2.3.100)

Port 25 SMTP:  🔑 SHA256:xY9zA8bC7...
Port 443 HTTPS: 🔑 SHA256:xY9zA8bC7...  ← Same key (OK, common)
Port 587 SMTP:  🔑 SHA256:xY9zA8bC7...  ← Same key (OK, common)
Port 993 IMAPS: 🔑 SHA256:xY9zA8bC7...  ← Same key (OK, common)

✓ All TLS services sharing one cert = Normal, good practice
```

**Pattern 2: Key Shared Across Multiple Servers (CLUSTER!)**
```
Server A: mail1.company.com (1.2.3.100)
  Port 443: 🔑 SHA256:xY9zA8bC7...

Server B: mail2.company.com (1.2.3.101)
  Port 443: 🔑 SHA256:xY9zA8bC7...  ← SAME KEY!

Server C: webmail.company.com (1.2.3.102)
  Port 443: 🔑 SHA256:xY9zA8bC7...  ← SAME KEY!

⚠ Three different servers sharing same key = CLUSTER
  → Saved as cluster1.json
  → Graph generated showing connections
```

**Pattern 3: SSH Key Same as TLS Key (DANGER!)**
```
Server: misconfigured.com (5.6.7.42)

Port 22 SSH:    🔑 SHA256:dAnGeR123...
Port 443 HTTPS: 🔑 SHA256:dAnGeR123...  ← SAME KEY AS SSH!

❌ SSH and TLS using same key = SECURITY PROBLEM!
   → Saved to dodgy.json for review
```

### Step 7: Generate Visualizations

**Cluster Graph (graph1.dot → graph1.svg)**
```
        mail1.company.com
              (1.2.3.100)
               /       \
              /         \
   Port 443: Same Key   Port 443: Same Key
            /             \
           /               \
  mail2.company.com    webmail.company.com
    (1.2.3.101)           (1.2.3.102)
```

## Real-World Analogy

### The 18 Million IP Addresses
```
Think of Ireland as having 18 million houses
🏠 🏠 🏠 🏠 🏠 ... (18,403,316 houses total)
```

### Finding Mail Servers (Port 25 Scan)
```
Walk to each house and ask: "Are you a post office?"

🏠 House 1: "No"
🏠 House 2: "No"
🏠 House 3: "No"
...
🏤 House 100: "Yes! I'm a post office!"  ← Mail server found!
...
🏠 House 101: "No"
...
🏤 House 234: "Yes! I'm a post office!"  ← Mail server found!
...

Result: ~700 post offices (mail servers) out of 18 million houses
```

### Checking Each Post Office's Keys
```
Post Office #1 (mail.example.com):

Front door (Port 22 SSH):     🔑 Red key
Package entrance (Port 25):   🔑 Blue key
Public counter (Port 443):    🔑 Blue key  ← Same as port 25
Back door (Port 587):         🔑 Blue key  ← Same as port 25

Notes:
- Red key (SSH) is different from Blue key (TLS) ✓ Good!
- Blue key used for all customer-facing services ✓ Good!
```

### Finding Clusters
```
Post Office A: Uses Blue key #123
Post Office B: Uses Blue key #123  ← Same key as A!
Post Office C: Uses Blue key #123  ← Same key as A and B!

All three post offices are using the exact same blue key!
This forms a CLUSTER.

Possible reasons:
- Same owner cloned the building
- Shared security company issued same key
- Franchises using template keys
```

## What You Actually See in the Files

### zmap.ips (List of Mail Servers Found)
```
1.2.3.100
1.2.5.234
1.2.8.99
5.6.7.42
... (one IP per line)
```

### records.fresh (Detailed Data Per Server)
Very long JSON lines, here's a simplified view:
```json
{
  "ip": "1.2.3.100",
  "p22": {
    "banner": "SSH-2.0-OpenSSH_7.9p1 Debian-10+deb10u2",
    "key_fingerprint": "SHA256:aB3cD4eF5gH6iJ7kL8mN9oP0qR1sT2uV3wX4yZ5"
  },
  "p25": {
    "banner": "220 mail.example.com ESMTP Postfix",
    "tls_cert_fingerprint": "SHA256:xY9zA8bC7dE6fG5hI4jK3lM2nO1pQ0"
  },
  "p443": {
    "banner": "Server: nginx/1.14.0 (Ubuntu)",
    "tls_cert_fingerprint": "SHA256:xY9zA8bC7dE6fG5hI4jK3lM2nO1pQ0",
    "certificate_common_name": "mail.example.com"
  }
}
```

### cluster1.json (Servers in One Cluster)
```json
[
  {
    "ip": "1.2.3.100",
    "hostname": "mail1.company.com",
    "shared_fingerprint": "SHA256:xY9zA8bC7...",
    "links": ["1.2.3.101", "1.2.3.102"]
  },
  {
    "ip": "1.2.3.101",
    "hostname": "mail2.company.com",
    "shared_fingerprint": "SHA256:xY9zA8bC7...",
    "links": ["1.2.3.100", "1.2.3.102"]
  },
  {
    "ip": "1.2.3.102",
    "hostname": "webmail.company.com",
    "shared_fingerprint": "SHA256:xY9zA8bC7...",
    "links": ["1.2.3.100", "1.2.3.101"]
  }
]
```

### summary.txt (Overall Statistics)
```
collisions: 89
total clusters: 23
largest cluster: 12 servers
servers with cross-protocol key reuse: 5
servers with unique keys: 611
```

## Your Specific Numbers

### Expected (Based on Your Professor)
```
IP addresses to scan:     18,403,316  ✓ (confirmed)
Mail servers expected:    ~700
Clusters expected:        ~20-30 (estimate)
Key reuse instances:      ~50-100 (estimate)
```

### What You Got
```
IP addresses scanned:     18,403,316  ✓
Mail servers found:       0           ✗
Clusters found:           0           (no data)
Key reuse instances:      0           (no data)
```

## Why This Matters

Imagine a company has 10 mail servers all using the same SSL certificate key. If an attacker steals that key from one server, they can:

1. Impersonate ALL 10 servers
2. Decrypt traffic to ALL 10 servers
3. Launch man-in-the-middle attacks on ALL 10 servers

Your research identifies these risky configurations so they can be fixed.

---

**Quick Summary for Your Document:**

*"This research scans 18.4 million IP addresses in Ireland to identify approximately 700 mail servers. For each mail server found, we connect to multiple service ports (SSH, SMTP, HTTPS, etc.) and collect two things: (1) the banner message the service sends, which identifies the software and version, and (2) the cryptographic key fingerprint, which is a unique identifier for the encryption key that service uses. We then analyze all collected data to find clusters of servers sharing the same cryptographic keys, which represents a security risk."*
