# DNS Records Explained - Plain English

## What is DNS?

**DNS (Domain Name System)** is like a phone book for the internet. It translates human-readable names into computer-readable IP addresses.

```
You type: tcd-student-research.ie
DNS translates to: 95.217.3.248
Your browser connects to: 95.217.3.248
```

## A Record (IPv4 Address)

**A** stands for "Address"

**What it does:** Points a domain name to an IPv4 address

**IPv4 format:** Four numbers separated by dots (e.g., 95.217.3.248)

**Example:**
```
Domain: tcd-student-research.ie
A Record: 95.217.3.248

When someone visits tcd-student-research.ie,
their browser connects to 95.217.3.248
```

**Real-world analogy:**
```
Domain name = "John's House"
A Record = Street address "123 Main Street"
```

## AAAA Record (IPv6 Address)

**AAAA** stands for "quad-A" (four times the size of A record)

**What it does:** Points a domain name to an IPv6 address

**IPv6 format:** Eight groups of hexadecimal numbers (e.g., 2a01:4f9:c012:e10c::1)

**Why IPv6 exists:**
- IPv4 has ~4 billion addresses (running out!)
- IPv6 has 340 undecillion addresses (basically unlimited)

**Example:**
```
Domain: tcd-student-research.ie
AAAA Record: 2a01:4f9:c012:e10c::1

When someone visits tcd-student-research.ie using IPv6,
their browser connects to 2a01:4f9:c012:e10c::1
```

## Your Server Has Both

```
IPv4: 95.217.3.248           → Use A record
IPv6: 2a01:4f9:c012:e10c::1  → Use AAAA record
```

Most modern servers have both. You should set up BOTH records so people can access your site either way.

## Other Common DNS Records

### MX Record (Mail Exchange)
**What:** Directs email to mail servers
```
Domain: tcd-student-research.ie
MX Record: mx1.reg365.net

Emails sent to @tcd-student-research.ie go to mx1.reg365.net
```

### TXT Record (Text)
**What:** Stores text information (verification, policies, etc.)

**Example uses:**
```
SPF (email authentication):
"v=spf1 include:spf.hosts.co.uk ~all"

Scan disclosure:
"TCD crypto key survey research. Contact: malomot@tcd.ie"
```

### NS Record (Name Server)
**What:** Tells which DNS servers manage the domain
```
ns0.reg365.net
ns1.reg365.net
ns2.reg365.net
```

### CNAME Record (Canonical Name)
**What:** Creates an alias from one domain to another
```
www.tcd-student-research.ie → CNAME → tcd-student-research.ie
```

## Your Current DNS Setup (WRONG)

```
Domain: tcd-student-research.ie
A Record: 195.7.226.12  ✗ (NOT your server!)
AAAA Record: (none)     ⚠ (missing)

Problem: Points to 195.7.226.12, which is NOT your scanning server
```

## What You Need to Change

### At Register 365:

**1. Update A Record:**
```
Current:  195.7.226.12
Change to: 95.217.3.248  ← Your server's IPv4
```

**2. Add AAAA Record:**
```
Type: AAAA
Value: 2a01:4f9:c012:e10c::1  ← Your server's IPv6
```

**3. Add TXT Record for scan disclosure:**
```
Type: TXT
Value: "TCD crypto key survey research. Contact: malomot@tcd.ie. More: http://tcd-student-research.ie/about-scan.html"
```

## How to Update DNS at Register 365

1. **Log in:** https://www.register365.com/
2. **Go to:** My Domains → tcd-student-research.ie
3. **Find:** DNS Settings / DNS Management / Zone Editor
4. **Locate A Record:** Shows `195.7.226.12`
5. **Edit:** Change to `95.217.3.248`
6. **Add AAAA Record:** Click "Add Record"
   - Type: AAAA
   - Name: @ (or leave blank)
   - Value: 2a01:4f9:c012:e10c::1
7. **Add TXT Record:** Click "Add Record"
   - Type: TXT
   - Name: @ (or leave blank)
   - Value: "TCD crypto key survey research. Contact: malomot@tcd.ie. More: http://tcd-student-research.ie/about-scan.html"
8. **Save Changes**

## DNS Propagation

After you update DNS records:

**Propagation time:** 1-48 hours (usually 1-2 hours)

**Why it takes time:**
- DNS information is cached around the world
- Each cache has a TTL (Time To Live)
- Caches gradually update with new information

**Check propagation:**
```bash
# Check if DNS updated
dig +short tcd-student-research.ie A
# Should show: 95.217.3.248

# Check AAAA record
dig +short tcd-student-research.ie AAAA
# Should show: 2a01:4f9:c012:e10c::1

# Check TXT record
dig +short tcd-student-research.ie TXT
# Should show your scan disclosure message
```

## About the Website

### Why http://tcd-student-research.ie/about-scan.html Doesn't Work Yet

Two reasons:

1. **DNS points to wrong IP** (195.7.226.12 instead of 95.217.3.248)
2. **No web server running** on your server yet

### To Make It Work:

**Step 1: Install web server on your server (95.217.3.248)**
```bash
sudo apt-get update
sudo apt-get install -y nginx
```

**Step 2: Create the about-scan.html page**
```bash
# Use the automated script
cd /root/surveys
sudo ./setup-scan-disclosure.sh
```

**Step 3: Update DNS at Register 365** (as described above)

**Step 4: Wait for DNS propagation** (1-2 hours)

**Step 5: Test**
```bash
curl http://tcd-student-research.ie/about-scan.html
```

## Complete Timeline

```
Now:
├─ DNS: Points to 195.7.226.12 (wrong server)
├─ Web server: Not running on your server
└─ Result: http://tcd-student-research.ie doesn't work

After running setup script:
├─ Web server: Running on 95.217.3.248
├─ Files created: /var/www/html/about-scan.html
├─ DNS: Still points to 195.7.226.12 (need to update)
└─ Result: http://95.217.3.248/about-scan.html works
           http://tcd-student-research.ie/about-scan.html still doesn't work

After updating DNS at Register 365:
├─ DNS: Updating (propagating)
├─ Wait: 1-2 hours
└─ Result: Both URLs work partially

After DNS fully propagated (1-2 hours):
├─ DNS: Points to 95.217.3.248
├─ Web server: Running with correct pages
└─ Result: http://tcd-student-research.ie/about-scan.html WORKS! ✓
```

## Summary

**A Record** = Points domain to IPv4 address (95.217.3.248)
**AAAA Record** = Points domain to IPv6 address (2a01:4f9:c012:e10c::1)

**Your domain currently points to the WRONG IP** (195.7.226.12)
**You need to change it to YOUR server's IP** (95.217.3.248)

**The website doesn't exist yet because:**
1. DNS points elsewhere
2. You haven't run the setup script yet

**Next steps:**
1. Run: `sudo ./setup-scan-disclosure.sh` (creates website)
2. Update DNS at Register 365 (points domain to your server)
3. Wait 1-2 hours (DNS propagation)
4. Website will work!
