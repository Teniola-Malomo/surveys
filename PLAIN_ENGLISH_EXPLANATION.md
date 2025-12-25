# Cryptographic Key Survey - Plain English Explanation

## The Big Picture: What Are We Actually Doing?

Imagine you have 18 million houses in Ireland. You want to:
1. **Find which houses are post offices** (mail servers)
2. **Check what keys those post offices use** for their different doors
3. **See if multiple post offices are using the same key** (security problem!)

### Breaking Down Your Questions

## Question 1: "Checking mailserver keys out of 18 million?"

**Short answer:** No, you're finding mail servers FROM 18 million, then checking those mail servers' keys.

**The process:**

```
Step 1: Scan 18,403,316 IP addresses in Ireland
        ↓
        "Knock on every door asking: Are you a post office?"
        ↓
        ~700 say "Yes, I'm a mail server"
        (17,402,616 say "No" or don't answer)

Step 2: For those ~700 mail servers only
        ↓
        "Let me check ALL the keys you use"
        ↓
        Collect keys from different services on those 700 servers

Step 3: Analyze the ~700 mail servers
        ↓
        "Are any of you sharing the same keys?"
        ↓
        Find clusters of key reuse
```

**So:**
- You scan: **18 million IPs**
- You find: **~700 mail servers**
- You analyze: **only those ~700 mail servers**

## Question 2: "What cryptographic key fingerprint?"

### What is a Cryptographic Key?

Think of it like a physical key, but for computers. When you connect to a secure service (like HTTPS websites, SSH servers, or email servers), both sides use cryptographic keys to:
- Prove their identity ("I am who I say I am")
- Encrypt communication ("Nobody can read our conversation")

### Types of Keys You're Collecting

#### SSH Keys (Port 22)
When you connect to a server via SSH (remote control):
```
Your computer: "Who are you?"
Server: "I'm server.example.com, here's my public key: XYZ123..."
```

The key proves the server's identity.

#### TLS/SSL Certificates (Ports 25, 443, 587, 993, etc.)
When you connect to secure services (HTTPS websites, secure email):
```
Your browser: "Show me your certificate"
Server: "Here's my certificate with public key: ABC456..."
```

The certificate contains a key that proves the website/server is legitimate.

### What is a Fingerprint?

A **fingerprint** is a short, unique identifier created from the full key.

**Analogy:**
- Full key = Your entire fingerprint
- Fingerprint = "Loop pattern, 12 ridges, center point at position X"

**In crypto:**
- Full RSA key = 2048 bits (very long)
- Fingerprint = `SHA256:abc123def456...` (64 characters)

**Example:**
```
Full RSA Public Key (2048 bits):
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2vXYN5xO1X...
[hundreds more characters]
-----END PUBLIC KEY-----

Fingerprint (SHA256 hash):
SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8
```

The fingerprint is easier to compare and store.

### What You're Actually Collecting

For each service on each mail server, you collect:
```json
{
  "ip": "1.2.3.4",
  "port_22_ssh": {
    "key_fingerprint": "SHA256:abc123...",
    "key_type": "RSA 2048-bit"
  },
  "port_443_https": {
    "certificate_fingerprint": "SHA256:xyz789...",
    "key_type": "RSA 2048-bit"
  }
}
```

Then you compare: "Does the SSH key fingerprint match the HTTPS key fingerprint?"

**If they match = BAD** (you should never use the same key for SSH and HTTPS!)

## Question 3: "What do you mean by banner?"

A **banner** is NOT about Windows or Linux directly. It's the greeting message a service sends when you connect.

### What is a Banner?

When you connect to any network service, it introduces itself. That introduction is the "banner."

**Example 1: Connecting to a mail server (port 25)**

```
$ telnet mail.example.com 25
Connected to mail.example.com.
220 mail.example.com ESMTP Postfix (Ubuntu)
```

The banner is: `220 mail.example.com ESMTP Postfix (Ubuntu)`

**What it tells us:**
- `220` = Ready for mail
- `mail.example.com` = Server hostname
- `ESMTP` = Protocol version
- `Postfix` = Mail software being used
- `(Ubuntu)` = Running on Ubuntu Linux

**Example 2: Connecting to SSH (port 22)**

```
$ ssh 1.2.3.4
SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5
```

Banner: `SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5`

**What it tells us:**
- `SSH-2.0` = Protocol version
- `OpenSSH_8.2p1` = SSH software and version
- `Ubuntu-4ubuntu0.5` = OS hint (Ubuntu)

**Example 3: Connecting to HTTPS (port 443)**

```
Server: nginx/1.18.0 (Ubuntu)
```

Banner tells us it's running nginx web server on Ubuntu.

