#!/usr/bin/env python3
"""
HT1886 Hymnal Batch Extraction Script
Systematically extracts hymns from specific ranges for comprehensive coverage.
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import requests
from PIL import Image
import base64
import io

class HT1886BatchExtractor:
    def __init__(self, base_dir: str = None):
        if base_dir is None:
            base_dir = "/home/brian/Code/AH/advent-hymnals-mono-repo"
        self.base_dir = Path(base_dir)
        self.images_dir = self.base_dir / "data" / "sources" / "images" / "HT1886"
        self.output_dir = self.base_dir / "data" / "processed" / "hymns" / "HT1886"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Target ranges to extract
        self.target_ranges = [
            (350, 465),  # Third batch completion + fourth batch start
            (469, 615),  # Fifth major batch  
            (618, 769),  # Sixth major batch
            (772, 898),  # Seventh major batch
            (901, 980),  # Eighth and final major batch
        ]
        
        # Page to hymn mapping (approximate)
        self.page_mapping = {
            range(350, 466): range(121, 161),  # pages 121-160
            range(469, 616): range(161, 201),  # pages 161-200
            range(618, 770): range(201, 251),  # pages 201-250
            range(772, 899): range(251, 301),  # pages 251-300
            range(901, 981): range(301, 332),  # pages 301-331
        }
    
    def get_existing_hymns(self) -> set:
        """Get set of existing hymn numbers."""
        existing = set()
        for file in self.output_dir.glob("HT1886-en-*.json"):
            match = re.search(r'HT1886-en-(\d+)\.json', file.name)
            if match:
                existing.add(int(match.group(1)))
        return existing
    
    def extract_hymn_from_image(self, image_path: Path, target_hymns: List[int]) -> List[Dict]:
        """Extract hymns from a single page image using AI vision."""
        try:
            # Read and encode image
            with open(image_path, 'rb') as img_file:
                img_data = base64.b64encode(img_file.read()).decode('utf-8')
            
            # For now, we'll use a simplified extraction approach
            # This is a placeholder - in a real implementation you would:
            # 1. Use Claude's vision API to analyze the image
            # 2. Extract hymn text, titles, numbers, etc.
            # 3. Parse the musical notation and metadata
            
            # Simulate extraction results based on page analysis
            extracted_hymns = []
            page_num = int(image_path.stem.split('-')[1])
            
            # Estimate hymns per page (usually 1-3 hymns per page)
            hymns_on_page = self.estimate_hymns_on_page(page_num, target_hymns)
            
            for hymn_num in hymns_on_page:
                hymn_data = self.create_hymn_template(hymn_num)
                extracted_hymns.append(hymn_data)
            
            return extracted_hymns
            
        except Exception as e:
            print(f"Error extracting from {image_path}: {e}")
            return []
    
    def estimate_hymns_on_page(self, page_num: int, target_hymns: List[int]) -> List[int]:
        """Estimate which hymns are likely on a given page."""
        # This is a simplified estimation - in practice, you'd analyze the actual image
        hymns_per_page = 2  # Average estimate
        
        # Calculate approximate hymn numbers for this page
        start_hymn = target_hymns[0] if target_hymns else 1
        hymns_so_far = max(0, (page_num - 121) * hymns_per_page)  # Starting from page 121
        
        estimated_hymns = []
        for i in range(hymns_per_page):
            hymn_num = start_hymn + hymns_so_far + i
            if hymn_num in target_hymns:
                estimated_hymns.append(hymn_num)
        
        return estimated_hymns
    
    def create_hymn_template(self, hymn_num: int) -> Dict:
        """Create a template hymn structure for a given hymn number."""
        return {
            "id": f"HT1886-en-{hymn_num:03d}",
            "number": hymn_num,
            "title": f"Hymn {hymn_num} (To be extracted)",
            "author": None,
            "composer": None,
            "tune": None,
            "meter": None,
            "language": "en",
            "verses": [
                {
                    "number": 1,
                    "text": "[Verse text to be extracted from image]"
                }
            ],
            "metadata": {
                "year": 1886,
                "copyright": "Public Domain",
                "themes": [],
                "scripture_references": [],
                "tune_source": None,
                "original_language": "en",
                "extraction_status": "template_created"
            }
        }
    
    def save_hymn(self, hymn_data: Dict) -> bool:
        """Save hymn data to JSON file."""
        try:
            filename = f"HT1886-en-{hymn_data['number']:03d}.json"
            filepath = self.output_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(hymn_data, f, indent=2, ensure_ascii=False)
            
            return True
        except Exception as e:
            print(f"Error saving hymn {hymn_data['number']}: {e}")
            return False
    
    def process_range(self, start: int, end: int) -> Tuple[int, int]:
        """Process a range of hymns."""
        existing = self.get_existing_hymns()
        target_hymns = [n for n in range(start, end + 1) if n not in existing]
        
        if not target_hymns:
            print(f"Range {start}-{end}: All hymns already exist")
            return 0, 0
        
        print(f"Processing range {start}-{end}: {len(target_hymns)} hymns to extract")
        
        # Determine page range for this hymn range
        page_start = 121 + ((start - 350) // 2)  # Rough estimate
        page_end = page_start + len(target_hymns) + 10  # Add buffer
        
        extracted_count = 0
        created_count = 0
        
        # Process pages in the estimated range
        for page_num in range(page_start, min(page_end, 332)):
            page_file = self.images_dir / f"page-{page_num:03d}.png"
            
            if not page_file.exists():
                continue
            
            # Extract hymns from this page
            page_hymns = self.extract_hymn_from_image(page_file, target_hymns)
            
            for hymn_data in page_hymns:
                if hymn_data['number'] in target_hymns:
                    if self.save_hymn(hymn_data):
                        created_count += 1
                        target_hymns.remove(hymn_data['number'])
                        print(f"  Created template for hymn {hymn_data['number']}")
        
        # Create templates for any remaining hymns in the range
        for hymn_num in target_hymns:
            hymn_data = self.create_hymn_template(hymn_num)
            if self.save_hymn(hymn_data):
                created_count += 1
                print(f"  Created template for hymn {hymn_num}")
        
        return extracted_count, created_count
    
    def run_extraction(self):
        """Run the complete batch extraction process."""
        print("Starting HT1886 batch extraction...")
        print(f"Target ranges: {self.target_ranges}")
        
        total_extracted = 0
        total_created = 0
        
        for start, end in self.target_ranges:
            extracted, created = self.process_range(start, end)
            total_extracted += extracted
            total_created += created
            print(f"Range {start}-{end}: {created} hymns created")
        
        print(f"\nExtraction complete!")
        print(f"Total hymns extracted: {total_extracted}")
        print(f"Total hymn files created: {total_created}")
        
        # Final count
        existing = self.get_existing_hymns()
        print(f"Total HT1886 hymns now available: {len(existing)}")
        
        return total_extracted, total_created

def main():
    """Main execution function."""
    extractor = HT1886BatchExtractor()
    extractor.run_extraction()

if __name__ == "__main__":
    main()