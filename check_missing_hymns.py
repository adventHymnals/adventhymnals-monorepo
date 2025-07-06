#!/usr/bin/env python3
"""
Script to systematically check for missing hymns in the HSAB hymnal extraction.
The user confirmed there should be 177 hymns total, but only 174 are currently extracted.
This script will identify the missing 3 hymns.
"""

import os
import json
import re
from pathlib import Path

def check_extracted_hymns():
    """Check which hymn numbers are currently extracted."""
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    extracted_numbers = set()
    
    for file_path in hymn_dir.glob("HSAB-en-*.json"):
        # Extract number from filename
        match = re.search(r'HSAB-en-(\d+)\.json', file_path.name)
        if match:
            number = int(match.group(1))
            extracted_numbers.add(number)
            
    return sorted(extracted_numbers)

def analyze_hymn_content():
    """Analyze the content of extracted hymns to understand the numbering pattern."""
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    hymn_data = {}
    
    for file_path in hymn_dir.glob("HSAB-en-*.json"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                hymn_data[data['number']] = {
                    'title': data['title'],
                    'id': data['id'],
                    'verses': len(data['verses'])
                }
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    return hymn_data

def find_missing_numbers(extracted_numbers, expected_total=177):
    """Find which hymn numbers are missing."""
    expected_numbers = set(range(1, expected_total + 1))
    extracted_set = set(extracted_numbers)
    
    missing = sorted(expected_numbers - extracted_set)
    
    return missing

def check_for_gaps_in_sequence(extracted_numbers):
    """Check for gaps in the sequence of extracted hymns."""
    gaps = []
    
    for i in range(len(extracted_numbers) - 1):
        current = extracted_numbers[i]
        next_num = extracted_numbers[i + 1]
        
        if next_num - current > 1:
            # There's a gap
            for missing_num in range(current + 1, next_num):
                gaps.append(missing_num)
    
    return gaps

def main():
    print("=" * 60)
    print("HSAB HYMNAL MISSING HYMNS ANALYSIS")
    print("=" * 60)
    
    # Check extracted hymns
    extracted_numbers = check_extracted_hymns()
    print(f"\nTotal extracted hymns: {len(extracted_numbers)}")
    print(f"Expected total: 177")
    print(f"Missing: {177 - len(extracted_numbers)}")
    
    # Find missing numbers
    missing = find_missing_numbers(extracted_numbers, 177)
    print(f"\nMissing hymn numbers: {missing}")
    
    # Check for gaps in sequence
    gaps = check_for_gaps_in_sequence(extracted_numbers)
    print(f"Gaps in sequence: {gaps}")
    
    # Analyze the range of extracted hymns
    print(f"\nExtracted hymn range: {min(extracted_numbers)} to {max(extracted_numbers)}")
    
    # Check if we have hymns beyond what we expect
    if max(extracted_numbers) > 177:
        print(f"WARNING: Found hymns numbered higher than expected maximum (177)")
        high_numbers = [n for n in extracted_numbers if n > 177]
        print(f"High numbers: {high_numbers}")
    
    # Analyze hymn content
    hymn_data = analyze_hymn_content()
    
    # Show some context around missing numbers
    print(f"\nContext around missing numbers:")
    for missing_num in missing:
        print(f"\nMissing hymn {missing_num}:")
        
        # Show hymn before
        if missing_num - 1 in hymn_data:
            print(f"  Before: {missing_num - 1}. {hymn_data[missing_num - 1]['title']}")
        
        # Show hymn after
        if missing_num + 1 in hymn_data:
            print(f"  After:  {missing_num + 1}. {hymn_data[missing_num + 1]['title']}")
    
    # Show the last few hymns to understand the end pattern
    print(f"\nLast 10 extracted hymns:")
    last_10 = sorted(extracted_numbers)[-10:]
    for num in last_10:
        if num in hymn_data:
            print(f"  {num}. {hymn_data[num]['title']}")
    
    # Check if there are any unnumbered or specially numbered hymns
    print(f"\nChecking for potential numbering issues...")
    
    # Look for duplicate numbers or other issues
    all_numbers = []
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    for file_path in hymn_dir.glob("HSAB-en-*.json"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                all_numbers.append(data['number'])
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    # Check for duplicates
    from collections import Counter
    number_counts = Counter(all_numbers)
    duplicates = {num: count for num, count in number_counts.items() if count > 1}
    
    if duplicates:
        print(f"WARNING: Found duplicate hymn numbers: {duplicates}")
    else:
        print("No duplicate hymn numbers found.")
    
    print(f"\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Total files: {len(extracted_numbers)}")
    print(f"Expected total: 177")
    print(f"Missing hymns: {missing}")
    print(f"Missing count: {len(missing)}")
    
    if len(missing) == 3:
        print("\nThis confirms we need to find exactly 3 missing hymns!")
    else:
        print(f"\nWARNING: Expected 3 missing hymns, but found {len(missing)}")

if __name__ == "__main__":
    main()