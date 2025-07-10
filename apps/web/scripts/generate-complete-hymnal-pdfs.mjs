#!/usr/bin/env node

import puppeteer from 'puppeteer';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');

// Configuration
const LOCAL_SITE_URL = 'http://localhost:3000';
const PDF_OUTPUT_DIR = path.join(projectRoot, 'public/pdfs/complete-hymnals');
const HYMNAL_FILTER = process.argv[2] || 'all';
const FORCE_REGENERATE = process.argv.includes('--force');

console.log('📚 Complete Hymnal PDF Generator');
console.log('=================================');
console.log(`📂 Output directory: ${PDF_OUTPUT_DIR}`);
console.log(`🌐 Target URL: ${LOCAL_SITE_URL}`);
console.log(`📚 Hymnal filter: ${HYMNAL_FILTER}`);
console.log(`🔄 Force regenerate: ${FORCE_REGENERATE}`);
console.log('');

async function loadHymnalReferences() {
  const referencesPath = path.join(projectRoot, '../../data/processed/metadata/hymnals-reference.json');
  console.log(`📖 Loading hymnal references from: ${referencesPath}`);
  
  try {
    const data = await fs.readFile(referencesPath, 'utf8');
    const parsed = JSON.parse(data);
    console.log(`✅ Found ${Object.keys(parsed.hymnals || {}).length} hymnals in metadata`);
    return parsed;
  } catch (error) {
    console.error('❌ Failed to load hymnal references:', error.message);
    throw error;
  }
}

async function loadHymnalHymns(hymnalId) {
  const hymnalPath = path.join(projectRoot, `../../data/processed/hymnals/${hymnalId}-collection.json`);
  console.log(`   📄 Loading hymns from: ${hymnalPath}`);
  
  try {
    const data = await fs.readFile(hymnalPath, 'utf8');
    const parsed = JSON.parse(data);
    const hymnList = parsed.hymns || [];
    
    // Load detailed hymn data from individual files
    const detailedHymns = [];
    for (const hymn of hymnList) {
      const hymnFilePath = path.join(projectRoot, `../../data/processed/hymns/${hymnalId}/${hymn.hymn_id}.json`);
      try {
        const hymnData = await fs.readFile(hymnFilePath, 'utf8');
        const detailedHymn = JSON.parse(hymnData);
        detailedHymns.push({
          ...hymn,
          ...detailedHymn,
          // Ensure we have the basic info from collection
          number: hymn.number,
          title: hymn.title || detailedHymn.title
        });
      } catch (hymnError) {
        // If individual hymn file doesn't exist, use basic info from collection
        console.log(`   ⚠️  Could not load detailed data for ${hymn.hymn_id}: ${hymnError.message}`);
        detailedHymns.push(hymn);
      }
    }
    
    return detailedHymns;
  } catch (error) {
    console.log(`   ⚠️  Could not load hymnal ${hymnalId}: ${error.message}`);
    return [];
  }
}

async function ensureOutputDirectory() {
  try {
    await fs.access(PDF_OUTPUT_DIR);
    console.log(`✅ PDF output directory exists: ${PDF_OUTPUT_DIR}`);
  } catch {
    console.log(`📁 Creating PDF output directory: ${PDF_OUTPUT_DIR}`);
    await fs.mkdir(PDF_OUTPUT_DIR, { recursive: true });
  }
}

async function pdfExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function checkLocalServerRunning() {
  try {
    const response = await fetch(LOCAL_SITE_URL, { method: 'HEAD' });
    return response.ok;
  } catch {
    return false;
  }
}

