# Local PDF Generation Guide

This guide explains how to generate PDFs locally for testing the PDF download functionality.

## Setup

1. **Install dependencies** (if not already done):
   ```bash
   cd apps/web
   pnpm install
   ```

2. **Start the development server**:
   ```bash
   pnpm run dev
   ```
   Keep this running in one terminal.

3. **Run PDF generation** (in another terminal):
   ```bash
   cd apps/web
   pnpm run generate-pdfs-sample  # Generate 5 PDFs for testing
   # OR
   pnpm run generate-pdfs         # Generate all PDFs (can take a while)
   # OR
   pnpm run generate-pdfs-force   # Force regenerate all PDFs
   ```

## PDF Storage Location

PDFs are saved in: `apps/web/public/pdfs/`

They are accessible at: `http://localhost:3000/pdfs/`

**Examples:**
- `http://localhost:3000/pdfs/sdah-1.pdf`
- `http://localhost:3000/pdfs/christ-in-song-25.pdf`

## PDF Index

An index file is automatically created at: `apps/web/public/pdfs/index.json`

This contains metadata about all available PDFs and is used by the PDF download buttons to check availability.

## Testing the PDF System

1. **Start dev server**: `pnpm run dev`
2. **Generate sample PDFs**: `pnpm run generate-pdfs-sample`
3. **Visit a hymn page**: e.g., `http://localhost:3000/seventh-day-adventist-hymnal/hymn-1-holy-holy-holy`
4. **Test PDF download button**: Should show "Download PDF" for generated hymns

## Script Options

### Basic Commands
```bash
# Generate first 5 PDFs from all hymnals (for testing)
pnpm run generate-pdfs-sample

# Generate all PDFs
pnpm run generate-pdfs

# Force regenerate all PDFs (overwrites existing)
pnpm run generate-pdfs-force

# Generate PDFs for specific hymnal
node scripts/generate-pdfs-local.mjs SDAH

# Generate sample PDFs for specific hymnal
node scripts/generate-pdfs-local.mjs SDAH --sample
```

### Advanced Usage
```bash
# Generate only Christ in Song PDFs
node scripts/generate-pdfs-local.mjs "christ-in-song"

# Force regenerate SDAH PDFs
node scripts/generate-pdfs-local.mjs SDAH --force

# Generate sample with force
node scripts/generate-pdfs-local.mjs all --sample --force
```

## Troubleshooting

### Common Issues

1. **"Local development server is not running"**
   - Make sure `pnpm run dev` is running in another terminal
   - Check that `http://localhost:3000` is accessible

2. **"No hymnals found matching filter"**
   - Check the hymnal filter spelling
   - Use `all` to generate from all hymnals
   - Available filters: `SDAH`, `christ-in-song`, `church-hymnal`, etc.

3. **PDFs not appearing in download buttons**
   - Check that PDFs exist in `apps/web/public/pdfs/`
   - Verify `index.json` was created
   - Refresh the webpage to reload PDF availability

4. **Browser/Puppeteer errors**
   - Try running with `--force` to regenerate
   - Check that the hymn pages load correctly in your browser
   - Make sure you have enough disk space

### Debugging

The script includes debug output showing:
- Which hymnals are being processed
- URLs being visited
- PDF file sizes
- Success/error status for each hymn

### Performance Notes

- **Sample mode** (5 PDFs): ~30 seconds
- **Full generation**: Can take 10-30 minutes depending on hymnal size
- **Memory usage**: Puppeteer uses ~100-200MB per browser instance
- **Disk space**: PDFs are typically 50-200KB each

## File Structure

```
apps/web/
├── public/
│   └── pdfs/                    # Generated PDFs
│       ├── index.json          # PDF availability index
│       ├── sdah-1.pdf          # Individual PDF files
│       ├── sdah-2.pdf
│       └── ...
├── scripts/
│   └── generate-pdfs-local.mjs # PDF generation script
└── src/
    ├── lib/
    │   └── pdf-utils.ts        # PDF utility functions
    └── components/
        └── ui/
            └── PDFDownloadButton.tsx  # Smart PDF button
```

## Next Steps

After generating PDFs locally:

1. **Test the download buttons** on various hymn pages
2. **Check mobile behavior** - PDFs should be disabled when not available
3. **Verify desktop fallback** - Should offer to generate PDFs when not available
4. **Test the index system** - New PDFs should be detected automatically

## Production Deployment

In production, PDFs will be generated automatically via GitHub Actions and served from the `/pdfs/` directory. The same detection system will work seamlessly.