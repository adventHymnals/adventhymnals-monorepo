#!/usr/bin/env python3
import os
import json
import re
from typing import Dict, List, Set, Any
from collections import defaultdict

def load_processed_hymns(hymns_dir: str) -> List[Dict[str, Any]]:
    """Load all processed hymn files"""
    hymns = []
    
    for filename in sorted(os.listdir(hymns_dir)):
        if filename.endswith('.json'):
            filepath = os.path.join(hymns_dir, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    hymn_data = json.load(f)
                    hymns.append(hymn_data)
            except Exception as e:
                print(f"Error loading {filename}: {e}")
    
    return hymns

def extract_authors_from_hymns(hymns: List[Dict[str, Any]]) -> Dict[str, Dict[str, Any]]:
    """Extract authors index from hymns"""
    authors = {}
    
    for hymn in hymns:
        author = hymn.get('author')
        if author and author.strip():
            author_clean = author.strip()
            if author_clean not in authors:
                authors[author_clean] = {
                    'id': re.sub(r'[^a-zA-Z0-9]', '_', author_clean.lower()),
                    'name': author_clean,
                    'hymns': []
                }
            authors[author_clean]['hymns'].append(hymn['id'])
    
    return authors

def extract_themes_from_hymns(hymns: List[Dict[str, Any]]) -> Dict[str, List[str]]:
    """Extract themes from hymn titles and content"""
    themes = defaultdict(list)
    
    # Define theme keywords
    theme_keywords = {
        'praise': ['praise', 'glory', 'honor', 'worship', 'adore', 'exalt'],
        'salvation': ['salvation', 'saved', 'grace', 'redemption', 'forgiveness'],
        'jesus': ['jesus', 'christ', 'savior', 'lord'],
        'god': ['god', 'father', 'almighty', 'creator'],
        'holy_spirit': ['spirit', 'holy ghost', 'comforter'],
        'christmas': ['christmas', 'bethlehem', 'nativity', 'born', 'manger'],
        'easter': ['easter', 'resurrection', 'risen', 'cross', 'calvary'],
        'prayer': ['prayer', 'pray', 'commune', 'talk'],
        'peace': ['peace', 'rest', 'calm', 'quiet'],
        'love': ['love', 'beloved', 'dear'],
        'heaven': ['heaven', 'eternal', 'home', 'glory'],
        'faith': ['faith', 'trust', 'believe', 'confidence'],
        'hope': ['hope', 'anchor', 'future'],
        'service': ['service', 'work', 'labor', 'mission'],
        'guidance': ['guide', 'lead', 'direction', 'path', 'way'],
        'creation': ['creation', 'nature', 'earth', 'sky', 'mountains']
    }
    
    for hymn in hymns:
        title = hymn.get('title', '').lower()
        verses_text = ' '.join([v.get('text', '') for v in hymn.get('verses', [])]).lower()
        combined_text = f"{title} {verses_text}"
        
        for theme, keywords in theme_keywords.items():
            if any(keyword in combined_text for keyword in keywords):
                themes[theme].append(hymn['id'])
    
    return themes

def extract_first_lines(hymns: List[Dict[str, Any]]) -> Dict[str, str]:
    """Extract first lines index"""
    first_lines = {}
    
    for hymn in hymns:
        verses = hymn.get('verses', [])
        if verses and len(verses) > 0:
            first_verse = verses[0]
            first_line = first_verse.get('text', '').strip()
            # Clean up the first line
            first_line = re.sub(r'\s+', ' ', first_line)
            # Take first meaningful part (up to first comma or semicolon)
            first_line = re.split(r'[,;]', first_line)[0].strip()
            if first_line:
                first_lines[hymn['id']] = first_line
    
    return first_lines

def generate_hymnal_collection(hymns: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Generate hymnal collection metadata"""
    return {
        'id': 'SDAH',
        'title': 'Seventh-day Adventist Hymnal',
        'language': 'en',
        'year': 1985,
        'publisher': 'Review and Herald Publishing Association',
        'hymns': [
            {
                'number': hymn['number'],
                'hymn_id': hymn['id'],
                'title': hymn.get('title', '')
            }
            for hymn in sorted(hymns, key=lambda x: x['number'])
        ],
        'metadata': {
            'total_hymns': len(hymns),
            'languages': ['en'],
            'themes': list(extract_themes_from_hymns(hymns).keys()),
            'publication_info': {
                'publisher': 'Review and Herald Publishing Association',
                'place': 'Hagerstown, MD',
                'isbn': None
            }
        }
    }

def main():
    hymns_dir = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymns/SDAH'
    metadata_dir = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/metadata/SDAH'
    hymnals_dir = '/home/brian/Code/AH/advent-hymnals-mono-repo/data/processed/hymnals'
    
    # Create hymnals directory if it doesn't exist
    os.makedirs(hymnals_dir, exist_ok=True)
    
    print("Loading processed hymns...")
    hymns = load_processed_hymns(hymns_dir)
    
    if not hymns:
        print("No processed hymns found!")
        return
    
    print(f"Loaded {len(hymns)} hymns")
    
    # Generate authors index
    print("Generating authors index...")
    authors = extract_authors_from_hymns(hymns)
    authors_path = os.path.join(metadata_dir, 'authors.json')
    with open(authors_path, 'w', encoding='utf-8') as f:
        json.dump(authors, f, indent=2, ensure_ascii=False)
    print(f"Authors index saved: {authors_path}")
    
    # Generate themes index
    print("Generating themes index...")
    themes = extract_themes_from_hymns(hymns)
    themes_path = os.path.join(metadata_dir, 'themes.json')
    with open(themes_path, 'w', encoding='utf-8') as f:
        json.dump(dict(themes), f, indent=2, ensure_ascii=False)
    print(f"Themes index saved: {themes_path}")
    
    # Generate first lines index
    print("Generating first lines index...")
    first_lines = extract_first_lines(hymns)
    first_lines_path = os.path.join(metadata_dir, 'first-lines.json')
    with open(first_lines_path, 'w', encoding='utf-8') as f:
        json.dump(first_lines, f, indent=2, ensure_ascii=False)
    print(f"First lines index saved: {first_lines_path}")
    
    # Generate hymnal collection
    print("Generating hymnal collection...")
    collection = generate_hymnal_collection(hymns)
    collection_path = os.path.join(hymnals_dir, 'SDAH-collection.json')
    with open(collection_path, 'w', encoding='utf-8') as f:
        json.dump(collection, f, indent=2, ensure_ascii=False)
    print(f"Hymnal collection saved: {collection_path}")
    
    # Generate summary
    print(f"\n=== Metadata Generation Summary ===")
    print(f"Total hymns processed: {len(hymns)}")
    print(f"Authors found: {len(authors)}")
    print(f"Themes identified: {len(themes)}")
    print(f"First lines indexed: {len(first_lines)}")

if __name__ == '__main__':
    main()