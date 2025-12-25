# HTTPS Setup Guide

## HTTP vs HTTPS

### HTTP (Hypertext Transfer Protocol)
```
http://tcd-student-research.ie

❌ NOT encrypted
❌ Not secure
❌ Browsers show "Not Secure" warning
❌ Data can be intercepted
```

### HTTPS (HTTP Secure)
```
https://tcd-student-research.ie

✅ Encrypted with TLS/SSL
✅ Secure
✅ Browsers show padlock icon
✅ Data is protected
✅ Required for modern web
```

## Why HTTPS Matters for Your Research Site

1. **Credibility** - Visitors trust sites with HTTPS
2. **Professional** - Shows you take security seriously (ironic for a security research site!)
3. **Browser warnings** - Chrome/Firefox warn about HTTP sites
4. **Best practice** - Standard for all websites in 2025

## How HTTPS Works

### Without HTTPS (HTTP):
```
Your browser → Internet → Server
    "Hello"  →  READABLE  →  "Hi!"

Anyone watching can see: "Hello" and "Hi!"
```

### With HTTPS:
```
Your browser → Internet → Server
   "jF9k2L"  → ENCRYPTED → "xK8m3P"

Decrypts to: "Hello"     Decrypts to: "Hi!"

Anyone watching only sees encrypted gibberish
```

## What You Need for HTTPS

1. **SSL/TLS Certificate** - Proves your website's identity
2. **Private Key** - Used to encrypt/decrypt data
3. **Web server configured** - nginx needs to know to use HTTPS

## Let's Encrypt - Free SSL Certificates

**What:** Free, automated SSL certificates
**Who:** Non-profit certificate authority (CA)
**Cost:** FREE (normally costs $50-200/year)
**Renewal:** Automatic every 90 days

## Setup Process

### Prerequisites

**IMPORTANT:** DNS MUST be pointing to your server FIRST!

```bash
# Check DNS is correct
dig +short tcd-student-research.ie A
# MUST show: 95.217.3.248

# If not, update DNS at Register 365 and wait 1-2 hours
```

### Step-by-Step Setup

#### Option 1: Automated Script (Recommended)

```bash
cd /root/surveys

# Run the HTTPS setup script
sudo ./setup-https.sh
```

