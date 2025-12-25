#!/bin/bash

# Setup HTTPS for tcd-student-research.ie
# Uses Let's Encrypt (free SSL certificates)

set -e

echo "=========================================="
echo "HTTPS Setup with Let's Encrypt"
echo "=========================================="
echo ""

DOMAIN="tcd-student-research.ie"
EMAIL="malomot@tcd.ie"

echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Check if DNS is pointing to this server
echo "Step 1: Checking DNS..."
CURRENT_IP=$(curl -s -4 ifconfig.me)
DNS_IP=$(dig +short $DOMAIN A | head -1)

echo "Your server IP: $CURRENT_IP"
echo "DNS points to:  $DNS_IP"
echo ""

if [ "$DNS_IP" != "$CURRENT_IP" ]; then
    echo "⚠️  WARNING: DNS is not pointing to this server yet!"
    echo ""
    echo "Current DNS: $DNS_IP"
    echo "Should be:   $CURRENT_IP"
    echo ""
    echo "You MUST update DNS at Register 365 first:"
    echo "  Change A record from $DNS_IP to $CURRENT_IP"
    echo ""
    echo "Then wait 1-2 hours for DNS propagation."
    echo ""
    read -p "Do you want to continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting. Update DNS first, then run this script again."
        exit 1
    fi
fi

echo "Step 2: Installing Certbot (Let's Encrypt client)..."
sudo apt-get update -qq
sudo apt-get install -y certbot python3-certbot-nginx

echo ""
echo "Step 3: Obtaining SSL certificate from Let's Encrypt..."
echo ""
echo "This will:"
echo "  - Verify you own $DOMAIN"
echo "  - Issue a free SSL certificate"
echo "  - Configure nginx to use HTTPS"
echo "  - Set up automatic renewal"
echo ""

# Run certbot
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --redirect

echo ""
echo "Step 4: Testing automatic renewal..."
sudo certbot renew --dry-run

echo ""
echo "=========================================="
echo "✅ HTTPS Setup Complete!"
echo "=========================================="
echo ""
echo "Your website is now available at:"
echo "  https://$DOMAIN"
echo "  https://$DOMAIN/about-scan.html"
echo ""
echo "HTTP is automatically redirected to HTTPS"
echo ""
echo "Certificate details:"
sudo certbot certificates
echo ""
echo "Certificate will auto-renew every 90 days"
echo ""
echo "Test your SSL configuration:"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo ""