### Why Collect Banners?

Banners help identify:
- **What software** is running (Postfix, Exchange, Sendmail)
- **What version** (helps identify vulnerabilities)
- **What OS** (Ubuntu, Windows, CentOS)
- **Hostname/domain** (mail.example.com)

This naming information is used in your analysis to:
- Group related servers
- Identify organizations
- Generate word clouds
- Understand deployment patterns

## Question 4: "What are the different services?"

A **service** is a program running on a server that does a specific job. Each service listens on a specific **port number**.

### Services You're Scanning

#### Port 22 - SSH (Secure Shell)
**What it does:** Remote command-line access to a server

**Example:**
```
You → SSH → Server
"Let me log in and run commands on that server"
```

**Why scan it:** SSH uses a host key. We check if this SSH key is reused elsewhere.

---

#### Port 25 - SMTP (Simple Mail Transfer Protocol)
**What it does:** Sends email between mail servers

**Example:**
```
Gmail server → SMTP → Your mail server
"Delivering an email to user@yourdomain.com"
```

**Why scan it:**
- This is how we FIND mail servers
- SMTP servers often use TLS certificates
- We collect those certificates and check for reuse

---

#### Port 110 - POP3 (Post Office Protocol v3)
**What it does:** Downloads email from server to your device

**Example:**
```
Your email app → POP3 → Mail server
"Download my emails and delete them from server"
```

**Why scan it:** POP3 often uses TLS encryption with a certificate. We check if it's the same cert as other services.

---

#### Port 143 - IMAP (Internet Message Access Protocol)
**What it does:** Accesses email on the server (keeps emails on server)

**Example:**
```
Your phone → IMAP → Mail server
"Show me my inbox, but keep the emails on the server"
```

**Why scan it:** Like POP3, uses TLS certificates we can check.

---

#### Port 443 - HTTPS (HTTP Secure)
**What it does:** Secure web browsing

**Example:**
```
Your browser → HTTPS → Web server
"Show me the website securely"
```

