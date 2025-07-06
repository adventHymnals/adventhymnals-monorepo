#!/usr/bin/env python3
"""
Script to analyze the INDEX OF FIRST LINES TO SUPPLEMENTAL HYMNS
and find the missing hymns 175, 176, 177.
"""

import re
from pathlib import Path

def analyze_index_page():
    """Analyze the index page to understand the supplemental hymns structure."""
    
    # From the index page (173.png), I can see hymn numbers listed
    # Let me extract all the hymn numbers mentioned in the index
    
    index_entries = [
        ("A SOLDIER, Lord, thou hast me made", 3),
        ("Although I'm down in Egypt's land", 31),
        ("Almighty love inspire", 33),
        ("Asleep in Jesus! Blessed sleep", 37),
        ("Delightful day! First gift of heaven", 1),
        ("How happy is the man", 17),
        ("Hark! Hark! Hear the blest tidings", 18),
        ("Hear what the voice from heaven proclaims", 36),
        ("I'm a pilgrim, and I'm a stranger", 7),
        ("I'm glad I ever heard the cry", 11),
        ("I saw one weary, sad and torn", 13),
        ("I love to steal while away", 14),
        ("I am weary of staying, O fain would I rest", 15),
        ("It was not sleep I found my sight", 23),
        ("I'll try to prove faithful", 28),
        ("I love this pure religion", 30),
        ("In expectation sweet", 32),
        ("Jesus died on Calvary's mountain", 22),
        ("Long for my Saviour I've been waiting", 2),
        ("My Saviour's coming in the sky", 24),
        ("My soul is full of glory", 27),
        ("Our bondage, it will end, by and by, when He comes", 8),
        ("Oh, no, we cannot sing our songs", 12),
        ("O Brother be faithful", 19),
        ("O let thy sweet Spirit descend from above", 20),
        ("On the high cliffs of Jordan with pleasure I stand", 34),
        ("O the Lord has passed by, and he's given me a blessing", 35),
        ("Soldiers of Christ arise", 4),
        ("See, brethren, see, how the day rolls on", 29),
        ("Sleep, now, dear Brother, sweetly sleep", 38),
        ("There is a world to come", 5),
    ]
    
    # Continue with the rest from page 174
    index_entries_page2 = [
        ("This groaning earth is too dark and drear", 6),
        ("The old Israelites knew", 9),
        ("There is a holy City", 10),
        ("To-day the Saviour calls", 16),
        ("We're looking for a City", 21),
        ("Worthy, worthy is the Lamb", 26),
        ("Your harps ye mourning saints", 25),
    ]
    
    all_entries = index_entries + index_entries_page2
    
    # Extract all hymn numbers from the index
    hymn_numbers = [entry[1] for entry in all_entries]
    
    print("Hymn numbers found in the index:")
    print(sorted(set(hymn_numbers)))
    
    print(f"\nTotal unique hymn numbers in index: {len(set(hymn_numbers))}")
    print(f"Highest hymn number in index: {max(hymn_numbers)}")
    
    # The index shows hymns 1-38, but we need hymns 175, 176, 177
    # This suggests that the supplemental hymns might be numbered differently
    # or there might be additional hymns beyond what's shown in this index
    
    return all_entries

def main():
    print("=" * 60)
    print("ANALYZING SUPPLEMENTAL HYMNS INDEX")
    print("=" * 60)
    
    entries = analyze_index_page()
    
    print("\nAll index entries:")
    for title, number in sorted(entries, key=lambda x: x[1]):
        print(f"{number:2d}. {title}")
    
    print("\n" + "=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print("The index shows hymns 1-38, but we need to find hymns 175-177.")
    print("This suggests that:")
    print("1. There might be additional supplemental hymns not listed in this index")
    print("2. The hymns 175-177 might be in a different section")
    print("3. There might be a different numbering system for supplemental hymns")
    print("\nNext step: Check if there are additional pages or sections after the index.")

if __name__ == "__main__":
    main()