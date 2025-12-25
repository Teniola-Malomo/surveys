# Scanning Disclosure Setup Guide

## Current Situation

### Your Scanning Host IP Addresses
- **IPv4:** `95.217.3.248`
- **IPv6:** `2a01:4f9:c012:e10c::1`
- **Reverse DNS:** `crypto-survey-webserver.` (good!)

### Your Domain: tcd-student-research.ie
- **Current A Record:** `195.7.226.12` ⚠️ (WRONG - doesn't match your scanning host!)
- **Current TXT Record:** `"v=spf1 include:spf.hosts.co.uk ~all"` (SPF only, no scan info)
- **Registrar:** Register 365
- **Web Server:** Not running on this host

## What You Need to Do

### 1. Update DNS Records at Register 365

Log in to Register 365 and update these DNS records:

#### A Record
```
Type: A
Name: @ (or tcd-student-research.ie)
Value: 95.217.3.248
TTL: 3600 (or default)
```

#### AAAA Record (IPv6 - optional but recommended)
```
Type: AAAA
Name: @ (or tcd-student-research.ie)
Value: 2a01:4f9:c012:e10c::1
TTL: 3600
```

#### TXT Record (Scanning Disclosure)
Add a NEW TXT record (keep the existing SPF one):

```
Type: TXT
Name: @ (or tcd-student-research.ie)
Value: "TCD crypto key survey research. Contact: [your-email]. More info: http://tcd-student-research.ie/about-scan.html"
TTL: 3600
```

### 2. Set Up a Web Server

Install and configure nginx to serve information about your scanning:

```bash
# Install nginx
sudo apt-get update
sudo apt-get install -y nginx

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 3. Create Scan Disclosure Web Page

Create an explanation page at `/var/www/html/about-scan.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>TCD Student Research - Cryptographic Key Survey</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #003366; }
        .contact { background: #f0f0f0; padding: 15px; border-left: 4px solid #003366; }
    </style>
</head>
<body>
    <h1>TCD Student Research - Cryptographic Key Survey</h1>

    <p>This server (95.217.3.248 / 2a01:4f9:c012:e10c::1) is conducting academic research
    as part of a Trinity College Dublin (TCD) student project.</p>

    <h2>What We're Doing</h2>
    <p>We are conducting a survey of cryptographic key usage on email servers (SMTP).
    This research identifies cases where SSH and TLS cryptographic keys are reused
    across different servers and protocols.</p>

    <h2>Research Details</h2>
    <ul>
        <li><strong>Research Type:</strong> Cryptographic key fingerprinting</li>
        <li><strong>Ports Scanned:</strong> 22 (SSH), 25 (SMTP), 110 (POP3), 143 (IMAP), 443 (HTTPS), 587 (SMTP), 993 (IMAPS)</li>
        <li><strong>Method:</strong> Non-intrusive banner collection and key fingerprinting</li>
        <li><strong>Rate:</strong> Intentionally slow (~147 packets/sec) to minimize impact</li>
        <li><strong>Data Collected:</strong> IP addresses, port banners, cryptographic key fingerprints</li>
        <li><strong>Data Retention:</strong> Research purposes only, not shared publicly with identifying information</li>
    </ul>

    <h2>Related Work</h2>
    <p>This research builds on prior work on cryptographic key reuse:</p>
    <ul>
        <li><a href="https://eprint.iacr.org/2018/299">Research Paper: Clusters of Re-Used Keys</a></li>
        <li><a href="https://github.com/sftcd/surveys">GitHub Repository</a></li>
    </ul>

    <h2>Privacy & Ethics</h2>
    <p>This scan:</p>
    <ul>
        <li>Does NOT attempt to exploit vulnerabilities</li>
        <li>Does NOT attempt to access data</li>
        <li>Does NOT perform brute-force or password attacks</li>
        <li>Only collects publicly-available server banners and key fingerprints</li>
        <li>Complies with academic research ethics guidelines</li>
    </ul>

    <div class="contact">
        <h2>Contact Information</h2>
        <p><strong>Institution:</strong> Trinity College Dublin (TCD)</p>
        <p><strong>Email:</strong> malomot@tcd.ie</p>
        <p><strong>Website:</strong> http://tcd-student-research.ie</p>
        <p>If you would like to opt-out of this survey or have questions, please contact us.</p>
    </div>

    <h2>Opt-Out</h2>
    <p>If you would like your IP address excluded from this research, please email us with:</p>
    <ul>
        <li>Your IP address or IP range</li>
        <li>Your organization name (optional)</li>
    </ul>
    <p>We will add your IP to our exclusion list.</p>

    <hr>
    <p><small>Last Updated: December 8, 2025</small></p>
</body>
</html>
```

### 4. Create Index Page

Create `/var/www/html/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>TCD Student Research</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; text-align: center; }
    </style>
</head>
<body>
    <h1>TCD Student Research</h1>
    <p>This site hosts information about academic research being conducted by Trinity College Dublin students.</p>
    <p><a href="/about-scan.html">About Our Cryptographic Key Survey</a></p>
</body>
</html>
```

### 5. Verify Setup

After DNS propagation (can take up to 48 hours, but usually 1-2 hours):

```bash
# Check DNS is pointing to your IP
dig +short tcd-student-research.ie A
# Should return: 95.217.3.248

# Check TXT record
dig +short tcd-student-research.ie TXT
# Should show your scan disclosure message

# Check web server is accessible
curl http://95.217.3.248/about-scan.html
curl http://tcd-student-research.ie/about-scan.html
```

## Quick Setup Script

Run this on your scanning host:

```bash
#!/bin/bash

# Install nginx
sudo apt-get update
sudo apt-get install -y nginx

# Create about page (you'll need to edit this with your email!)
sudo tee /var/www/html/about-scan.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>TCD Student Research - Cryptographic Key Survey</title>
</head>
<body>
    <h1>TCD Student Research - Cryptographic Key Survey</h1>
    <p>Research scanning from 95.217.3.248</p>
    <p>Contact: [YOUR-EMAIL]@tcd.ie</p>
    <p><a href="https://eprint.iacr.org/2018/299">Research Paper</a></p>
</body>
</html>
EOF

# Create index
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head><title>TCD Student Research</title></head>
<body>
    <h1>TCD Student Research</h1>
    <p><a href="/about-scan.html">About Our Cryptographic Key Survey</a></p>
</body>
</html>
EOF

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx

echo "Web server setup complete!"
echo "Now update DNS at Register 365 to point to 95.217.3.248"
```

## Register 365 DNS Update Instructions

1. Log in to https://www.register365.com/
2. Go to "My Domains" or "Domain Management"
3. Select "tcd-student-research.ie"
4. Look for "DNS Management" or "DNS Records"
5. Find the A record currently pointing to `195.7.226.12`
6. Change it to `95.217.3.248`
7. Add a new TXT record with scan disclosure information
8. Save changes
9. Wait 1-2 hours for DNS propagation

## Testing After Setup

```bash
# Test from this server
curl -I http://tcd-student-research.ie/about-scan.html

# Check if you can make outbound port 25 connections
telnet gmail-smtp-in.l.google.com 25
```

## Important Notes

1. **Update your email:** Replace `[YOUR-EMAIL]` with your actual TCD email in the HTML
2. **Ethics approval:** Make sure you have proper ethics approval from TCD for network scanning
3. **Port 25 blocking:** Your scan found 0 results because port 25 is likely blocked. Contact your hosting provider (Hetzner, based on the IP) to enable outbound port 25
4. **Notification:** Some providers require you to notify them before scanning to avoid account suspension

## Your Current Status

- ✅ Reverse DNS set up (crypto-survey-webserver)
- ⚠️ DNS A record pointing to wrong IP (needs update)
- ❌ No web server running (needs setup)
- ❌ No scan disclosure TXT record (needs adding)
- ⚠️ Port 25 likely blocked (contact Hetzner)

---

**Next Steps:**
1. Run the quick setup script above to install nginx
2. Edit the HTML files with your actual email
3. Update DNS at Register 365
4. Contact Hetzner about enabling outbound port 25
5. Wait for DNS propagation (1-2 hours)
6. Verify everything works
