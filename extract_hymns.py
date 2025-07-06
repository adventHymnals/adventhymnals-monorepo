#!/usr/bin/env python3
import os
import json
import subprocess
import re
from typing import List, Dict, Any, Optional

def run_ocr(image_path: str) -> str:
    """Run OCR on image and return cleaned text"""
    try:
        result = subprocess.run([
            'tesseract', image_path, '-', '--psm', '3',
            '-c', 'tessedit_char_whitelist=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,\\-\\(\\)\\:\\;\\"\\  '
        ], capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"OCR failed for {image_path}: {e}")
        return ""

def clean_text(text: str) -> str:
    """Clean OCR text by removing musical notation artifacts"""
    # Remove lines with mostly musical notation characters
    lines = text.split('\n')
    cleaned_lines = []
    
    for line in lines:
        # Skip lines that are mostly musical notation artifacts
        if len(line.strip()) > 0:
            # Remove excessive whitespace and clean up
            cleaned_line = re.sub(r'\s+', ' ', line.strip())
            # Skip lines that are mostly single characters or musical symbols
            if len(cleaned_line) > 2 and not re.match(r'^[a-zA-Z\s\-]{0,3}$', cleaned_line):
                cleaned_lines.append(cleaned_line)
    
    return '\n'.join(cleaned_lines)

def extract_hymn_number(text: str) -> Optional[int]:
    """Extract hymn number from text"""
    # Look for patterns like "1.", "2.", etc. at the beginning of lines
    lines = text.split('\n')
    for line in lines:
        if line.strip().startswith(('1.', '2.', '3.', '4.', '5.')):
            return int(line.strip()[0])
    return None

def extract_title(text: str) -> Optional[str]:
    """Extract hymn title from text"""
    lines = text.split('\n')
    for line in lines:
        line = line.strip()
        # Title is usually the first substantial line that's not a verse
        # Look for lines that look like titles (capitalized, not starting with verse numbers)
        if (len(line) > 5 and 
            not line.startswith(('1.', '2.', '3.', '4.', '5.')) and
            not re.match(r'^[a-zA-Z\s\-]{0,5}$', line) and
            # Check if line contains title-like words
            (re.search(r'[A-Z][a-z]+.*[A-Z]', line) or
             any(word in line for word in ['Praise', 'Lord', 'God', 'Jesus', 'Christ', 'Holy', 'Come', 'King', 'Heaven', 'My', 'Soul']))):
            # Clean up the title
            title = re.sub(r'[^a-zA-Z\s,\-\']', '', line)
            title = re.sub(r'\s+', ' ', title).strip()
            if len(title) > 3:
                return title
    return None

def extract_verses(text: str) -> List[Dict[str, Any]]:
    """Extract verses from text"""
    verses = []
    lines = text.split('\n')
    
    current_verse = None
    current_verse_text = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Check if this line starts a new verse
        if line.startswith(('1.', '2.', '3.', '4.', '5.')):
            # Save previous verse if exists
            if current_verse is not None and current_verse_text:
                # Clean up the verse text
                verse_text = ' '.join(current_verse_text)
                verse_text = clean_verse_text(verse_text)
                if verse_text:
                    verses.append({
                        'number': current_verse,
                        'text': verse_text
                    })
            
            # Start new verse
            current_verse = int(line[0])
            # Remove the number and get the rest of the line
            verse_text = line[2:].strip()
            current_verse_text = [verse_text] if verse_text else []
        elif current_verse is not None:
            # Continue current verse
            # Filter out lines that are mostly musical notation
            if (len(line) > 2 and 
                not re.match(r'^[a-zA-Z\s\-]{0,3}$', line) and
                not re.match(r'^[^a-zA-Z]*$', line)):  # Skip lines with no letters
                current_verse_text.append(line)
    
    # Save last verse
    if current_verse is not None and current_verse_text:
        verse_text = ' '.join(current_verse_text)
        verse_text = clean_verse_text(verse_text)
        if verse_text:
            verses.append({
                'number': current_verse,
                'text': verse_text
            })
    
    return verses

def clean_verse_text(text: str) -> str:
    """Clean verse text by removing OCR artifacts"""
    # Remove excessive musical notation artifacts
    text = re.sub(r'[^a-zA-Z\s,\-\.\;\:\'\"\(\)]', ' ', text)
    # Remove multiple spaces
    text = re.sub(r'\s+', ' ', text)
    # Remove very short fragments
    words = text.split()
    cleaned_words = []
    for word in words:
        if len(word) > 1 or word.lower() in ['a', 'i', 'o']:
            cleaned_words.append(word)
    return ' '.join(cleaned_words).strip()

def process_hymn_image(image_path: str, hymn_number: int) -> Optional[Dict[str, Any]]:
    """Process a single hymn image and return structured data"""
    print(f"Processing hymn {hymn_number}: {image_path}")
    
    # Run OCR
    raw_text = run_ocr(image_path)
    if not raw_text:
        return None
    
    # Clean text
    cleaned_text = clean_text(raw_text)
    
    # Extract hymn data
    title = extract_title(cleaned_text)
    verses = extract_verses(cleaned_text)
    
    if not title or not verses:
        print(f"Warning: Could not extract title or verses for hymn {hymn_number}")
        return None
    
    # Create hymn data structure
    hymn_data = {
        'id': f'SDAH-en-{hymn_number:03d}',
        'number': hymn_number,
        'title': title,
        'language': 'en',
        'verses': verses
    }
    
    return hymn_data

def process_hymns_batch(start: int, end: int, source_dir: str, output_dir: str):
    """Process a batch of hymns"""
    print(f"Processing hymns {start}-{end}")
    
    for i in range(start, end + 1):
        image_path = os.path.join(source_dir, f'{i:03d}.png')
        
        if not os.path.exists(image_path):
            print(f"Warning: Image not found: {image_path}")
            continue
        
        hymn_data = process_hymn_image(image_path, i)
        
        if hymn_data:
            # Save hymn data
            output_path = os.path.join(output_dir, f'SDAH-en-{i:03d}.json')
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(hymn_data, f, indent=2, ensure_ascii=False)
            print(f"Saved: {output_path}")
        else:
            print(f"Failed to process hymn {i}")

def generate_processing_stats(output_dir: str):
    """Generate processing statistics"""
    processed_files = [f for f in os.listdir(output_dir) if f.endswith('.json')]
    total_processed = len(processed_files)
    
    stats = {
        'total_hymns_expected': 695,
        'total_hymns_processed': total_processed,
        'success_rate': (total_processed / 695) * 100,
        'processing_date': '2025-07-04',
        'processed_files': sorted(processed_files)
    }
    
    stats_path = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/indices/SDAH/processing-stats.json'
    with open(stats_path, 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=2, ensure_ascii=False)
    
    print(f"\n=== Processing Statistics ===")
    print(f"Expected hymns: {stats['total_hymns_expected']}")
    print(f"Successfully processed: {stats['total_hymns_processed']}")
    print(f"Success rate: {stats['success_rate']:.1f}%")
    print(f"Statistics saved to: {stats_path}")

def main():
    source_dir = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/sources/images/SDAH'
    output_dir = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/SDAH'
    
    # Process in batches of 100
    for batch_start in range(51, 696, 100):  # Start from 51, go to 695
        batch_end = min(batch_start + 99, 695)
        print(f"\n=== Processing batch {batch_start}-{batch_end} ===")
        process_hymns_batch(batch_start, batch_end, source_dir, output_dir)
        
    # Generate statistics
    generate_processing_stats(output_dir)

if __name__ == '__main__':
    main()