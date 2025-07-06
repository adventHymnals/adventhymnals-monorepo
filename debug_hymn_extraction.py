#!/usr/bin/env python3
"""
Debug script to understand how hymns were numbered in the extraction process.
"""

import json
from pathlib import Path

def analyze_actual_hymns():
    """Analyze the actual hymns that were extracted."""
    
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    hymns = {}
    
    for file_path in sorted(hymn_dir.glob("HSAB-en-*.json")):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                hymns[data['number']] = {
                    'title': data['title'],
                    'filename': file_path.name,
                    'verses': len(data['verses'])
                }
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    return hymns

def main():
    print("=" * 80)
    print("DEBUGGING HYMN EXTRACTION NUMBERING")
    print("=" * 80)
    
    hymns = analyze_actual_hymns()
    
    print(f"Total hymns extracted: {len(hymns)}")
    print(f"Hymn numbers range: {min(hymns.keys())} to {max(hymns.keys())}")
    
    # Show first 10 hymns
    print("\nFirst 10 hymns:")
    for i in range(1, 11):
        if i in hymns:
            print(f"{i:3d}. {hymns[i]['title']}")
    
    # Show last 10 hymns
    print("\nLast 10 hymns:")
    last_numbers = sorted(hymns.keys())[-10:]
    for num in last_numbers:
        print(f"{num:3d}. {hymns[num]['title']}")
    
    # Check if the actual hymns match the index
    print("\n" + "=" * 80)
    print("CHECKING AGAINST INDEX")
    print("=" * 80)
    
    # From the index, we know there should be 38 hymns total
    # Let's see what hymns 1-38 actually are
    
    print("\nHymns 1-38 (should match the index):")
    for i in range(1, 39):
        if i in hymns:
            print(f"{i:2d}. {hymns[i]['title']}")
        else:
            print(f"{i:2d}. *** MISSING ***")
    
    # Check what hymns are numbered above 38
    high_numbers = [num for num in hymns.keys() if num > 38]
    if high_numbers:
        print(f"\nHymns numbered above 38: {sorted(high_numbers)}")
        print("These might be incorrectly numbered or duplicated hymns.")
        
        print("\nHymns numbered 39+:")
        for num in sorted(high_numbers):
            print(f"{num:3d}. {hymns[num]['title']}")
    
    # Check the specific range around where we expect the missing hymns
    print("\n" + "=" * 80)
    print("CHECKING HYMNS 170-174 (end of extraction)")
    print("=" * 80)
    
    for i in range(170, 175):
        if i in hymns:
            print(f"{i}. {hymns[i]['title']}")
        else:
            print(f"{i}. *** MISSING ***")

if __name__ == "__main__":
    main()