**Why scan it:**
- Many mail servers also run webmail (like Gmail's web interface)
- Uses TLS certificates
- We check if the webmail cert is the same as the SMTP cert

---

#### Port 587 - SMTP Submission
**What it does:** Sends email FROM your device to your mail server

**Example:**
```
Your email app → SMTP Submission → Your mail server
"Here's an email I want to send"
```

**Why scan it:** Modern, secure way to submit email. Uses TLS certificates.

---

#### Port 993 - IMAPS (IMAP Secure)
**What it does:** Encrypted version of IMAP

**Example:**
```
Your phone → IMAPS → Mail server (encrypted)
"Show me my inbox securely"
```

**Why scan it:** Always encrypted, always has a certificate to check.

---

### Service Summary Table

| Port | Service | What It Does | Uses Keys? |
|------|---------|--------------|------------|
| 22 | SSH | Remote server access | ✅ SSH Host Key |
| 25 | SMTP | Server-to-server email | ✅ TLS Certificate (optional) |
| 110 | POP3 | Download email | ✅ TLS Certificate |
| 143 | IMAP | Access email on server | ✅ TLS Certificate |
| 443 | HTTPS | Secure websites | ✅ TLS Certificate |
| 587 | SMTP Submission | Send email from client | ✅ TLS Certificate |
| 993 | IMAPS | Secure IMAP | ✅ TLS Certificate |

## Real Example: One Mail Server

Let's say you find mail server at IP `1.2.3.4`. Here's what you collect:

```
Server: mail.example.com (1.2.3.4)

Port 22 (SSH):
  Banner: "SSH-2.0-OpenSSH_7.4"
  Key Fingerprint: SHA256:abc123...
  Key Type: RSA 2048-bit

Port 25 (SMTP):
  Banner: "220 mail.example.com ESMTP Postfix"
  TLS Fingerprint: SHA256:xyz789...
  Certificate: CN=mail.example.com

Port 443 (HTTPS):
  Banner: "Server: nginx/1.14.0"
  TLS Fingerprint: SHA256:xyz789...  ← SAME as port 25! (OK)
  Certificate: CN=mail.example.com

Port 587 (SMTP Submission):
  Banner: "220 mail.example.com ESMTP Postfix"
  TLS Fingerprint: SHA256:xyz789...  ← SAME as port 25! (OK)
  Certificate: CN=mail.example.com

Port 993 (IMAPS):
  Banner: "* OK IMAP4 ready"
  TLS Fingerprint: SHA256:xyz789...  ← SAME as port 25! (OK)
  Certificate: CN=mail.example.com
```

**Analysis:**
- SSH key (abc123) is different from TLS key (xyz789) ✅ GOOD!
- All TLS services (25, 443, 587, 993) share the same cert (xyz789) ✅ GOOD!
- This is a properly configured server ✅

**Now imagine you find ANOTHER server at 1.2.3.5:**

```
Server: backup.example.com (1.2.3.5)

Port 22 (SSH):
  Key Fingerprint: SHA256:abc123...  ← SAME as 1.2.3.4!

Port 443 (HTTPS):
  TLS Fingerprint: SHA256:xyz789...  ← SAME as 1.2.3.4!
```

**This creates a CLUSTER!**
- Both servers (1.2.3.4 and 1.2.3.5) share keys
- Possible reasons: Cloned VMs, shared hosting, load balancer
- Your research identifies and visualizes this!

## The Security Issues You're Finding

### Issue 1: Cross-Protocol Key Reuse
**BAD:** Using the same key for SSH and HTTPS

```
Port 22 SSH:    Key = abc123
Port 443 HTTPS: Key = abc123  ← SAME KEY! Dangerous!
```

**Why bad:** If one service is compromised, both are compromised.

### Issue 2: Cross-Host Key Reuse
**SUSPICIOUS:** Multiple servers sharing identical keys

```
Server A: Key = xyz789
Server B: Key = xyz789  ← Same key across different hosts
Server C: Key = xyz789
```

**Why suspicious:** Could indicate:
- Cloned virtual machines without regenerating keys
- Shared infrastructure
- Potential attack vector

## Data Flow Summary

```
1. Start with 18,403,316 IP addresses (all hosts in Ireland)
                    ↓
2. ZMap scans port 25 to find mail servers
                    ↓
3. Find ~700 mail servers (expected)
                    ↓
4. FreshGrab connects to each of those 700 servers
                    ↓
5. For EACH server, check ports: 22, 25, 110, 143, 443, 587, 993
                    ↓
6. Collect:
   - Banners (server identification messages)
   - Key fingerprints (unique identifiers for cryptographic keys)
                    ↓
7. Store everything in records.fresh (one JSON per server)
                    ↓
8. SameKeys.py analyzes all collected data
                    ↓
9. Find patterns:
   - Servers sharing keys
   - Keys used across different services
                    ↓
10. Create clusters and graphs showing key reuse
```

## What Your Final Results Look Like

If your scan HAD found servers, you'd see:

### Summary File
```
Total mail servers scanned: 700
Servers with key reuse: 89
Total clusters found: 23
Largest cluster: 12 servers
```

### Cluster Example
```
Cluster #5 (8 servers sharing keys):
- mail1.company.com (1.2.3.4)
- mail2.company.com (1.2.3.5)
- smtp.company.com (1.2.3.6)
- webmail.company.com (1.2.3.7)
- backup1.company.com (1.2.3.8)
- backup2.company.com (1.2.3.9)
- mx1.company.com (1.2.3.10)
- mx2.company.com (1.2.3.11)

All using fingerprint: SHA256:abc123def456...
```

### Graph Visualization
A visual diagram showing:
- Each server as a node (circle)
- Lines between servers that share keys
- Color coding for different types of connections

## Why This Research Matters

### Security Implications
1. **Vulnerability Amplification** - If one server is hacked, all servers in a cluster are at risk
2. **Poor Key Management** - Identifies organizations with weak security practices
3. **Supply Chain Issues** - Reveals when hosting providers use default/shared keys

### Academic Value
1. **Measure real-world practices** - How common is key reuse?
2. **Geographic patterns** - Does Ireland differ from other countries?
3. **Temporal analysis** - Is key reuse increasing or decreasing?

### Practical Impact
Organizations identified in clusters can be notified to improve their security.

## Glossary

**Host** - Any computer with an IP address on a network

**Mail Server** - A host that handles email (runs SMTP software)

**Service** - A program on a host that performs a specific function (SSH, HTTPS, SMTP, etc.)

**Port** - A number (0-65535) that identifies which service you want to connect to

**Banner** - The greeting message a service sends when you connect

**Cryptographic Key** - Mathematical value used to prove identity and encrypt data

**Fingerprint** - Short, unique identifier derived from a full cryptographic key

**TLS/SSL Certificate** - Digital document containing a cryptographic key, used to prove website/server identity

**SSH Key** - Cryptographic key used by SSH servers to prove their identity

**Cluster** - Group of servers that share the same cryptographic keys

**Key Reuse** - When the same cryptographic key is used in multiple places (often a security problem)

---

**Your scan in one sentence:**
You scan 18 million IP addresses in Ireland to find ~700 mail servers, then collect their cryptographic key fingerprints from various services to identify which servers are sharing keys.