This will:
1. Check DNS is pointing to your server
2. Install Certbot (Let's Encrypt client)
3. Obtain SSL certificate
4. Configure nginx for HTTPS
5. Set up automatic renewal
6. Redirect HTTP → HTTPS automatically

#### Option 2: Manual Setup

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate and auto-configure nginx
sudo certbot --nginx -d tcd-student-research.ie -d www.tcd-student-research.ie

# Follow the prompts:
# - Enter email: malomot@tcd.ie
# - Agree to Terms of Service: Yes
# - Share email with EFF: No (optional)
# - Redirect HTTP to HTTPS: Yes

# Test automatic renewal
sudo certbot renew --dry-run
```

## What Certbot Does

### Before (HTTP only):
```
nginx configuration:
server {
    listen 80;
    server_name tcd-student-research.ie;
    root /var/www/html;
}
```

### After (HTTPS with redirect):
```
nginx configuration:
# HTTP - redirects to HTTPS
server {
    listen 80;
    server_name tcd-student-research.ie;
    return 301 https://$server_name$request_uri;
}

# HTTPS - serves content
server {
    listen 443 ssl;
    server_name tcd-student-research.ie;
    root /var/www/html;

    ssl_certificate /etc/letsencrypt/live/tcd-student-research.ie/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tcd-student-research.ie/privkey.pem;

    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
```

## After Setup

### Your URLs will be:
```
http://tcd-student-research.ie
  → Automatically redirects to ↓
https://tcd-student-research.ie ✓

http://tcd-student-research.ie/about-scan.html
  → Automatically redirects to ↓
https://tcd-student-research.ie/about-scan.html ✓
```

### Testing

```bash
# Test HTTPS works
curl -I https://tcd-student-research.ie/about-scan.html
# Should show: HTTP/2 200 OK

# Test HTTP redirects to HTTPS
curl -I http://tcd-student-research.ie/about-scan.html
# Should show: 301 Moved Permanently
# Location: https://tcd-student-research.ie/about-scan.html

# Check certificate
openssl s_client -connect tcd-student-research.ie:443 -servername tcd-student-research.ie < /dev/null

# Or visit in browser
firefox https://tcd-student-research.ie/about-scan.html
# Should show padlock icon 🔒
```

### Certificate Details

```bash
# View certificate info
sudo certbot certificates

# Output will show:
# - Certificate Name: tcd-student-research.ie
# - Domains: tcd-student-research.ie www.tcd-student-research.ie
# - Expiry Date: (90 days from now)
# - Certificate Path: /etc/letsencrypt/live/tcd-student-research.ie/fullchain.pem
# - Private Key Path: /etc/letsencrypt/live/tcd-student-research.ie/privkey.pem
```

## Automatic Renewal

Certbot sets up a systemd timer that renews certificates automatically:

```bash
# Check renewal timer status
sudo systemctl status certbot.timer

# Manually test renewal (doesn't actually renew)
sudo certbot renew --dry-run

# Force renewal (if needed)
sudo certbot renew --force-renewal
```

Certificates auto-renew 30 days before expiry, so you don't need to do anything!

## Updating Your Documentation

After setting up HTTPS, update references from:
```
http://tcd-student-research.ie/about-scan.html
```

To:
```
https://tcd-student-research.ie/about-scan.html
```

### Update DNS TXT Record

Change your scan disclosure TXT record:

**Old:**
```
"TCD crypto key survey research. Contact: malomot@tcd.ie. More: http://tcd-student-research.ie/about-scan.html"
```

**New:**
```
"TCD crypto key survey research. Contact: malomot@tcd.ie. More: https://tcd-student-research.ie/about-scan.html"
```

## Troubleshooting

### "DNS doesn't point to this server"

**Problem:** DNS hasn't been updated or hasn't propagated yet

**Solution:**
```bash
# Check what DNS says
dig +short tcd-student-research.ie A

# Should show: 95.217.3.248
# If not, update at Register 365 and wait 1-2 hours
```

### "Certificate validation failed"

**Problem:** Let's Encrypt can't reach your server

**Solutions:**
- Check firewall allows port 80 and 443
- Check nginx is running: `sudo systemctl status nginx`
- Check DNS is correct
- Wait longer for DNS propagation

### "Rate limit exceeded"

**Problem:** Let's Encrypt limits certificate requests

**Solution:**
- Wait 1 hour and try again
- Let's Encrypt allows 5 failures per hour

## Complete Timeline

### Day 1: Initial Setup
```
1. Run: sudo ./setup-scan-disclosure-malomot.sh
   → Creates HTTP website
   → Works at: http://95.217.3.248/about-scan.html

2. Update DNS at Register 365
   → Change A record to 95.217.3.248
   → Add AAAA and TXT records

3. Wait 1-2 hours for DNS propagation
```

### Day 1-2: After DNS Propagates
```
4. Check DNS: dig +short tcd-student-research.ie A
   → Should show: 95.217.3.248

5. Run: sudo ./setup-https.sh
   → Gets SSL certificate
   → Configures HTTPS
   → Sets up auto-renewal

6. Test: https://tcd-student-research.ie/about-scan.html
   → Should show padlock 🔒
   → HTTP automatically redirects to HTTPS
```

## Security Benefits

With HTTPS, your scan disclosure site will:

1. **Encrypt traffic** - Visitors' connections are private
2. **Prove authenticity** - Certificate shows site is really yours
3. **Prevent tampering** - Man-in-the-middle attacks blocked
4. **Show professionalism** - Especially important for security research!

## SSL/TLS Grade

After setup, test your SSL configuration:

**SSL Labs Test:**
https://www.ssllabs.com/ssltest/analyze.html?d=tcd-student-research.ie

Should get: **A or A+ rating**

## Summary

**HTTP (current):**
- ❌ Not encrypted
- ❌ Browser warnings
- ❌ Less professional

**HTTPS (after setup):**
- ✅ Encrypted
- ✅ Padlock icon
- ✅ Professional
- ✅ Free with Let's Encrypt
- ✅ Auto-renews every 90 days

**To set up:**
```bash
# 1. Make sure DNS is updated first
dig +short tcd-student-research.ie A
# Should show: 95.217.3.248

# 2. Run the HTTPS setup script
cd /root/surveys
sudo ./setup-https.sh

# 3. Done! Visit:
https://tcd-student-research.ie/about-scan.html
```

---

**Recommended:** Always use HTTPS for any public-facing website, especially for security research!
