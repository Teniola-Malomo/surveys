#!/usr/bin/env python3
"""
Verify MaxMind IP data for a country code

This script shows:
- How many prefixes MaxMind has for a country
- Total IP addresses across all prefixes
- Breakdown by prefix size
- Comparison with expected values
"""

import ipaddress
import argparse
import sys
from collections import Counter

def verify_maxmind_data(mmdb_file, country_code):
    """
    Verify MaxMind data for a country
    """
    total_ips = 0
    prefix_count = 0
    prefix_sizes = Counter()
    prefixes = []

    try:
        with open(mmdb_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        network = ipaddress.ip_network(line, strict=False)
                        num_ips = network.num_addresses
                        total_ips += num_ips
                        prefix_count += 1
                        prefix_sizes[network.prefixlen] += 1
                        prefixes.append((line, num_ips))
                    except Exception as e:
                        print(f"Warning: Error parsing {line}: {e}", file=sys.stderr)
    except FileNotFoundError:
        print(f"Error: File not found: {mmdb_file}", file=sys.stderr)
        return None

    return {
        'total_ips': total_ips,
        'prefix_count': prefix_count,
        'prefix_sizes': prefix_sizes,
        'prefixes': prefixes
    }

def main():
    parser = argparse.ArgumentParser(description='Verify MaxMind IP data')
    parser.add_argument('-f', '--file', required=True, help='MaxMind IP file (e.g., mm-ips.IE.v4)')
    parser.add_argument('-c', '--country', default='??', help='Country code for display')
    parser.add_argument('-e', '--expected', type=int, help='Expected number of IPs or prefixes')
    parser.add_argument('--show-top', type=int, default=10, help='Show top N largest prefixes')

    args = parser.parse_args()

    print(f"Verifying MaxMind data for: {args.country}")
    print(f"File: {args.file}")
    print("=" * 70)
    print()

    data = verify_maxmind_data(args.file, args.country)

    if data is None:
        return 1

    print(f"Total prefixes:      {data['prefix_count']:,}")
    print(f"Total IP addresses:  {data['total_ips']:,}")
    print()

    if args.expected:
        print(f"Expected value:      {args.expected:,}")
        if args.expected < 10000:
            # Probably expecting prefix count
            diff = data['prefix_count'] - args.expected
            print(f"Difference (prefixes): {diff:+,}")
        else:
            # Probably expecting IP count
            diff = data['total_ips'] - args.expected
            print(f"Difference (IPs):      {diff:+,}")
        print()

    print("Prefix size distribution:")
    print(f"{'Prefix':>10s} {'Count':>8s} {'IPs per prefix':>18s} {'Total IPs':>18s}")
    print("-" * 70)

    for prefix_len in sorted(data['prefix_sizes'].keys()):
        count = data['prefix_sizes'][prefix_len]
        ips_per_prefix = 2 ** (32 - prefix_len)
        total_for_size = ips_per_prefix * count
        print(f"/{prefix_len:<8d} {count:>8,d} {ips_per_prefix:>18,d} {total_for_size:>18,d}")

    print()
    print(f"Top {args.show_top} largest prefixes:")
    print(f"{'Prefix':>20s} {'IP Count':>15s}")
    print("-" * 40)

    # Sort by IP count, descending
    sorted_prefixes = sorted(data['prefixes'], key=lambda x: x[1], reverse=True)
    for prefix, count in sorted_prefixes[:args.show_top]:
        print(f"{prefix:>20s} {count:>15,d}")

    print()
    print("=" * 70)
    print("Summary:")
    print(f"  - MaxMind has {data['prefix_count']:,} prefixes for {args.country}")
    print(f"  - This represents {data['total_ips']:,} total IP addresses")
    print(f"  - ZMap will scan all {data['total_ips']:,} IPs looking for port 25")
    print(f"  - The number of RESPONSIVE servers will be much lower")
    print()

    return 0

if __name__ == '__main__':
    sys.exit(main())
