#!/usr/bin/env python3
"""
Script to find the missing hymns 175, 176, 177 based on the user's confirmation
that there should be 177 hymns total.
"""

import json
from pathlib import Path

def get_current_extraction_status():
    """Get the current status of hymn extraction."""
    
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    # Count actual files
    files = list(hymn_dir.glob("HSAB-en-*.json"))
    print(f"Total JSON files: {len(files)}")
    
    # Get the numbers from filenames
    numbers_from_filenames = []
    for file_path in files:
        try:
            # Extract number from filename like HSAB-en-001.json
            number_str = file_path.stem.split('-')[-1]  # Gets the last part after splitting by '-'
            number = int(number_str)
            numbers_from_filenames.append(number)
        except:
            print(f"Could not extract number from {file_path.name}")
    
    numbers_from_filenames.sort()
    
    print(f"Numbers from filenames: {min(numbers_from_filenames)} to {max(numbers_from_filenames)}")
    print(f"Total numbers: {len(numbers_from_filenames)}")
    
    # Check for missing numbers in the sequence
    missing_in_sequence = []
    for i in range(1, max(numbers_from_filenames) + 1):
        if i not in numbers_from_filenames:
            missing_in_sequence.append(i)
    
    print(f"Missing numbers in sequence 1-{max(numbers_from_filenames)}: {missing_in_sequence}")
    
    # If we need 177 total, what's missing?
    if max(numbers_from_filenames) < 177:
        needed_numbers = list(range(max(numbers_from_filenames) + 1, 178))
        print(f"Numbers needed to reach 177: {needed_numbers}")
        
        # These are the missing hymns we need to find
        return needed_numbers
    else:
        return []

def analyze_extraction_issue():
    """Analyze why we have fewer hymns than expected."""
    
    print("\n" + "=" * 80)
    print("EXTRACTION ANALYSIS")
    print("=" * 80)
    
    # The issue is likely that:
    # 1. The original extraction process created files HSAB-en-001.json through HSAB-en-174.json
    # 2. But hymns 175, 176, 177 were never created
    # 3. This suggests that the content for these hymns exists but wasn't processed
    
    print("Current situation:")
    print("- Files exist: HSAB-en-001.json through HSAB-en-174.json")
    print("- Missing files: HSAB-en-175.json, HSAB-en-176.json, HSAB-en-177.json")
    print("- Total hymns expected: 177")
    print("- Total hymns found: 174")
    print("- Missing hymns: 3")
    
    print("\nPossible reasons for missing hymns:")
    print("1. The source images contain hymns that weren't processed")
    print("2. The extraction stopped at 174 for some reason")
    print("3. The hymns 175-177 are in a different format or location")
    print("4. The hymns 175-177 are supplemental hymns not in the main sequence")

def create_missing_hymns_template():
    """Create template files for the missing hymns."""
    
    print("\n" + "=" * 80)
    print("CREATING TEMPLATES FOR MISSING HYMNS")
    print("=" * 80)
    
    # Based on the established schema, create templates for hymns 175, 176, 177
    template = {
        "id": "",
        "number": 0,
        "title": "[TITLE TO BE EXTRACTED]",
        "language": "en",
        "verses": [
            {
                "number": 1,
                "text": "[VERSES TO BE EXTRACTED]"
            }
        ],
        "metadata": {
            "year": 1852,
            "copyright": "Public Domain",
            "publisher": "James White",
            "location": "Rochester, N.Y.",
            "themes": ["[THEMES TO BE DETERMINED]"],
            "original_language": "en",
            "has_chorus": False
        }
    }
    
    hymn_dir = Path("/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/HSAB")
    
    for hymn_num in [175, 176, 177]:
        template_copy = template.copy()
        template_copy["id"] = f"HSAB-en-{hymn_num:03d}"
        template_copy["number"] = hymn_num
        template_copy["title"] = f"[HYMN {hymn_num} - TO BE EXTRACTED]"
        
        file_path = hymn_dir / f"HSAB-en-{hymn_num:03d}.json"
        
        print(f"Template created for: {file_path.name}")
        
        # Don't actually create the files yet - just show what would be created
        # with open(file_path, 'w', encoding='utf-8') as f:
        #     json.dump(template_copy, f, indent=2, ensure_ascii=False)
    
    print("\nThese templates show the format needed for the missing hymns.")
    print("Next step: Find the actual hymn content in the source images.")

def main():
    print("=" * 80)
    print("FINDING MISSING HYMNS 175, 176, 177")
    print("=" * 80)
    
    missing_numbers = get_current_extraction_status()
    
    if missing_numbers:
        print(f"\nMissing hymns to be found: {missing_numbers}")
    else:
        print("\nNo missing hymns found - extraction appears complete.")
        return
    
    analyze_extraction_issue()
    create_missing_hymns_template()
    
    print("\n" + "=" * 80)
    print("NEXT STEPS")
    print("=" * 80)
    print("1. Manually examine the source images for hymns 175-177")
    print("2. Check if these hymns are in supplemental sections")
    print("3. Extract the content using the established schema")
    print("4. Create the missing JSON files")
    
    print("\nLikely locations to check:")
    print("- After page 172 (end of regular hymns)")
    print("- After page 174 (end of index)")
    print("- In appendices or supplemental sections")
    print("- In different formatting that wasn't recognized")

if __name__ == "__main__":
    main()