#!/bin/bash

# Scanning Disclosure Web Server Setup
# For TCD Student Research - Cryptographic Key Survey
# Email: malomot@tcd.ie

set -e

echo "=========================================="
echo "TCD Student Research - Scan Disclosure Setup"
echo "=========================================="
echo ""

# Get current IP
IPV4=$(curl -s -4 ifconfig.me)
IPV6=$(curl -s -6 ifconfig.me 2>/dev/null || echo "Not available")

echo "Your scanning host IPs:"
echo "  IPv4: $IPV4"
echo "  IPv6: $IPV6"
echo ""
echo "Contact email: malomot@tcd.ie"
echo ""

echo "Installing nginx web server..."
sudo apt-get update -qq
sudo apt-get install -y nginx

echo ""
echo "Creating scan disclosure web pages..."

# Create about-scan.html
sudo tee /var/www/html/about-scan.html > /dev/null << EOF
<!DOCTYPE html>
<html>
<head>
    <title>TCD Student Research - Cryptographic Key Survey</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; line-height: 1.6; }
        h1 { color: #003366; }
        h2 { color: #0055aa; margin-top: 30px; }
        .contact { background: #f0f0f0; padding: 15px; border-left: 4px solid #003366; margin: 20px 0; }
        ul { margin: 10px 0; }
        li { margin: 8px 0; }
        a { color: #0055aa; }
    </style>
</head>
<body>
    <h1>TCD Student Research - Cryptographic Key Survey</h1>

    <p>This server ($IPV4) is conducting academic research
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
        <li><strong>Rate:</strong> Intentionally slow (~147 packets/sec) to minimize network impact</li>
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
        <p><strong>Scanning IP:</strong> $IPV4</p>
        <p>If you would like to opt-out of this survey or have questions, please contact us.</p>
    </div>

    <h2>Opt-Out</h2>
    <p>If you would like your IP address excluded from this research, please email us at
    <a href="mailto:malomot@tcd.ie">malomot@tcd.ie</a> with:</p>
    <ul>
        <li>Your IP address or IP range</li>
        <li>Your organization name (optional)</li>
    </ul>
    <p>We will add your IP to our exclusion list within 48 hours.</p>

    <hr>
    <p><small>Last Updated: $(date +"%B %d, %Y")</small></p>
    <p><small>Scanning Host: $IPV4</small></p>
</body>
</html>
EOF

# Create index.html
sudo tee /var/www/html/index.html > /dev/null << EOF
<!DOCTYPE html>
<html>
<head>
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
    <p>This site hosts information about academic research being conducted by Trinity College Dublin students.</p>
    <a href="/about-scan.html">About Our Cryptographic Key Survey</a>
</body>
</html>
EOF

# Enable and start nginx
echo ""
echo "Starting nginx web server..."
sudo systemctl enable nginx
sudo systemctl start nginx

echo ""
echo "===================================================="
echo "✅ Web server setup complete!"
echo "===================================================="
echo ""
echo "Test locally:"
echo "  curl http://localhost/about-scan.html"
echo "  curl http://$IPV4/about-scan.html"
echo ""
echo "===================================================="
echo "NEXT STEPS:"
echo "===================================================="
echo ""
echo "1. Update DNS at Register 365:"
echo "   Login: https://www.register365.com/"
echo ""
echo "   A Record:"
echo "   - Change from: 195.7.226.12"
echo "   - Change to:   $IPV4"
echo ""
echo "   AAAA Record (add new):"
echo "   - Type: AAAA"
echo "   - Value: $IPV6"
echo ""
echo "   TXT Record (add new):"
echo "   - Type: TXT"
echo "   - Value: \"TCD crypto key survey research. Contact: malomot@tcd.ie. More: http://tcd-student-research.ie/about-scan.html\""
echo ""
echo "2. Wait 1-2 hours for DNS propagation, then verify:"
echo "   dig +short tcd-student-research.ie A"
echo "   dig +short tcd-student-research.ie AAAA"
echo "   curl http://tcd-student-research.ie/about-scan.html"
echo ""
echo "3. Test the website now (using IP address):"
echo "   http://$IPV4/about-scan.html"
echo ""
echo "===================================================="
