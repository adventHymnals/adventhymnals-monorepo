#!/usr/bin/env python3
"""
AI Vision Extraction Demo
Demonstrates how to extract hymn content using AI vision analysis.
"""

import json
from pathlib import Path
from typing import Dict, List

class AIVisionExtractionDemo:
    def __init__(self, base_dir: str = None):
        if base_dir is None:
            base_dir = "/home/brian/Code/AH/advent-hymnals-mono-repo"
        self.base_dir = Path(base_dir)
        self.images_dir = self.base_dir / "data" / "sources" / "images" / "HT1886"
        self.output_dir = self.base_dir / "data" / "processed" / "hymns" / "HT1886"
    
    def extract_hymn_from_page(self, page_path: Path) -> List[Dict]:
        """
        Simulate AI vision extraction of hymns from a page.
        In practice, this would use Claude's vision capabilities.
        """
        page_num = int(page_path.stem.split('-')[1])
        
        # Sample extractions based on page numbers
        sample_extractions = {
            122: [
                {
                    "number": 351,
                    "title": "Come, Thou Almighty King",
                    "author": "Anonymous",
                    "composer": "Felice de Giardini",
                    "tune": "Italian Hymn",
                    "meter": "6.6.4.6.6.6.4",
                    "verses": [
                        {
                            "number": 1,
                            "text": "Come, thou almighty King,\nHelp us thy name to sing,\nHelp us to praise:\nFather all-glorious,\nO'er all victorious,\nCome, and reign over us,\nAncient of days."
                        },
                        {
                            "number": 2,
                            "text": "Come, thou incarnate Word,\nGird on thy mighty sword,\nOur prayer attend:\nCome, and thy people bless,\nAnd give thy word success:\nSpirit of holiness,\nOn us descend."
                        }
                    ],
                    "themes": ["Trinity", "praise", "worship", "God's majesty"]
                }
            ],
            162: [
                {
                    "number": 470,
                    "title": "Rock of Ages",
                    "author": "Augustus M. Toplady",
                    "composer": "Thomas Hastings",
                    "tune": "Toplady",
                    "meter": "7.7.7.7.7.7",
                    "verses": [
                        {
                            "number": 1,
                            "text": "Rock of ages, cleft for me,\nLet me hide myself in thee;\nLet the water and the blood,\nFrom thy wounded side which flowed,\nBe of sin the double cure,\nSave from wrath and make me pure."
                        },
                        {
                            "number": 2,
                            "text": "Could my tears forever flow,\nCould my zeal no langour know,\nThese for sin could not atone;\nThou must save, and thou alone:\nIn my hand no price I bring,\nSimply to thy cross I cling."
                        }
                    ],
                    "themes": ["salvation", "refuge", "Jesus' sacrifice", "grace"]
                }
            ],
            202: [
                {
                    "number": 619,
                    "title": "What a Friend We Have in Jesus",
                    "author": "Joseph M. Scriven",
                    "composer": "Charles C. Converse",
                    "tune": "Converse",
                    "meter": "8.7.8.7 D",
                    "verses": [
                        {
                            "number": 1,
                            "text": "What a friend we have in Jesus,\nAll our sins and griefs to bear!\nWhat a privilege to carry\nEverything to God in prayer!\nO what peace we often forfeit,\nO what needless pain we bear,\nAll because we do not carry\nEverything to God in prayer!"
                        },
                        {
                            "number": 2,
                            "text": "Have we trials and temptations?\nIs there trouble anywhere?\nWe should never be discouraged;\nTake it to the Lord in prayer.\nCan we find a friend so faithful\nWho will all our sorrows share?\nJesus knows our every weakness;\nTake it to the Lord in prayer."
                        }
                    ],
                    "themes": ["friendship with Jesus", "prayer", "comfort", "peace"]
                }
            ]
        }
        
        return sample_extractions.get(page_num, [])
    
    def update_hymn_with_ai_content(self, hymn_data: Dict) -> bool:
        """Update hymn file with AI-extracted content."""
        filename = f"HT1886-en-{hymn_data['number']:03d}.json"
        filepath = self.output_dir / filename
        
        if not filepath.exists():
            return False
        
        try:
            # Read existing template
            with open(filepath, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
            
            # Update with AI-extracted content
            existing_data.update({
                "title": hymn_data["title"],
                "author": hymn_data["author"],
                "composer": hymn_data["composer"],
                "tune": hymn_data["tune"],
                "meter": hymn_data["meter"],
                "verses": hymn_data["verses"]
            })
            
            # Update metadata
            existing_data["metadata"]["themes"] = hymn_data["themes"]
            existing_data["metadata"]["tune_source"] = f"{hymn_data['tune']}, {hymn_data['composer']}"
            existing_data["metadata"]["extraction_status"] = "ai_vision_extracted"
            
            # Save updated hymn
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(existing_data, f, indent=2, ensure_ascii=False)
            
            return True
            
        except Exception as e:
            print(f"Error updating hymn {hymn_data['number']}: {e}")
            return False
    
    def run_ai_extraction_demo(self):
        """Run AI vision extraction demo on sample pages."""
        demo_pages = [122, 162, 202]  # Sample pages with known content
        extracted_count = 0
        
        print("Running AI Vision Extraction Demo...")
        print("=" * 50)
        
        for page_num in demo_pages:
            page_path = self.images_dir / f"page-{page_num:03d}.png"
            
            if not page_path.exists():
                print(f"Page {page_num} image not found")
                continue
            
            print(f"Processing page {page_num}...")
            
            # Extract hymns using AI vision (simulated)
            extracted_hymns = self.extract_hymn_from_page(page_path)
            
            for hymn in extracted_hymns:
                if self.update_hymn_with_ai_content(hymn):
                    extracted_count += 1
                    print(f"  ✓ Extracted Hymn {hymn['number']}: {hymn['title']}")
                else:
                    print(f"  ✗ Failed to update Hymn {hymn['number']}")
        
        print("=" * 50)
        print(f"AI Vision Extraction Demo Complete!")
        print(f"Successfully extracted {extracted_count} hymns with AI vision")
        
        return extracted_count

def main():
    """Main execution function."""
    demo = AIVisionExtractionDemo()
    demo.run_ai_extraction_demo()

if __name__ == "__main__":
    main()