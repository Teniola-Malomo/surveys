# Re-running the Ireland Scan - Complete Guide

## Understanding "700" vs "18 Million"

**MaxMind Data:**
- **5,153 prefixes** (network ranges)
- **18,403,316 total IP addresses** in those prefixes

**What your professor meant by "700":**
- Approximately **700 RESPONSIVE mail servers** expected
- NOT the total IPs scanned
- This is the hit rate: 700 / 18,403,316 = **0.0038%**

**Your scan results:**
- IPs scanned: **18,403,316** ✅ (correct)
- Port 25 responses: **0** ❌ (unexpected)
- Expected responses: **~700**

## Why You Got 0 Responses

Since we confirmed port 25 IS NOT blocked, other possibilities:

1. **Timing/Network issues** - Temporary connectivity problems during scan
2. **AWS/Cloud IPs** - Many prefixes are AWS (34.240.0.0/12, 52.208.0.0/13) which may not respond to external port 25 scans
3. **Modern filtering** - Mail servers heavily filter inbound connections
4. **MaxMind accuracy** - Data may include non-Irish IPs or dormant ranges

## Verifying MaxMind Data

Run this script anytime:

```bash
cd /root/surveys

# Check IE data
./verify-maxmind-data.py -f data/smtp/runs/IE-20251116-125800/mm-ips.IE.v4 -c IE -e 700

# Or re-extract from MaxMind to verify
./IPsFromMM.py -c IE -o /tmp/test-mm-ips.IE --nov6 -i mmdb
wc -l /tmp/test-mm-ips.IE.v4
```

### What the Numbers Mean

```
Total prefixes:      5,153   ← Network ranges
Total IP addresses:  18,403,316   ← Individual IPs to scan
Expected responses:  ~700   ← Servers that will respond on port 25
```

## Re-running the Scan

### Option 1: Clean Full Re-run

Start completely fresh with a new run:

```bash
cd ~/data/smtp/runs

# Run scan with logging
nohup /root/code/surveys/skey-all.sh -c IE -mm -r . >ie-rescan-$(date +%Y%m%d).out 2>&1 &

# Watch progress
tail -f ie-rescan-*.out

# Or monitor in another way
watch -n 60 'tail -20 ie-rescan-*.out'
```

### Option 2: Resume From Current Directory

If you want to try again using the existing IP list:

```bash
cd /root/data/smtp/runs/IE-20251116-125800

# Remove old zmap results
rm -f zmap.ips input.ips records.fresh

# Re-run just the zmap stage with the existing mm-ips files
sudo zmap -p 25 -o zmap.ips -w mm-ips.IE.v4 -r 147

# Watch for results
watch -n 10 'echo "Lines in zmap.ips: $(wc -l < zmap.ips)"'

# Once you have some IPs, continue with the rest
ln -s zmap.ips input.ips
/root/code/surveys/skey-all.sh -c IE -p . -r .
```

### Option 3: Test Scan First

Try a small test to verify everything works:

```bash
# Create a test list with known responsive mail servers
cat > /tmp/test-mail-servers.txt << 'EOF'
142.250.27.26
209.85.220.26
108.177.15.26
EOF

# Test FreshGrab
cd /root/surveys
./FreshGrab.py -i /tmp/test-mail-servers.txt -o /tmp/test-output.json -c US -d mmdb

# Check if you got results
cat /tmp/test-output.json | python3 -m json.tool | head -100

# If that works, your port 25 is definitely working!
```

## Monitoring the Scan

### Watch ZMap Progress

```bash
# From the scan directory
cd /root/data/smtp/runs/IE-YYYYMMDD-HHMMSS
tail -f *.out
```

You'll see output like:
```
 4:33 3% (2h44m left); send: 38600 148 p/s (140 p/s avg); recv: 169 2 p/s (0 p/s avg); hitrate: 0.44%
```

Key metrics:
- `send: 38600` - IPs scanned so far
- `recv: 169` - Responses received (this is what you want > 0!)
- `hitrate: 0.44%` - Percentage responding
- `2h44m left` - Estimated time remaining

### Check for Responses

```bash
# While scan is running, check if any hosts found
wc -l zmap.ips
cat zmap.ips | head -20

# If you see IPs appearing, success!
```

