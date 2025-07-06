#!/usr/bin/env python3
"""
Final analysis to determine the correct number of hymns and identify any missing ones.
"""

import json
from pathlib import Path

def compare_with_index():
    """Compare extracted hymns with the index to find discrepancies."""
    
    # Expected hymns from the index (pages 173-174)
    expected_hymns = [
        (1, "Delightful day! First gift of heaven"),
        (2, "Long for my Saviour I've been waiting"),
        (3, "A SOLDIER, Lord, thou hast me made"),
        (4, "Soldiers of Christ arise"),
        (5, "There is a world to come"),
        (6, "This groaning earth is too dark and drear"),
        (7, "I'm a pilgrim, and I'm a stranger"),
        (8, "Our bondage, it will end, by and by, when He comes"),
        (9, "The old Israelites knew"),
        (10, "There is a holy City"),
        (11, "I'm glad I ever heard the cry"),
        (12, "Oh, no, we cannot sing our songs"),
        (13, "I saw one weary, sad and torn"),
        (14, "I love to steal while away"),
        (15, "I am weary of staying, O fain would I rest"),
        (16, "To-day the Saviour calls"),
        (17, "How happy is the man"),
        (18, "Hark! Hark! Hear the blest tidings"),
        (19, "O Brother be faithful"),
        (20, "O let thy sweet Spirit descend from above"),
        (21, "We're looking for a City"),
        (22, "Jesus died on Calvary's mountain"),
        (23, "It was not sleep I found my sight"),
        (24, "My Saviour's coming in the sky"),
        (25, "Your harps ye mourning saints"),
        (26, "Worthy, worthy is the Lamb"),
        (27, "My soul is full of glory"),
        (28, "I'll try to prove faithful"),
        (29, "See, brethren, see, how the day rolls on"),
        (30, "I love this pure religion"),
        (31, "Although I'm down in Egypt's land"),
        (32, "In expectation sweet"),
        (33, "Almighty love inspire"),
        (34, "On the high cliffs of Jordan with pleasure I stand"),
        (35, "O the Lord has passed by, and he's given me a blessing"),
        (36, "Hear what the voice from heaven proclaims"),
        (37, "Asleep in Jesus! Blessed sleep"),
        (38, "Sleep, now, dear Brother, sweetly sleep"),
    ]
    
    # Load extracted hymns
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    extracted_hymns = {}
    
    for file_path in sorted(hymn_dir.glob("HSAB-en-*.json")):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                extracted_hymns[data['number']] = data['title']
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    print("=" * 80)
    print("COMPARISON WITH INDEX")
    print("=" * 80)
    
    matches = 0
    discrepancies = []
    
    for expected_num, expected_title in expected_hymns:
        if expected_num in extracted_hymns:
            extracted_title = extracted_hymns[expected_num]
            if expected_title.lower() in extracted_title.lower() or extracted_title.lower() in expected_title.lower():
                matches += 1
                print(f"✓ {expected_num:2d}. MATCH: {expected_title}")
            else:
                discrepancies.append((expected_num, expected_title, extracted_title))
                print(f"✗ {expected_num:2d}. MISMATCH:")
                print(f"     Expected: {expected_title}")
                print(f"     Extracted: {extracted_title}")
        else:
            discrepancies.append((expected_num, expected_title, "MISSING"))
            print(f"✗ {expected_num:2d}. MISSING: {expected_title}")
    
    print(f"\nSummary: {matches} matches out of {len(expected_hymns)} expected hymns")
    
    return discrepancies

def analyze_extraction_pattern():
    """Analyze how the extraction process numbered the hymns."""
    
    print("\n" + "=" * 80)
    print("EXTRACTION PATTERN ANALYSIS")
    print("=" * 80)
    
    # The issue seems to be that the extraction process:
    # 1. Correctly extracted the 38 main hymns (1-38)
    # 2. Then continued extracting and numbering additional content as hymns 39-153
    # 3. But the user expected 177 hymns total
    
    print("Current situation:")
    print("- Index shows 38 hymns should exist")
    print("- Extraction found 153 hymns (1-153)")
    print("- User expects 177 hymns total")
    print("- Missing: hymns 154-177 (24 hymns)")
    
    print("\nPossible explanations:")
    print("1. The extraction process incorrectly numbered content that isn't hymns")
    print("2. There are additional hymns beyond the 38 listed in the index")
    print("3. The user's expectation of 177 hymns is incorrect")
    print("4. There are multiple sections or volumes being combined")

def main():
    discrepancies = compare_with_index()
    analyze_extraction_pattern()
    
    print("\n" + "=" * 80)
    print("RECOMMENDATION")
    print("=" * 80)
    
    if len(discrepancies) == 0:
        print("All hymns match the index perfectly.")
        print("The hymnal contains exactly 38 hymns as listed in the index.")
        print("The expectation of 177 hymns appears to be incorrect.")
    else:
        print(f"Found {len(discrepancies)} discrepancies that need investigation.")
        
    print("\nNext steps:")
    print("1. Verify with the user if 177 hymns is the correct expectation")
    print("2. Check if there are additional volumes or sections")
    print("3. Review the extraction process for hymns 39-153")
    print("4. Determine if content beyond hymn 38 should be considered hymns")

if __name__ == "__main__":
    main()