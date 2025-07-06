# Extract Hymnal Data from Images

Extract hymns and metadata from scanned hymnal images using AI vision capabilities, handling multi-page hymns and multiple hymns per page.

## Hymnal ID: $ARGUMENTS

## AI Vision Extraction Process

1. **Load Hymnal Context**
   - Read and understand the hymnal ID: $ARGUMENTS
   - Analyze the hymnal image directory structure in data/sources/images/{hymnal-id}/
   - Load hymnal-info.json to understand the hymnal structure and metadata
   - Examine image naming conventions and file organization
   - Count total images and estimate processing scope
   - Review existing processed data to avoid duplication

2. **ULTRATHINK**
   - Think hard before processing images. Create a comprehensive extraction strategy
   - Break down extraction into manageable batches using your TodoWrite tool
   - Use the TodoWrite tool to create and track your extraction plan
   - Identify potential challenges: multi-page hymns, multiple hymns per page, image quality
   - Plan for handling incomplete hymns that span multiple pages
   - Consider metadata extraction strategies (titles, authors, composers, tune names)
   - Plan for error handling and quality validation of extracted data

3. **Execute AI Vision Processing**
   - Process images in sequential order to maintain hymn continuity
   - Use AI vision capabilities to read and understand each image
   - Identify hymn boundaries and numbers within each image
   - Extract hymn metadata (title, author, composer, tune name, meter)
   - Handle multi-page hymns by combining text from consecutive images
   - Process multiple hymns per page when detected
   - Apply intelligent text recognition and cleanup
   - Validate extracted hymn structure and completeness

4. **Structure Hymn Data**
   - Create individual hymn JSON files following the required schema
   - Generate unique hymn IDs using the format: {hymnal-id}-{language}-{number}
   - Organize verses, chorus, and metadata into structured format
   - Extract and normalize metrical patterns
   - Identify themes and scripture references where present
   - Create cross-references between related hymns
   - Validate data integrity and completeness

5. **Generate Indices and Metadata**
   - Create author index with biographical information where available
   - Generate composer index with tune information
   - Build metrical pattern index for hymn classification
   - Create theme-based categorization
   - Generate scripture reference index
   - Build first-line index for hymn identification
   - Create tune name index with associated hymns

6. **Validate and Complete**
   - Validate all extracted hymn data against the defined schema
   - Check for missing hymns or incomplete extractions
   - Verify metadata accuracy and completeness
   - Cross-reference with existing hymnal databases if available
   - Generate processing statistics and quality metrics
   - Create hymnal collection JSON file with complete metadata
   - Update processing status in hymnal-info.json

## AI Vision Processing Strategy

### Image Analysis Workflow
For each image file:
1. Use Read tool to load and analyze the image
2. Extract all visible text content using AI vision
3. Identify hymn numbers and boundaries
4. Extract hymn titles and metadata
5. Parse verse structure and chorus
6. Handle continuation from previous image
7. Save structured data using Write tool

### Multi-Page Hymn Handling
- Track incomplete hymns from previous pages
- Combine text segments when hymn spans multiple pages
- Maintain verse numbering across page boundaries
- Detect hymn completion and finalize data

### Multiple Hymns Per Page
- Identify multiple hymn numbers on single page
- Split content between different hymns
- Handle partial hymns that continue on next page
- Maintain proper hymn sequencing

## Required Data Format

### Individual Hymn JSON Schema
```json
{
  "id": "SDAH-en-001",
  "number": 1,
  "title": "Holy, Holy, Holy",
  "author": "Reginald Heber",
  "composer": "John B. Dykes",
  "tune": "Nicaea",
  "meter": "11.12.12.10",
  "language": "en",
  "verses": [
    {
      "number": 1,
      "text": "Holy, holy, holy! Lord God Almighty!\nEarly in the morning our song shall rise to Thee;\nHoly, holy, holy! merciful and mighty!\nGod in three Persons, blessed Trinity!"
    },
    {
      "number": 2,
      "text": "Holy, holy, holy! all the saints adore Thee,\nCasting down their golden crowns around the glassy sea;\nCherubim and seraphim falling down before Thee,\nWhich wert, and art, and evermore shalt be."
    }
  ],
  "chorus": {
    "text": "Holy, holy, holy! Lord God Almighty!\nAll Thy works shall praise Thy name in earth and sky and sea!"
  },
  "metadata": {
    "year": 1826,
    "copyright": "Public Domain",
    "themes": ["worship", "trinity", "praise"],
    "scripture_references": ["Rev 4:8", "Isa 6:3"],
    "tune_source": "Nicaea, John B. Dykes, 1861",
    "original_language": "en"
  }
}
```