## Expected Timeline

Based on your previous scan:

- **ZMap scan:** ~34 hours (1 day, 10 hours)
- **FreshGrab:** 7-10 hours (for ~700 hosts × 7 ports)
- **Clustering:** 1-2 hours
- **Graphing:** 5-10 minutes
- **Total:** ~2 days

## Success Criteria

After the scan completes, check these files:

```bash
cd /root/data/smtp/runs/IE-YYYYMMDD-HHMMSS

# Should have responsive hosts
wc -l zmap.ips
# Expected: ~700 lines

# Should have collected records
wc -l records.fresh
# Expected: ~700 lines (one JSON object per line)

# Should have found some clusters
cat summary.txt
# Expected: "collisions: XXX" where XXX > 0

# Check cluster files
ls -lh cluster*.json
ls -lh graph*.dot
```

## If You Still Get 0 Results

### Verify Port 25 Connectivity Again

```bash
# Test a few known mail servers manually
for ip in 142.250.27.26 209.85.220.26 108.177.15.26; do
    echo "Testing $ip..."
    timeout 5 bash -c "echo 'QUIT' | nc $ip 25" 2>&1 | head -3
done
```

### Try a Different Country

Some countries may have better response rates:

```bash
# United States (likely more responsive)
cd ~/data/smtp/runs
nohup /root/code/surveys/skey-all.sh -c US -mm -r . >us-scan.out 2>&1 &

# Netherlands
nohup /root/code/surveys/skey-all.sh -c NL -mm -r . >nl-scan.out 2>&1 &

# Germany
nohup /root/code/surveys/skey-all.sh -c DE -mm -r . >de-scan.out 2>&1 &
```

### Check ZMap Directly

Test ZMap in isolation:

```bash
# Create a small test range
echo "8.8.8.0/24" > /tmp/test-range.txt

# Scan just this range
sudo zmap -p 25 -o /tmp/test-results.txt -w /tmp/test-range.txt -r 100

# Check results
cat /tmp/test-results.txt
```

## Recommended Approach

I recommend this sequence:

1. **First, run the test scan** (Option 3 above) to confirm port 25 works
2. **If successful, start a full IE re-scan** (Option 1)
3. **Monitor closely** for the first hour to see if you get ANY responses
4. **If still 0 responses after 1 hour**, kill it and try a different country
5. **Report findings** to your professor

## Quick Reference Commands

```bash
# Re-extract MaxMind data for IE
cd /root/surveys
./IPsFromMM.py -c IE -o /tmp/verify-ie --nov6 -i mmdb
./verify-maxmind-data.py -f /tmp/verify-ie.v4 -c IE

# Start new scan
cd ~/data/smtp/runs
nohup /root/code/surveys/skey-all.sh -c IE -mm -r . >ie-scan-$(date +%Y%m%d).out 2>&1 &

# Monitor
tail -f ~/data/smtp/runs/ie-scan-*.out

# Check for results (while running)
ls -lh ~/data/smtp/runs/IE-*/zmap.ips
wc -l ~/data/smtp/runs/IE-*/zmap.ips

# Stop a running scan
pkill -f skey-all.sh
sudo pkill zmap
```

## Contact Your Hosting Provider

Since your previous scan found 0 hosts, you may want to:

1. **Confirm with Hetzner** that outbound port 25 is truly unrestricted
2. **Ask about rate limiting** - they may throttle scans
3. **Notify them** about your academic research to avoid account issues

## Questions for Your Professor

Before re-running, consider asking:

1. Is 700 the expected number of **responsive hosts** or something else?
2. Should I try a different country if IE continues to return 0?
3. What hit rate (%) should I expect for modern scans?
4. Is there a specific date range when the original data was collected?

---

**Bottom Line:**
- MaxMind data is correct: **18.4M IPs in 5,153 prefixes** ✅
- Your professor's 700 likely means **~700 expected responsive servers** ✅
- Your scan of 18.4M IPs finding 0 servers is unexpected ⚠️
- Port 25 is confirmed working ✅
- Ready to re-run the scan 🚀

**Next action:** Run the test scan (Option 3) to verify connectivity, then launch a full re-scan.
