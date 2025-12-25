# SMTP Cryptographic Key Survey - Scan Analysis Guide

## Overview

This is a cryptographic key reuse survey project that scans mail servers to identify cases where SSH and TLS keys are being reused across different hosts and protocols. The project was created by Stephen Farrell and published in [this research paper](https://eprint.iacr.org/2018/299).

## Your Scan: IE-20251116-125800

### What Was Scanned

**Target:** Ireland (IE)
**Scan Date:** November 16-17, 2025
**Duration:** ~1 day, 10 hours
**Target Addresses:** ~18.4 million IP addresses
**Ports Scanned:** 22 (SSH), 25 (SMTP), 110 (POP3), 143 (IMAP), 443 (HTTPS), 587 (SMTP), 993 (IMAPS)

### Scan Results Summary

**IMPORTANT FINDING: Zero responsive hosts detected**

```
Total IPs scanned:     18,403,316
Port 25 responses:     0
Hit rate:              0.00%
Clusters found:        0
Key collisions:        0
```

### Why Zero Results?

The scan found no SMTP servers (port 25) responding in Ireland. This could be due to:

1. **Network restrictions:** Your scanning host may not be able to make outbound connections on port 25
   - Many ISPs and cloud providers block outbound port 25 to prevent spam
   - Test with: `telnet <known-mail-server> 25`

2. **Firewall/routing issues:** Traffic may be filtered before reaching targets

3. **MaxMind data:** The IP prefixes from MaxMind may not accurately reflect current Irish mail servers

4. **Actual scarcity:** There may genuinely be few open port 25 servers in the scanned ranges

### Scan Workflow

The scan went through these stages:

1. **MaxMind IP extraction** (IPsFromMM.py)
   - Extracted 5,153 IPv4 prefixes for Ireland
   - Extracted 4,139 IPv6 prefixes (not currently used)
   - Generated: `mm-ips.IE.v4`, `mm-ips.IE.v6`

2. **ZMap port scanning** (zmap)
   - Scanned all IPs in the prefixes for port 25 listeners
   - Duration: 1d 10h 33m
   - Result: `zmap.ips` (empty - 0 hosts found)

3. **Banner/Key collection** (FreshGrab.py) - SKIPPED
   - Would collect SSH and TLS keys from responsive hosts
   - Would generate: `records.fresh` (one JSON blob per host)

4. **Cluster analysis** (SameKeys.py) - NO DATA
   - Would identify hosts sharing cryptographic keys
   - Would generate: `collisions.json`, `fingerprints.json`

5. **Graph generation** (ReportReuse.py) - NO DATA
   - Would create visualization of key-sharing clusters
   - Would generate: `cluster*.json`, `graph*.dot` files

## File Structure

```
data/smtp/runs/IE-20251116-125800/
├── 20251116-125800.out          # 16MB log file from entire scan
├── Makefile                     # Controls individual scan stages
├── mm-ips.IE.v4                 # 5,153 IPv4 prefixes from MaxMind
├── mm-ips.IE.v6                 # 4,139 IPv6 prefixes from MaxMind
├── zmap.ips                     # Empty (no responsive hosts found)
├── input.ips -> zmap.ips        # Symlink to IPs for next stage
├── records.fresh                # Empty (no data to collect)
├── collisions.json              # Empty (no clusters found)
├── fingerprints.json            # Empty
├── all-key-fingerprints.json    # Empty
├── dodgy.json                   # Empty
├── clustersizes.csv             # Shows 0 clusters
├── summary.txt                  # Summary: 0 collisions, 0 clusters
└── graph.done                   # Marker file indicating completion
```

## Installed Dependencies

The following packages are already installed on your system:

### System Packages
- `zmap` - Fast network scanner
- `zgrab` - Banner grabbing tool
- `graphviz` - Graph visualization (sfdp/neato)
- `perforate` - Contains finddup utility

### Python 3.12.3 Packages
- `geoip2` (2.9.0) - MaxMind GeoIP database
- `maxminddb` (2.5.2) - MaxMind DB reader
- `pytz` (2024.1) - Timezone handling
- `networkx` (2.8.8) - Graph analysis
- `matplotlib` (3.6.3) - Plotting
- `graphviz` - Graph generation
- `dateutil` - Date parsing
- `jsonpickle` - JSON serialization
- `netaddr` - Network address manipulation
- `cryptography` - Cryptographic operations
- `wordcloud` - Word cloud generation
- `plotly` - Interactive plotting
- `scipy` - Scientific computing

All dependencies are satisfied.

## What You Can Do With This Data

### 1. Analyze the Scan Log

```bash
# View the full scan progression
less data/smtp/runs/IE-20251116-125800/20251116-125800.out

# Check MaxMind IP extraction statistics
grep "matching" data/smtp/runs/IE-20251116-125800/20251116-125800.out | tail -20

# See final scan statistics
tail -50 data/smtp/runs/IE-20251116-125800/20251116-125800.out
```

### 2. Examine the IP Prefixes

```bash
# See what IP ranges were scanned
head -50 data/smtp/runs/IE-20251116-125800/mm-ips.IE.v4

# Count total prefixes
wc -l data/smtp/runs/IE-20251116-125800/mm-ips.IE.*
```

### 3. Troubleshoot Network Connectivity

```bash
# Test if you can connect to a known mail server
telnet gmail-smtp-in.l.google.com 25

# Check if port 25 is blocked outbound
sudo iptables -L OUTPUT -v -n | grep 25

# Try scanning a single known mail server
echo "64.233.160.26" > /tmp/test.ips
cd data/smtp/runs/IE-20251116-125800
/root/code/surveys/FreshGrab.py -i /tmp/test.ips -o /tmp/test.out -c US -d /root/code/surveys/mmdb
```

### 4. Re-run Analysis Stages Manually

If you get data from another source, you can use the Makefile:

```bash
cd data/smtp/runs/IE-20251116-125800

# Analyze clusters (if you had records.fresh data)
make clusters cname="IE"

# Generate graphs (if you had collision data)
make graphs

# Render SVG images from dot files
make images

# Generate word clouds from cluster names
make words
```

## Example: What Success Looks Like

If the scan HAD found responsive hosts, you would see:

### records.fresh
Large JSON file with one entry per IP:
```json
{
  "ip": "1.2.3.4",
  "p22": { /* SSH banner and key fingerprint */ },
  "p25": { /* SMTP banner */ },
  "p443": { /* HTTPS certificate and details */ },
  ...
}
```

### collisions.json
Hosts that share keys:
```json
[
  {
    "ip": "1.2.3.4",
    "asn": 12345,
    "fps": ["sha256:abc123...", "sha256:def456..."],
    "linked": ["1.2.3.5", "1.2.3.6"],
    ...
  }
]
```

### Cluster Files
Individual files like `cluster1.json`, `cluster2.json` containing all hosts in each cluster.

### Graph Files
Graphviz `.dot` files showing relationships, which can be rendered to SVG:

```
graph1.dot -> graph1.dot.svg
```

## Next Steps

### Option 1: Debug Network Connectivity
1. Test outbound port 25 connectivity
2. Check firewall rules
3. Try scanning from a different host/network

### Option 2: Run a Test Scan
Try scanning a smaller, known-good target:

```bash
cd ~/data/smtp/runs
# Create a test file with a known mail server IP
echo "64.233.160.26" > test-ips.txt

# Run just the FreshGrab stage
/root/code/surveys/FreshGrab.py -i test-ips.txt -o test-records.json -c US -d /root/code/surveys/mmdb
```

### Option 3: Analyze Existing Data
If you have `records.fresh` data from another source:

```bash
cd data/smtp/runs/IE-20251116-125800
# Copy your data to records.fresh
# Then run analysis
make clusters cname="IE"
make graphs
make images
```

### Option 4: Try a Different Country
Some countries may have more accessible mail servers:

```bash
cd ~/data/smtp/runs
nohup /root/code/surveys/skey-all.sh -c US -mm -r . >us-scan.out 2>&1 &
```

## Understanding the Research

This project identifies:
- **Key reuse within hosts:** Same key used for SSH and TLS on one host
- **Key reuse across hosts:** Multiple hosts sharing the same cryptographic key
- **Cross-protocol reuse:** SSH host keys used as TLS keys (security issue)

The clusters help identify:
- Misconfigured server deployments
- Virtual hosting setups
- Load balancer configurations
- Potential security vulnerabilities

## Additional Resources

- **Research Paper:** https://eprint.iacr.org/2018/299
- **Sample Graphs:** https://down.dsg.cs.tcd.ie/runs/
- **Presentation:** https://down.dsg.cs.tcd.ie/misc/hark.pdf
- **Repository:** https://github.com/sftcd/surveys

## Scripts Reference

### Main Scripts
- `skey-all.sh` - Orchestrates the full scan workflow
- `IPsFromMM.py` - Extracts IP prefixes from MaxMind database
- `FreshGrab.py` - Collects banners and keys from hosts
- `SameKeys.py` - Identifies key collisions and creates clusters
- `ReportReuse.py` - Generates graphs and cluster reports

### Analysis Tools (clustertools/)
- `ClusterStats.py` - Generate statistics tables
- `ClusterGetCerts.py` - Re-fetch certificates from cluster hosts
- `ClusterPortBT.py` - Check browser trust status
- `wordle.sh` - Generate word clouds from hostnames
- `clips.sh` - Extract IPs from a cluster
- `biggest22.sh` - Find largest SSH key clusters

## Warnings

1. **Scanning Ethics:** Only scan networks you have permission to scan
2. **Network Impact:** The scan rate is intentionally slow to be polite
3. **Legal:** Some jurisdictions have laws about network scanning
4. **Sudo Required:** ZMap requires root permissions
5. **Disk Space:** Full scans can generate GB of data

---

**Scan Status:** Complete (0 results found - likely due to port 25 blocking)
**Next Action:** Troubleshoot network connectivity or try a different scanning host