### Hymnal Collection JSON Schema
```json
{
  "id": "SDAH",
  "title": "Seventh-day Adventist Hymnal",
  "language": "en",
  "year": 1985,
  "publisher": "Review and Herald Publishing Association",
  "hymns": [
    {
      "number": 1,
      "hymn_id": "SDAH-en-001",
      "title": "Holy, Holy, Holy",
      "page": 1
    }
  ],
  "metadata": {
    "total_hymns": 695,
    "languages": ["en"],
    "themes": ["worship", "praise", "service", "salvation"],
    "publication_info": {
      "publisher": "Review and Herald Publishing Association",
      "place": "Hagerstown, MD",
      "isbn": "978-0-8280-0000-0"
    }
  }
}
```

### Author Index JSON Schema
```json
{
  "authors": [
    {
      "id": "reginald-heber",
      "name": "Reginald Heber",
      "birth_year": 1783,
      "death_year": 1826,
      "nationality": "English",
      "biography": "Anglican bishop and hymn writer",
      "hymns": ["SDAH-en-001", "SDAH-en-045"]
    }
  ]
}
```

### Composer Index JSON Schema
```json
{
  "composers": [
    {
      "id": "john-b-dykes",
      "name": "John B. Dykes",
      "birth_year": 1823,
      "death_year": 1876,
      "nationality": "English",
      "biography": "Anglican clergyman and composer",
      "tunes": ["Nicaea", "Melita", "Hollingside"]
    }
  ]
}
```

### Tune Index JSON Schema
```json
{
  "tunes": [
    {
      "id": "nicaea",
      "name": "Nicaea",
      "composer_id": "john-b-dykes",
      "meter": "11.12.12.10",
      "year": 1861,
      "source": "Hymns Ancient and Modern",
      "hymns": ["SDAH-en-001"]
    }
  ]
}
```

### Metrical Pattern Index JSON Schema
```json
{
  "patterns": [
    {
      "pattern": "11.12.12.10",
      "variations": ["11.12.12.10", "11 12 12 10"],
      "hymns": ["SDAH-en-001", "SDAH-en-234"]
    }
  ]
}
```

## File Organization Structure

### Save locations for extracted data:
```
data/processed/hymns/{hymnal-id}/
├── {hymnal-id}-{language}-001.json
├── {hymnal-id}-{language}-002.json
├── ...
└── {hymnal-id}-{language}-695.json

data/processed/hymnals/
└── {hymnal-id}-collection.json

data/processed/metadata/{hymnal-id}/
├── authors.json
├── composers.json
├── tunes.json
├── themes.json
├── metrical-patterns.json
└── scripture-references.json

data/processed/indices/{hymnal-id}/
├── processing-log.json
├── extraction-stats.json
└── quality-report.json
```

## Processing Instructions for AI

### When analyzing each image:
1. **Read the image** using the Read tool
2. **Identify hymn numbers** - usually at the top of each hymn
3. **Extract the title** - typically bold text below the hymn number
4. **Find metadata** - author, composer, tune name (often in smaller text)
5. **Parse verses** - numbered sections of the hymn text
6. **Identify chorus/refrain** - repeated sections (may be labeled)
7. **Extract meter** - metrical pattern (e.g., 8.7.8.7.D)
8. **Note any continuation** - if hymn continues on next page

### Quality Guidelines:
- Preserve original text formatting and punctuation
- Maintain consistent verse numbering
- Handle special characters and diacritical marks
- Identify incomplete hymns that span multiple pages
- Flag unclear or damaged text for manual review

### Error Handling:
- If text is unclear, mark with [unclear] annotation
- If hymn continues on next page, note "continued"
- If multiple hymns on one page, process each separately
- Handle missing or damaged pages gracefully

## Usage Examples

```bash
# Extract all hymns from SDAH (Seventh-day Adventist Hymnal)
/extract-from-images SDAH

# Extract from Christ in Song hymnal
/extract-from-images CIS

# Extract from Millenial Harp
/extract-from-images MH

# Extract from Swahili hymnal
/extract-from-images NZK
```

## Completion Criteria

Hymnal extraction is complete when:
- [ ] All hymn images are processed successfully
- [ ] Individual hymn JSON files are created with complete structure
- [ ] Metadata indices are generated and populated
- [ ] Hymnal collection file is created with summary information
- [ ] Processing statistics show acceptable quality metrics
- [ ] Error log contains manageable number of issues
- [ ] Cross-references and relationships are established
- [ ] Data validation passes all schema checks

## Quality Assurance

### Validation Checks:
- Hymn count matches expected total (695 for SDAH)
- All required metadata fields present
- Verse numbering consistency
- Cross-reference accuracy
- JSON schema compliance

### Processing Statistics:
- Total images processed
- Successful extractions
- Partial/incomplete hymns
- Quality confidence scores
- Error/unclear text instances

This command leverages AI vision capabilities to intelligently extract and structure hymnal data, providing comprehensive digitization of traditional hymnals with high accuracy and detailed metadata preservation.