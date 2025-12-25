# Quick Start Guide - malomot@tcd.ie

## What You Need to Do Now

### Step 1: Set Up Your Web Server (5 minutes)

Run this command on your server:

```bash
cd /root/surveys
sudo ./setup-scan-disclosure-malomot.sh
```

This will:
- Install nginx web server
- Create http://95.217.3.248/about-scan.html
- Create the disclosure page with your email (malomot@tcd.ie)

### Step 2: Update DNS at Register 365 (10 minutes)

**Login:** https://www.register365.com/

**Go to:** My Domains → tcd-student-research.ie → DNS Settings

**Make these changes:**

#### Change A Record:
```
Current value: 195.7.226.12
New value:     95.217.3.248
```

#### Add AAAA Record:
```
Type:  AAAA
Name:  @ (or leave blank for root domain)
Value: 2a01:4f9:c012:e10c::1
TTL:   3600 (or default)
```

#### Add TXT Record:
```
Type:  TXT
Name:  @ (or leave blank for root domain)
Value: "TCD crypto key survey research. Contact: malomot@tcd.ie. More: http://tcd-student-research.ie/about-scan.html"
TTL:   3600 (or default)
```

**IMPORTANT:** Keep the existing SPF TXT record! You'll have TWO TXT records total.

### Step 3: Wait for DNS (1-2 hours)

DNS changes take time to propagate worldwide. Check progress:

```bash
# Check every few minutes
watch -n 60 'dig +short tcd-student-research.ie A'

# When it shows 95.217.3.248, DNS is updated!
```

### Step 4: Verify Everything Works

After DNS propagates:

```bash
# Test DNS
dig +short tcd-student-research.ie A
# Should show: 95.217.3.248

dig +short tcd-student-research.ie AAAA
# Should show: 2a01:4f9:c012:e10c::1

dig tcd-student-research.ie TXT
# Should show your scan disclosure message

# Test website
curl http://tcd-student-research.ie/about-scan.html
# Should return HTML page
```

## Understanding A vs AAAA Records

**A Record (IPv4):**
- Points to: 95.217.3.248
- Format: Four numbers (0-255) separated by dots
- Example: 192.168.1.1

**AAAA Record (IPv6):**
- Points to: 2a01:4f9:c012:e10c::1
- Format: Eight groups of hexadecimal (0-9, a-f)
- Example: 2001:0db8:85a3:0000:0000:8a2e:0370:7334

Both point to the SAME server, just using different IP versions.

## Why the Website Doesn't Work Yet

Right now, your domain points to the wrong server:

```
tcd-student-research.ie
         ↓ (DNS lookup)
    195.7.226.12  ← WRONG SERVER!
         ↓
    (Some other server, not yours)
         ↓
    404 Not Found or Connection Error
```

After you update DNS:

```
tcd-student-research.ie
         ↓ (DNS lookup)
    95.217.3.248  ← YOUR SERVER! ✓
         ↓
    nginx web server
         ↓
    /var/www/html/about-scan.html
         ↓
    Website displays! ✓
```

## Testing Before DNS Updates

You can test your website immediately using the IP address:

```bash
# This works right after running the setup script
curl http://95.217.3.248/about-scan.html

# Or open in browser:
http://95.217.3.248/about-scan.html
```

## Current Status Checklist

- [ ] Web server installed (run setup script)
- [ ] Disclosure pages created
- [ ] DNS A record updated at Register 365
- [ ] DNS AAAA record added at Register 365
- [ ] DNS TXT record added at Register 365
- [ ] Wait for DNS propagation (1-2 hours)
- [ ] Verify website works via domain name
- [ ] Ready to scan!

## All Your Server Info in One Place

```
Server IPv4:    95.217.3.248
Server IPv6:    2a01:4f9:c012:e10c::1
Domain:         tcd-student-research.ie
Email:          malomot@tcd.ie
Provider:       Hetzner
Port 25 Status: OPEN ✓

Current DNS (WRONG):
  A Record: 195.7.226.12

Correct DNS (CHANGE TO):
  A Record:    95.217.3.248
  AAAA Record: 2a01:4f9:c012:e10c::1
  TXT Record:  "TCD crypto key survey research. Contact: malomot@tcd.ie..."
```

## Quick Command Reference

```bash
# Set up web server
sudo ./setup-scan-disclosure-malomot.sh

# Test website via IP
curl http://95.217.3.248/about-scan.html

# Check DNS A record
dig +short tcd-student-research.ie A

# Check DNS AAAA record
dig +short tcd-student-research.ie AAAA

# Check DNS TXT record
dig tcd-student-research.ie TXT

# Test website via domain (after DNS updates)
curl http://tcd-student-research.ie/about-scan.html

# Test port 25
./test-port25.sh

# Start a new IE scan
cd ~/data/smtp/runs
nohup /root/code/surveys/skey-all.sh -c IE -mm -r . >ie-scan.out 2>&1 &
```

## Files for Your Documentation

I've created these comprehensive guides:

1. **DNS_RECORDS_EXPLAINED.md** - What are A and AAAA records
2. **PLAIN_ENGLISH_EXPLANATION.md** - Complete scan explanation for your document
3. **VISUAL_EXAMPLE.md** - Step-by-step visual walkthrough
4. **NETWORKING_CONCEPTS.md** - Hosts vs mail servers
5. **SCAN_ANALYSIS_GUIDE.md** - Analysis of your scan data
6. **RERUN_SCAN_GUIDE.md** - How to re-run scans
7. **test-port25.sh** - Test port 25 connectivity
8. **setup-scan-disclosure-malomot.sh** - Setup script with your email

All located in: `/root/surveys/`

---

**Next immediate action:** Run `sudo ./setup-scan-disclosure-malomot.sh`
