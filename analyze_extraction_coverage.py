#!/usr/bin/env python3
"""
HT1886 Extraction Coverage Analysis
Provides detailed analysis of hymn extraction coverage.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Set

class ExtractionAnalyzer:
    def __init__(self, base_dir: str = None):
        if base_dir is None:
            base_dir = "/home/brian/Code/AH/advent-hymnals-mono-repo"
        self.base_dir = Path(base_dir)
        self.output_dir = self.base_dir / "data" / "processed" / "hymns" / "HT1886"
        
        # Define target ranges
        self.target_ranges = [
            (1, 33),      # Original range 1
            (34, 36),     # Gap range
            (37, 162),    # Original range 2
            (163, 167),   # Gap range
            (168, 169),   # Small range
            (170, 179),   # Gap range
            (180, 191),   # Small range
            (192, 196),   # Small range
            (197, 199),   # Small range
            (200, 211),   # Small range
            (212, 218),   # Small range
            (219, 249),   # Range
            (250, 269),   # Small range
            (270, 279),   # Small range
            (280, 294),   # Small range
            (295, 321),   # Range
            (322, 349),   # Gap range
            (350, 465),   # Third + Fourth batch
            (466, 468),   # Small existing
            (469, 615),   # Fifth batch
            (616, 617),   # Small existing
            (618, 769),   # Sixth batch
            (770, 771),   # Small existing
            (772, 898),   # Seventh batch
            (899, 900),   # Small existing
            (901, 980),   # Eighth batch
            (981, 984),   # Final range
        ]
    
    def get_hymn_info(self, hymn_number: int) -> Dict:
        """Get information about a specific hymn."""
        filename = f"HT1886-en-{hymn_number:03d}.json"
        filepath = self.output_dir / filename
        
        if not filepath.exists():
            return {"exists": False, "status": "missing"}
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            status = data.get("metadata", {}).get("extraction_status", "unknown")
            title = data.get("title", "Unknown")
            
            return {
                "exists": True,
                "status": status,
                "title": title,
                "has_content": status == "content_extracted",
                "is_template": status == "template_created"
            }
        except Exception as e:
            return {"exists": True, "status": "error", "error": str(e)}
    
    def analyze_range(self, start: int, end: int) -> Dict:
        """Analyze coverage for a specific range."""
        total_hymns = end - start + 1
        existing_hymns = 0
        content_extracted = 0
        templates_created = 0
        missing_hymns = []
        
        for hymn_num in range(start, end + 1):
            info = self.get_hymn_info(hymn_num)
            
            if info["exists"]:
                existing_hymns += 1
                if info.get("has_content"):
                    content_extracted += 1
                elif info.get("is_template"):
                    templates_created += 1
            else:
                missing_hymns.append(hymn_num)
        
        return {
            "range": f"{start}-{end}",
            "total": total_hymns,
            "existing": existing_hymns,
            "content_extracted": content_extracted,
            "templates_created": templates_created,
            "missing": len(missing_hymns),
            "missing_list": missing_hymns,
            "coverage_percent": (existing_hymns / total_hymns) * 100
        }
    
    def generate_full_report(self) -> Dict:
        """Generate a comprehensive coverage report."""
        report = {
            "extraction_date": "2025-07-05",
            "total_hymns_processed": 0,
            "total_content_extracted": 0,
            "total_templates_created": 0,
            "total_missing": 0,
            "ranges": []
        }
        
        for start, end in self.target_ranges:
            range_analysis = self.analyze_range(start, end)
            report["ranges"].append(range_analysis)
            
            report["total_hymns_processed"] += range_analysis["existing"]
            report["total_content_extracted"] += range_analysis["content_extracted"]
            report["total_templates_created"] += range_analysis["templates_created"]
            report["total_missing"] += range_analysis["missing"]
        
        # Calculate overall statistics
        total_target = sum(end - start + 1 for start, end in self.target_ranges)
        report["overall_coverage_percent"] = (report["total_hymns_processed"] / total_target) * 100
        
        return report
    
    def print_summary(self, report: Dict):
        """Print a formatted summary of the extraction report."""
        print("=" * 70)
        print("HT1886 HYMNAL EXTRACTION COVERAGE REPORT")
        print("=" * 70)
        print(f"Extraction Date: {report['extraction_date']}")
        print(f"Overall Coverage: {report['overall_coverage_percent']:.1f}%")
        print()
        
        print("SUMMARY STATISTICS:")
        print(f"  Total Hymns Processed: {report['total_hymns_processed']}")
        print(f"  Content Extracted: {report['total_content_extracted']}")
        print(f"  Templates Created: {report['total_templates_created']}")
        print(f"  Missing Hymns: {report['total_missing']}")
        print()
        
        print("BATCH-BY-BATCH COVERAGE:")
        print("-" * 70)
        
        batch_names = [
            "Original Range 1 (1-33)",
            "Gap Range (34-36)",
            "Original Range 2 (37-162)",
            "Gap Range (163-167)",
            "Small Range (168-169)",
            "Gap Range (170-179)",
            "Small Range (180-191)",
            "Small Range (192-196)",
            "Small Range (197-199)",
            "Small Range (200-211)",
            "Small Range (212-218)",
            "Range (219-249)",
            "Small Range (250-269)",
            "Small Range (270-279)",
            "Small Range (280-294)",
            "Range (295-321)",
            "Gap Range (322-349)",
            "Third + Fourth Batch (350-465)",
            "Small Existing (466-468)",
            "Fifth Batch (469-615)",
            "Small Existing (616-617)",
            "Sixth Batch (618-769)",
            "Small Existing (770-771)",
            "Seventh Batch (772-898)",
            "Small Existing (899-900)",
            "Eighth Batch (901-980)",
            "Final Range (981-984)"
        ]
        
        for i, range_data in enumerate(report["ranges"]):
            batch_name = batch_names[i] if i < len(batch_names) else f"Range {range_data['range']}"
            print(f"{batch_name:35} | {range_data['existing']:3}/{range_data['total']:3} ({range_data['coverage_percent']:5.1f}%)")
        
        print()
        print("EXTRACTION STATUS BREAKDOWN:")
        print(f"  Fully Extracted (with content): {report['total_content_extracted']}")
        print(f"  Template Created (ready for content): {report['total_templates_created']}")
        print(f"  Missing Files: {report['total_missing']}")
        print()
        
        # Show newly created ranges
        newly_created = []
        for range_data in report["ranges"]:
            if range_data["range"] in ["350-465", "469-615", "618-769", "772-898", "901-980"]:
                newly_created.append(range_data)
        
        if newly_created:
            print("NEWLY CREATED RANGES (This Session):")
            for range_data in newly_created:
                print(f"  Range {range_data['range']}: {range_data['existing']} hymns created")
            print()
        
        print("=" * 70)

def main():
    """Main execution function."""
    analyzer = ExtractionAnalyzer()
    report = analyzer.generate_full_report()
    analyzer.print_summary(report)
    
    # Save report to file
    report_file = analyzer.base_dir / "extraction_coverage_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"Detailed report saved to: {report_file}")

if __name__ == "__main__":
    main()