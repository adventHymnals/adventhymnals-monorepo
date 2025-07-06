# Hymnal Data Structure

This directory contains the organized hymnal data for the Advent Hymnals project.

## Directory Structure

### `/sources`
Raw hymnal data in various formats:
- `images/` - Scanned hymnal pages (PNG, JPG, TIFF)
- `pdf/` - OCR'd PDF documents
- `markdown/` - Manually transcribed hymns in markdown format
- `legacy/` - Historical hymnal data from existing projects

### `/processed`
Processed and cleaned hymnal data:
- `hymns/` - Individual hymn files in JSON format
- `hymnals/` - Complete hymnal collections
- `metadata/` - Extracted metadata (authors, composers, tunes)
- `indices/` - Generated indices and cross-references

## File Naming Convention

### Source Files
- `{hymnal-name}-{language}-{format}.{ext}`
- Examples:
  - `sda-hymnal-en-images/`
  - `christ-in-song-sw-ocr.pdf`
  - `millenial-harp-en-markdown.md`

### Processed Files
- `{hymnal-id}-v{version}.json` for hymnal collections
- `{hymnal-id}-hymn-{number}.json` for individual hymns
- `{hymnal-id}-metadata.json` for metadata collections

## Data Formats

### Hymn JSON Structure
```json
{
  "id": "unique-hymn-id",
  "number": 123,
  "title": "Hymn Title",
  "author": "Author Name",
  "composer": "Composer Name",
  "tune": "Tune Name",
  "meter": "8.7.8.7 D",
  "language": "en",
  "verses": [
    {
      "number": 1,
      "text": "Verse text here..."
    }
  ],
  "chorus": {
    "text": "Chorus text here..."
  },
  "metadata": {
    "year": 1941,
    "copyright": "Public Domain",
    "themes": ["praise", "worship"],
    "scripture_references": ["Ps 23:1"]
  }
}
```

### Hymnal JSON Structure
```json
{
  "id": "hymnal-id",
  "title": "Hymnal Title",
  "language": "en",
  "year": 1941,
  "publisher": "Publisher Name",
  "hymns": [
    {
      "number": 1,
      "hymn_id": "hymn-id-reference"
    }
  ],
  "metadata": {
    "total_hymns": 695,
    "languages": ["en"],
    "themes": ["worship", "praise", "service"]
  }
}
```