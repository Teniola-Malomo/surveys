#!/bin/bash

# Complete Setup Script for TCD Crypto Survey Disclosure
# Email: malomot@tcd.ie
# Domain: tcd-student-research.ie

set -e

DOMAIN="tcd-student-research.ie"
EMAIL="malomot@tcd.ie"
CURRENT_IPV4=$(curl -s -4 ifconfig.me)
CURRENT_IPV6=$(curl -s -6 ifconfig.me 2>/dev/null || echo "Not available")

echo "============================================================"
echo "  TCD Cryptographic Key Survey - Complete Setup"
echo "============================================================"
echo ""
echo "This script will:"
echo "  1. Install nginx web server"
echo "  2. Create disclosure web pages"
echo "  3. Set up HTTPS with Let's Encrypt (if DNS is ready)"
echo ""
echo "Domain: $DOMAIN"
echo "Email:  $EMAIL"
echo "IPv4:   $CURRENT_IPV4"
echo "IPv6:   $CURRENT_IPV6"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "============================================================"
echo "Step 1: Installing nginx web server"
echo "============================================================"
sudo apt-get update -qq
sudo apt-get install -y nginx

echo ""
echo "============================================================"
echo "Step 2: Creating disclosure pages"
echo "============================================================"

# Create about-scan.html
sudo tee /var/www/html/about-scan.html > /dev/null << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TCD Student Research - Cryptographic Key Survey</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; line-height: 1.6; }
        h1 { color: #003366; }
        h2 { color: #0055aa; margin-top: 30px; }
        .contact { background: #f0f0f0; padding: 15px; border-left: 4px solid #003366; margin: 20px 0; }
        ul { margin: 10px 0; }
        li { margin: 8px 0; }
        a { color: #0055aa; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>TCD Student Research - Cryptographic Key Survey</h1>

    <p>This server ($CURRENT_IPV4) is conducting academic research
    as part of a Trinity College Dublin (TCD) student project.</p>

    <h2>What We're Doing</h2>
    <p>We are conducting a survey of cryptographic key usage on email servers (SMTP).
    This research identifies cases where SSH and TLS cryptographic keys are reused
    across different servers and protocols.</p>

    <h2>Research Details</h2>
    <ul>
        <li><strong>Research Type:</strong> Cryptographic key fingerprinting</li>
        <li><strong>Target:</strong> Mail servers (SMTP) in Ireland and other countries</li>
        <li><strong>Ports Scanned:</strong> 22 (SSH), 25 (SMTP), 110 (POP3), 143 (IMAP), 443 (HTTPS), 587 (SMTP), 993 (IMAPS)</li>
        <li><strong>Method:</strong> Non-intrusive banner collection and key fingerprinting</li>
        <li><strong>Scan Rate:</strong> Intentionally slow (~147 packets/sec) to minimize network impact</li>
        <li><strong>Data Collected:</strong> IP addresses, port banners, cryptographic key fingerprints, hostnames</li>
        <li><strong>Data Retention:</strong> Research purposes only, not shared publicly with identifying information</li>
    </ul>

    <h2>What We Do NOT Do</h2>
    <p>This scan:</p>
    <ul>
        <li>Does NOT attempt to exploit vulnerabilities</li>
        <li>Does NOT attempt to access data or systems</li>
        <li>Does NOT perform brute-force or password attacks</li>
        <li>Does NOT send spam or malicious traffic</li>
        <li>Only collects publicly-available server banners and key fingerprints</li>
    </ul>

    <h2>Related Work</h2>
    <p>This research builds on prior work on cryptographic key reuse:</p>
    <ul>
        <li><a href="https://eprint.iacr.org/2018/299">Research Paper: Clusters of Re-Used Keys (ePrint 2018/299)</a></li>
        <li><a href="https://github.com/sftcd/surveys">GitHub Repository: sftcd/surveys</a></li>
        <li><a href="https://down.dsg.cs.tcd.ie/runs/">Sample Results and Graphs</a></li>
    </ul>

    <h2>Privacy & Ethics</h2>
    <p>This research:</p>
    <ul>
        <li>Complies with academic research ethics guidelines</li>
        <li>Follows responsible disclosure practices</li>
        <li>Does not publicly identify vulnerable systems without consent</li>
        <li>Uses rate limiting to avoid network disruption</li>
        <li>Provides opt-out mechanism (see below)</li>
    </ul>

    <div class="contact">
        <h2>Contact Information</h2>
        <p><strong>Institution:</strong> Trinity College Dublin (TCD)</p>
        <p><strong>Researcher:</strong> Student Project</p>
        <p><strong>Email:</strong> <a href="mailto:$EMAIL">$EMAIL</a></p>
        <p><strong>Website:</strong> <code>https://$DOMAIN</code></p>
        <p><strong>Scanning IP:</strong> <code>$CURRENT_IPV4</code></p>
        <p>If you would like to opt-out of this survey or have questions, please contact us.</p>
    </div>

    <h2>Opt-Out Instructions</h2>
    <p>If you would like your IP address excluded from this research, please email us at
    <a href="mailto:$EMAIL">$EMAIL</a> with:</p>
    <ul>
        <li>Your IP address or IP range to exclude</li>
        <li>Your organization name (optional)</li>
        <li>Reason for exclusion (optional)</li>
    </ul>
    <p>We will add your IP to our exclusion list within 48 hours and confirm via email.</p>

    <h2>Technical Details</h2>
    <p>Scan characteristics:</p>
    <ul>
        <li><strong>Scanner:</strong> ZMap (network scanner) + ZGrab (banner grabber)</li>
        <li><strong>Rate:</strong> ~147 packets per second</li>
        <li><strong>Duration:</strong> Scans may take 24-48 hours to complete</li>
        <li><strong>Frequency:</strong> Scans are not continuous; run periodically for research</li>
    </ul>

    <hr>
    <p><small>Last Updated: $(date +"%B %d, %Y at %H:%M UTC")</small></p>
    <p><small>Scanning Host IPv4: $CURRENT_IPV4</small></p>
    <p><small>Scanning Host IPv6: $CURRENT_IPV6</small></p>
</body>
</html>
EOF

# Create index.html
sudo tee /var/www/html/index.html > /dev/null << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TCD Student Research</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 100px auto;
            padding: 20px;
            text-align: center;
        }
        h1 { color: #003366; }
        .subtitle { color: #666; margin: 20px 0; }
        a {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background: #003366;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        a:hover { background: #0055aa; }
    </style>
</head>
<body>
    <h1>TCD Student Research</h1>
    <p class="subtitle">Trinity College Dublin - Computer Science</p>
    <p>This site hosts information about academic research being conducted by TCD students.</p>
    <a href="/about-scan.html">About Our Cryptographic Key Survey</a>
</body>
</html>
EOF

echo "✓ Disclosure pages created"

echo ""
echo "============================================================"
echo "Step 3: Starting nginx"
echo "============================================================"
sudo systemctl enable nginx
sudo systemctl restart nginx
echo "✓ Nginx running"

echo ""
echo "============================================================"
echo "Step 4: Checking DNS"
echo "============================================================"
DNS_IP=$(dig +short $DOMAIN A | head -1)

echo "Your server IPv4: $CURRENT_IPV4"
echo "DNS A record:     $DNS_IP"

if [ "$DNS_IP" == "$CURRENT_IPV4" ]; then
    echo "✓ DNS is correct!"
    echo ""
    echo "============================================================"
    echo "Step 5: Setting up HTTPS with Let's Encrypt"
    echo "============================================================"

    read -p "Set up HTTPS now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Installing Certbot..."
        sudo apt-get install -y certbot python3-certbot-nginx

        echo ""
        echo "Obtaining SSL certificate..."
        sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN \
            --non-interactive \
            --agree-tos \
            --email $EMAIL \
            --redirect || {
            echo "⚠️  HTTPS setup failed. You can try again later with:"
            echo "    sudo certbot --nginx -d $DOMAIN"
        }

        echo ""
        echo "Testing auto-renewal..."
        sudo certbot renew --dry-run || echo "⚠️  Auto-renewal test failed (may be OK)"
    else
        echo "Skipping HTTPS setup. You can set it up later with:"
        echo "  sudo ./setup-https.sh"
    fi
else
    echo "⚠️  DNS is NOT pointing to this server yet"
    echo ""
    echo "You need to update DNS at Register 365 first:"
    echo "  1. Log in to https://www.register365.com/"
    echo "  2. Go to: My Domains → $DOMAIN → DNS Settings"
    echo "  3. Change A record from: $DNS_IP"
    echo "                       to: $CURRENT_IPV4"
    echo "  4. Add AAAA record:      $CURRENT_IPV6"
    echo "  5. Wait 1-2 hours for propagation"
    echo ""
    echo "Then run HTTPS setup:"
    echo "  sudo ./setup-https.sh"
    echo ""
fi

echo ""
echo "============================================================"
echo "✅ Setup Complete!"
echo "============================================================"
echo ""
echo "Your website is accessible at:"
echo "  http://$CURRENT_IPV4/about-scan.html"
if [ "$DNS_IP" == "$CURRENT_IPV4" ]; then
    echo "  http://$DOMAIN/about-scan.html"
    if [ -d /etc/letsencrypt/live/$DOMAIN ]; then
        echo "  https://$DOMAIN/about-scan.html (HTTPS enabled!)"
    fi
fi
echo ""
echo "Next steps:"
if [ "$DNS_IP" != "$CURRENT_IPV4" ]; then
    echo "  1. Update DNS at Register 365"
    echo "  2. Wait for DNS propagation (1-2 hours)"
    echo "  3. Run: sudo ./setup-https.sh"
fi
echo "  - Test port 25: ./test-port25.sh"
echo "  - Start scan: cd ~/data/smtp/runs && /root/code/surveys/skey-all.sh -c IE -mm -r ."
echo ""
echo "Documentation:"
echo "  - See QUICK_START_MALOMOT.md for detailed instructions"
echo "  - See HTTPS_SETUP_GUIDE.md for HTTPS information"
echo ""
