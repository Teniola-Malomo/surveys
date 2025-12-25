#!/bin/bash
# Test Port 25 Connectivity
# This script tests if your server can make outbound connections on port 25

echo "=========================================="
echo "Port 25 Connectivity Test"
echo "=========================================="
echo ""
echo "Your IP address:"
curl -s ifconfig.me
echo ""
echo ""

echo "Test 1: Using netcat (nc)"
echo "-------------------------------------------"
echo "Attempting to connect to Gmail's mail server..."
if timeout 5 nc -zv gmail-smtp-in.l.google.com 25 2>&1 | grep -q succeeded; then
    echo "✓ SUCCESS: Port 25 is OPEN"
else
    echo "✗ FAILED: Port 25 appears BLOCKED"
fi
echo ""

echo "Test 2: Using telnet"
echo "-------------------------------------------"
echo "Sending QUIT command to test server..."
timeout 5 bash -c 'echo "QUIT" | telnet gmail-smtp-in.l.google.com 25 2>&1' | head -5
echo ""

echo "Test 3: Using bash TCP redirect"
echo "-------------------------------------------"
if timeout 3 bash -c 'cat < /dev/null > /dev/tcp/gmail-smtp-in.l.google.com/25 2>&1'; then
    echo "✓ TCP connection to port 25 successful"
else
    echo "✗ TCP connection to port 25 failed"
fi
echo ""

echo "Test 4: Multiple mail servers"
echo "-------------------------------------------"
for server in "gmail-smtp-in.l.google.com" "mx.google.com" "aspmx.l.google.com"; do
    echo -n "Testing $server ... "
    if timeout 3 nc -zv $server 25 2>&1 | grep -q succeeded; then
        echo "✓ OK"
    else
        echo "✗ FAILED"
    fi
done
echo ""

echo "Test 5: Check firewall rules"
echo "-------------------------------------------"
echo "Checking local iptables for port 25 blocks..."
if command -v iptables &> /dev/null; then
    sudo iptables -L OUTPUT -n -v | grep -E "dpt:25|smtp" || echo "No specific port 25 rules found"
else
    echo "iptables not available"
fi
echo ""

echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "If ALL tests show SUCCESS/OK:"
echo "  → Port 25 is OPEN and working"
echo "  → Your scans should work"
echo ""
echo "If ANY test shows FAILED/BLOCKED:"
echo "  → Port 25 is blocked"
echo "  → Contact your hosting provider (Hetzner)"
echo "  → Explain: Academic research requires port 25"
echo ""
echo "Your server: $(curl -s ifconfig.me)"
echo "Provider: Hetzner (based on IP range)"
echo ""