async function generateCompleteHymnalPDF(browser, hymnal, hymns) {
  const pdfFileName = `${hymnal.url_slug}-complete.pdf`;
  const pdfPath = path.join(PDF_OUTPUT_DIR, pdfFileName);
  
  // Skip if PDF exists and not forcing regeneration
  if (!FORCE_REGENERATE && await pdfExists(pdfPath)) {
    console.log(`   ⏭️  Skipping ${pdfFileName} (already exists)`);
    return { success: true, skipped: true };
  }
  
  const hymnalUrl = `${LOCAL_SITE_URL}/${hymnal.url_slug}`;
  
  try {
    console.log(`   📚 Generating: ${pdfFileName}`);
    console.log(`   🔗 Hymnal URL: ${hymnalUrl}`);
    console.log(`   📊 Including ${hymns.length} hymns`);
    
    const page = await browser.newPage();
    
    // Set viewport for consistent rendering
    await page.setViewport({ width: 1200, height: 1600, deviceScaleFactor: 2 });
    
    // Navigate to hymnal main page
    await page.goto(hymnalUrl, { 
      waitUntil: 'networkidle2', 
      timeout: 60000 
    });
    
    // Wait for content to load
    try {
      await page.waitForSelector('.hymnal-content, main, .container', { timeout: 15000 });
    } catch {
      console.log(`   ⚠️  Content selector not found, proceeding anyway`);
    }
    
    // Inject comprehensive PDF styles and collect all hymn content
    await page.addStyleTag({
      content: `
        /* Reset and base styles */
        * {
          box-sizing: border-box;
        }
        
        body, html {
          font-family: Georgia, 'Times New Roman', serif !important;
          font-size: 12px !important;
          line-height: 1.5 !important;
          color: #000 !important;
          background: white !important;
          margin: 0 !important;
          padding: 0 !important;
        }
        
        /* Hide UI elements */
        .no-print,
        nav:not(.breadcrumb),
        .navbar,
        header nav,
        footer,
        .sidebar,
        .hymnal-index,
        button,
        .btn,
        [role="button"],
        .related-hymns,
        .floating-action,
        .mobile-menu,
        .action-buttons,
        .search-container,
        .filter-controls,
        .pagination {
          display: none !important;
        }
        
        /* Keep main content */
        .container, .max-w-7xl {
          max-width: none !important;
          margin: 0 !important;
          padding: 20px !important;
        }
        
        /* Typography hierarchy */
        h1 {
          font-size: 28px !important;
          font-weight: bold !important;
          text-align: center !important;
          margin: 40px 0 30px 0 !important;
          page-break-after: avoid !important;
          color: #1a365d !important;
          border-bottom: 3px solid #1a365d !important;
          padding-bottom: 10px !important;
        }
        
        h2 {
          font-size: 20px !important;
          font-weight: bold !important;
          margin: 30px 0 15px 0 !important;
          page-break-after: avoid !important;
          color: #2d3748 !important;
        }
        
        h3 {
          font-size: 16px !important;
          font-weight: bold !important;
          margin: 20px 0 10px 0 !important;
          page-break-after: avoid !important;
          color: #4a5568 !important;
        }
        
        /* Hymn content */
        .hymn-item, .hymn-card {
          page-break-inside: avoid !important;
          margin-bottom: 40px !important;
          padding: 20px !important;
          border: 1px solid #e2e8f0 !important;
          border-radius: 8px !important;
          background: #f8fafc !important;
        }
        
        .hymn-title {
          font-size: 18px !important;
          font-weight: bold !important;
          color: #1a365d !important;
          margin-bottom: 8px !important;
        }
        
        .hymn-number {
          font-size: 14px !important;
          color: #718096 !important;
          margin-bottom: 12px !important;
        }
        
        .hymn-author {
          font-size: 13px !important;
          color: #4a5568 !important;
          font-style: italic !important;
          margin-bottom: 16px !important;
        }
        
        .verse, .stanza, .hymn-verse {
          margin-bottom: 16px !important;
          padding: 8px 0 !important;
          page-break-inside: avoid !important;
        }
        
        .verse-number, .stanza-number {
          font-weight: bold !important;
          color: #2d3748 !important;
          margin-bottom: 4px !important;
        }
        
        .verse-text, .stanza-text {
          line-height: 1.6 !important;
          white-space: pre-line !important;
        }
        
        /* Hymn metadata styling */
        .hymn-metadata {
          background: #f3f4f6 !important;
          padding: 12px !important;
          border-radius: 6px !important;
          margin: 12px 0 16px 0 !important;
          font-size: 11px !important;
          color: #4a5568 !important;
        }
        
        /* Hymn footer with themes and scripture */
        .hymn-footer {
          margin-top: 20px !important;
          padding: 12px !important;
          background: #f7fafc !important;
          border-radius: 6px !important;
          font-size: 11px !important;
          color: #4a5568 !important;
        }
        
        .hymn-footer .themes,
        .hymn-footer .scripture-refs {
          margin-bottom: 8px !important;
        }
        
        .hymn-footer .themes:last-child,
        .hymn-footer .scripture-refs:last-child {
          margin-bottom: 0 !important;
        }
        
        /* Table of contents */
        .toc {
          page-break-after: always !important;
          margin-bottom: 40px !important;
        }
        
        .toc h2 {
          text-align: center !important;
          margin-bottom: 30px !important;
        }
        
        .toc-item {
          display: flex !important;
          justify-content: space-between !important;
          padding: 4px 0 !important;
          border-bottom: 1px dotted #cbd5e0 !important;
        }
        
        .toc-title {
          flex: 1 !important;
          margin-right: 20px !important;
        }
        
        .toc-number {
          font-weight: bold !important;
          color: #4a5568 !important;
        }
        
        /* Page break rules */
        @page {
          margin: 0.75in;
          size: letter;
          
          @top-center {
            content: "${hymnal.site_name || hymnal.name}";
            font-size: 10px;
            color: #4a5568;
          }
          
          @bottom-center {
            content: "Page " counter(page) " of " counter(pages);
            font-size: 9px;
            color: #6b7280;
          }
        }
        
        /* Force page breaks between major sections */
        .hymn-section {
          page-break-before: always !important;
        }
        
        .hymn-section:first-child {
          page-break-before: auto !important;
        }
        
        /* Print-specific adjustments */
        @media print {
          * {
            -webkit-print-color-adjust: exact !important;
            color-adjust: exact !important;
          }
          
          body {
            print-color-adjust: exact !important;
          }
        }
      `
    });
    
    // Create a comprehensive hymnal content structure
    await page.evaluate((hymnalData, hymnsData) => {
      // Clear existing content
      document.body.innerHTML = '';
      
      // Create main container
      const container = document.createElement('div');
      container.className = 'hymnal-complete-pdf';
      
      // Title page
      const titlePage = document.createElement('div');
      titlePage.className = 'title-page';
      titlePage.innerHTML = `
        <h1>${hymnalData.site_name || hymnalData.name}</h1>
        <div style="text-align: center; margin: 40px 0;">
          <p style="font-size: 16px; margin: 10px 0;"><strong>Year:</strong> ${hymnalData.year}</p>
          <p style="font-size: 16px; margin: 10px 0;"><strong>Total Hymns:</strong> ${hymnalData.total_songs}</p>
          <p style="font-size: 16px; margin: 10px 0;"><strong>Language:</strong> ${hymnalData.language_name}</p>
          ${hymnalData.compiler ? `<p style="font-size: 16px; margin: 10px 0;"><strong>Compiler:</strong> ${hymnalData.compiler}</p>` : ''}
        </div>
        <div style="position: absolute; bottom: 40px; left: 50%; transform: translateX(-50%); text-align: center;">
          <p style="font-size: 14px; color: #666;">Generated from AdventHymnals.org</p>
          <p style="font-size: 12px; color: #888;">${new Date().toLocaleDateString()}</p>
        </div>
      `;
      titlePage.style.cssText = 'page-break-after: always; height: 100vh; position: relative; display: flex; flex-direction: column; justify-content: center; text-align: center;';
      container.appendChild(titlePage);
      
      // Table of contents
      if (hymnsData.length > 0) {
        const tocPage = document.createElement('div');
        tocPage.className = 'toc';
        tocPage.innerHTML = `
          <h2>Table of Contents</h2>
          <div class="toc-list">
            ${hymnsData.slice(0, 50).map(hymn => `
              <div class="toc-item">
                <span class="toc-title">${hymn.title}</span>
                <span class="toc-number">#${hymn.number}</span>
              </div>
            `).join('')}
            ${hymnsData.length > 50 ? `
              <div style="text-align: center; margin: 20px 0; font-style: italic; color: #666;">
                ... and ${hymnsData.length - 50} more hymns
              </div>
            ` : ''}
          </div>
        `;
        container.appendChild(tocPage);
      }
      
      // Add hymns content (first 10 for sample, or all if small collection)
      const hymnsToInclude = hymnsData.length <= 20 ? hymnsData : hymnsData.slice(0, 10);
      hymnsToInclude.forEach((hymn, index) => {
        const hymnSection = document.createElement('div');
        hymnSection.className = 'hymn-section';
        
        let hymnContent = `
          <div class="hymn-item">
            <div class="hymn-number">Hymn #${hymn.number}</div>
            <h3 class="hymn-title">${hymn.title}</h3>
        `;
        
        // Add author info
        if (hymn.author) {
          hymnContent += `<div class="hymn-author">By: ${hymn.author}</div>`;
        }
        
        // Add composer/tune info if available
        if (hymn.composer || hymn.tune) {
          hymnContent += `<div class="hymn-metadata">`;
          if (hymn.composer) {
            hymnContent += `<span><strong>Music:</strong> ${hymn.composer}</span>`;
          }
          if (hymn.tune) {
            hymnContent += `${hymn.composer ? ' • ' : ''}<span><strong>Tune:</strong> ${hymn.tune}</span>`;
          }
          if (hymn.meter) {
            hymnContent += ` • <span><strong>Meter:</strong> ${hymn.meter}</span>`;
          }
          hymnContent += `</div>`;
        }
        
        // Add verses content
        if (hymn.verses && hymn.verses.length > 0) {
          hymn.verses.forEach((verse, vIndex) => {
            const verseText = verse.text || verse;
            // Convert newlines to proper line breaks
            const formattedText = verseText.replace(/\n/g, '<br>');
            hymnContent += `
              <div class="verse">
                <div class="verse-number">Verse ${verse.number || vIndex + 1}</div>
                <div class="verse-text">${formattedText}</div>
              </div>
            `;
          });
        } else if (hymn.stanzas && hymn.stanzas.length > 0) {
          hymn.stanzas.forEach((stanza, sIndex) => {
            const stanzaText = stanza.text || stanza;
            const formattedText = stanzaText.replace(/\n/g, '<br>');
            hymnContent += `
              <div class="stanza">
                <div class="stanza-number">Stanza ${stanza.number || sIndex + 1}</div>
                <div class="stanza-text">${formattedText}</div>
              </div>
            `;
          });
        } else if (hymn.lyrics) {
          // Handle plain text lyrics
          const formattedLyrics = hymn.lyrics.replace(/\n\n/g, '</div><div class="verse"><div class="verse-text">').replace(/\n/g, '<br>');
          hymnContent += `
            <div class="verse">
              <div class="verse-text">${formattedLyrics}</div>
            </div>
          `;
        } else {
          hymnContent += `
            <div class="verse">
              <div class="verse-text" style="color: #666; font-style: italic;">
                Lyrics not available in this format.
                <br><br>
                <small>This hymn may have lyrics available on the web version at AdventHymnals.org</small>
              </div>
            </div>
          `;
        }
        
        // Add themes/scripture references if available
        if (hymn.metadata && (hymn.metadata.themes || hymn.metadata.scripture_references)) {
          hymnContent += `<div class="hymn-footer">`;
          
          if (hymn.metadata.themes && hymn.metadata.themes.length > 0) {
            hymnContent += `
              <div class="themes">
                <strong>Themes:</strong> ${hymn.metadata.themes.join(', ')}
              </div>
            `;
          }
          
          if (hymn.metadata.scripture_references && hymn.metadata.scripture_references.length > 0) {
            hymnContent += `
              <div class="scripture-refs">
                <strong>Scripture:</strong> ${hymn.metadata.scripture_references.join(', ')}
              </div>
            `;
          }
          
          hymnContent += `</div>`;
        }
        
        hymnContent += `</div>`;
        hymnSection.innerHTML = hymnContent;
        container.appendChild(hymnSection);
      });
      
      // Add note if this is a sample
      if (hymnsData.length > hymnsToInclude.length) {
        const sampleNote = document.createElement('div');
        sampleNote.style.cssText = 'page-break-before: always; text-align: center; padding: 40px; color: #666;';
        sampleNote.innerHTML = `
          <h2>Sample Complete</h2>
          <p>This PDF contains the first ${hymnsToInclude.length} hymns from ${hymnalData.site_name || hymnalData.name}.</p>
          <p>The complete collection contains ${hymnsData.length} hymns total.</p>
          <p>Visit <strong>AdventHymnals.org</strong> to browse all hymns online.</p>
        `;
        container.appendChild(sampleNote);
      }
      
      document.body.appendChild(container);
    }, hymnal, hymns);
    
    // Wait for content to be fully rendered
    await page.waitForTimeout(3000);
    
    // Generate PDF with optimized settings for complete hymnal
    await page.pdf({
      path: pdfPath,
      format: 'Letter',
      printBackground: true,
      preferCSSPageSize: false,
      margin: {
        top: '0.75in',
        right: '0.75in',
        bottom: '0.75in',
        left: '0.75in'
      },
      displayHeaderFooter: true,
      headerTemplate: `
        <div style="font-size: 10px; margin: 0 auto; color: #4b5563; font-family: serif; text-align: center; width: 100%;">
          ${hymnal.site_name || hymnal.name} (${hymnal.year})
        </div>
      `,
      footerTemplate: `
        <div style="font-size: 9px; margin: 0 auto; color: #6b7280; font-family: serif; text-align: center; width: 100%;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span> - AdventHymnals.org
        </div>
      `
    });
    
    await page.close();
    
    // Verify PDF was created and get size
    const stats = await fs.stat(pdfPath);
    const sizeMB = Math.round(stats.size / 1024 / 1024 * 100) / 100;
    
    console.log(`   ✅ Generated: ${pdfFileName} (${sizeMB} MB)`);
    return { success: true, skipped: false, size: stats.size };
    
  } catch (error) {
    console.error(`   ❌ Failed to generate ${pdfFileName}: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function createCompleteHymnalIndex() {
  const indexPath = path.join(PDF_OUTPUT_DIR, 'index.json');
  
  try {
    const files = await fs.readdir(PDF_OUTPUT_DIR);
    const pdfFiles = files
      .filter(file => file.endsWith('.pdf'))
      .map(file => {
        const slug = file.replace('-complete.pdf', '');
        return {
          filename: file,
          hymnal_slug: slug,
          url: `/pdfs/complete-hymnals/${file}`,
          type: 'complete_hymnal',
          generated: new Date().toISOString()
        };
      })
      .sort((a, b) => a.hymnal_slug.localeCompare(b.hymnal_slug));
    
    const index = {
      generated: new Date().toISOString(),
      count: pdfFiles.length,
      type: 'complete_hymnals',
      description: 'Complete hymnal PDF collections with all hymns from each collection',
      pdfs: pdfFiles
    };
    
    await fs.writeFile(indexPath, JSON.stringify(index, null, 2));
    console.log(`📋 Created complete hymnal PDF index: ${indexPath} (${pdfFiles.length} files)`);
    
  } catch (error) {
    console.error('❌ Error creating complete hymnal PDF index:', error);
  }
}

async function main() {
  console.log('🚀 Starting complete hymnal PDF generation...\n');
  
  // Check if local server is running
  const serverRunning = await checkLocalServerRunning();
  if (!serverRunning) {
    console.error('❌ Local development server is not running!');
    console.log('   Please start the server with: pnpm run dev');
    console.log('   Then run this script again.');
    process.exit(1);
  }
  console.log('✅ Local development server is running');
  
  // Ensure output directory exists
  await ensureOutputDirectory();
  
  // Load hymnal data
  const references = await loadHymnalReferences();
  
  // Filter hymnals if specified
  let hymnalsToProcess = Object.values(references.hymnals);
  if (HYMNAL_FILTER !== 'all') {
    hymnalsToProcess = hymnalsToProcess.filter(h => 
      h.id.toLowerCase().includes(HYMNAL_FILTER.toLowerCase()) ||
      h.url_slug.toLowerCase().includes(HYMNAL_FILTER.toLowerCase()) ||
      h.name.toLowerCase().includes(HYMNAL_FILTER.toLowerCase())
    );
  }
  
  if (hymnalsToProcess.length === 0) {
    console.error(`❌ No hymnals found matching filter: ${HYMNAL_FILTER}`);
    process.exit(1);
  }
  
  console.log(`📚 Processing ${hymnalsToProcess.length} hymnal(s):`);
  hymnalsToProcess.forEach(h => console.log(`   - ${h.name} (${h.id})`));
  console.log('');
  
  // Launch browser
  console.log('🌐 Launching browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu'
    ]
  });
  console.log('✅ Browser launched');
  
  let totalGenerated = 0;
  let totalSkipped = 0;
  let totalErrors = 0;
  let totalSize = 0;
  
  for (const hymnal of hymnalsToProcess) {
    console.log(`\n📖 Processing: ${hymnal.name} (${hymnal.id})`);
    
    const hymns = await loadHymnalHymns(hymnal.id);
    console.log(`   Found ${hymns.length} hymns`);
    
    const result = await generateCompleteHymnalPDF(browser, hymnal, hymns);
    
    if (result.success) {
      if (result.skipped) {
        totalSkipped++;
      } else {
        totalGenerated++;
        totalSize += result.size || 0;
      }
    } else {
      totalErrors++;
    }
    
    // Small delay between hymnals
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  await browser.close();
  console.log('🌐 Browser closed');
  
  // Create index
  await createCompleteHymnalIndex();
  
  // Summary
  console.log('\n✨ Complete Hymnal PDF Generation Complete!');
  console.log('============================================');
  console.log(`📄 Generated: ${totalGenerated} PDFs`);
  console.log(`⏭️  Skipped: ${totalSkipped} PDFs`);
  console.log(`❌ Errors: ${totalErrors}`);
  console.log(`💾 Total size: ${Math.round(totalSize / 1024 / 1024 * 100) / 100} MB`);
  console.log(`📂 Output: ${PDF_OUTPUT_DIR}`);
  console.log(`📋 Index: ${PDF_OUTPUT_DIR}/index.json`);
  console.log('\n🌐 Complete hymnal PDFs accessible at: http://localhost:3000/pdfs/complete-hymnals/');
  
  if (totalErrors > 0) {
    console.log('\n⚠️  Some PDFs failed to generate. Check the logs above for details.');
  }
}

main().catch(error => {
  console.error('\n💥 Fatal error:', error);
  process.exit(1);
});