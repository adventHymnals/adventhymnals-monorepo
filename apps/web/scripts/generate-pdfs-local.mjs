#!/usr/bin/env node

import puppeteer from 'puppeteer';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');

// Configuration
const LOCAL_SITE_URL = 'http://localhost:3000';
const PDF_OUTPUT_DIR = path.join(projectRoot, 'public/pdfs');
const HYMNAL_FILTER = process.argv[2] || 'all'; // Can pass hymnal filter as argument
const FORCE_REGENERATE = process.argv.includes('--force');
const MAX_HYMNS = process.argv.includes('--sample') ? 5 : Infinity; // For testing

console.log('🎵 Local PDF Generator for Advent Hymnals');
console.log('=====================================');
console.log(`📂 Output directory: ${PDF_OUTPUT_DIR}`);
console.log(`🌐 Target URL: ${LOCAL_SITE_URL}`);
console.log(`📚 Hymnal filter: ${HYMNAL_FILTER}`);
console.log(`🔄 Force regenerate: ${FORCE_REGENERATE}`);
console.log(`📊 Max hymns: ${MAX_HYMNS === Infinity ? 'All' : MAX_HYMNS}`);
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
    return parsed.hymns || [];
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

async function generateHymnPDF(browser, hymnalSlug, hymn, hymnalName) {
  const slug = `hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`;
  const pdfFileName = `${hymnalSlug}-${hymn.number}.pdf`;
  const pdfPath = path.join(PDF_OUTPUT_DIR, pdfFileName);
  
  // Skip if PDF exists and not forcing regeneration
  if (!FORCE_REGENERATE && await pdfExists(pdfPath)) {
    console.log(`   ⏭️  Skipping ${pdfFileName} (already exists)`);
    return { success: true, skipped: true };
  }
  
  const url = `${LOCAL_SITE_URL}/${hymnalSlug}/${slug}`;
  
  try {
    console.log(`   📄 Generating: ${pdfFileName}`);
    console.log(`   🔗 URL: ${url}`);
    
    const page = await browser.newPage();
    
    // Set viewport for consistent rendering
    await page.setViewport({ width: 1200, height: 1600, deviceScaleFactor: 2 });
    
    // Navigate to hymn page with longer timeout for local development
    await page.goto(url, { 
      waitUntil: 'networkidle2', 
      timeout: 60000 // Longer timeout for local dev
    });
    
    // Wait for content to load - try multiple selectors
    try {
      await page.waitForSelector('.hymn-content, [data-hymn-content], main, article', { 
        timeout: 15000 
      });
    } catch {
      console.log(`   ⚠️  Content selector not found, proceeding anyway`);
    }
    
    // Wait for any lazy-loaded content
    await page.waitForTimeout(2000);
    
    // Hide navigation and action buttons for cleaner PDF
    await page.addStyleTag({
      content: `
        /* Hide UI elements */
        .action-buttons,
        .no-print,
        nav:not(.breadcrumb),
        .navbar,
        header nav,
        footer,
        .sidebar,
        .hymnal-index,
        button:not(.print-keep),
        .btn,
        [role="button"],
        .related-hymns,
        .floating-action,
        .mobile-menu {
          display: none !important;
        }
        
        /* Keep hymn header but clean it up */
        .hymn-header {
          padding: 20px !important;
          margin-bottom: 20px !important;
          background: linear-gradient(135deg, #1e40af, #3b82f6) !important;
          border-radius: 0 !important;
        }
        
        /* Typography for PDF */
        body, html {
          font-size: 13px !important;
          line-height: 1.6 !important;
          font-family: Georgia, 'Times New Roman', serif !important;
        }
        
        h1, h2, h3 {
          page-break-after: avoid !important;
          color: #1f2937 !important;
        }
        
        h1 {
          font-size: 24px !important;
          margin-bottom: 16px !important;
        }
        
        h2 {
          font-size: 18px !important;
          margin-bottom: 12px !important;
        }
        
        /* Hymn content formatting */
        .verse, .stanza, .hymn-verse {
          page-break-inside: avoid !important;
          margin-bottom: 20px !important;
          padding: 12px !important;
          border-left: 3px solid #e5e7eb !important;
          background: #f9fafb !important;
        }
        
        .verse-number, .stanza-number {
          font-weight: bold !important;
          color: #374151 !important;
          margin-bottom: 8px !important;
        }
        
        /* Metadata styling */
        .hymn-metadata, .quick-info {
          background: #f3f4f6 !important;
          padding: 12px !important;
          border-radius: 6px !important;
          margin: 16px 0 !important;
          font-size: 12px !important;
        }
        
        /* Responsive layout for PDF */
        .container, .max-w-7xl {
          max-width: none !important;
          margin: 0 !important;
          padding: 0 20px !important;
        }
        
        .grid {
          display: block !important;
        }
        
        .lg\\:col-span-2, .lg\\:col-span-1 {
          width: 100% !important;
        }
        
        /* Page break rules */
        @page {
          margin: 0.75in;
          size: letter;
        }
        
        /* Print color accuracy */
        @media print {
          * {
            -webkit-print-color-adjust: exact !important;
            color-adjust: exact !important;
          }
        }
        
        /* Debug: highlight content areas */
        ${process.env.NODE_ENV === 'development' ? `
          .hymn-content { border: 2px solid red !important; }
          .verse { border-left-color: blue !important; }
        ` : ''}
      `
    });
    
    // Wait for styles to apply
    await page.waitForTimeout(1500);
    
    // Generate PDF with optimized settings
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
        <div style="font-size: 10px; margin: 0 auto; color: #4b5563; font-family: sans-serif;">
          <strong>${hymn.title}</strong> - ${hymnalName} #${hymn.number}
        </div>
      `,
      footerTemplate: `
        <div style="font-size: 9px; margin: 0 auto; color: #6b7280; font-family: sans-serif;">
          <span class="pageNumber"></span> / <span class="totalPages"></span> - AdventHymnals.org
        </div>
      `
    });
    
    await page.close();
    
    // Verify PDF was created and get size
    const stats = await fs.stat(pdfPath);
    const sizeKB = Math.round(stats.size / 1024);
    
    console.log(`   ✅ Generated: ${pdfFileName} (${sizeKB} KB)`);
    return { success: true, skipped: false, size: stats.size };
    
  } catch (error) {
    console.error(`   ❌ Failed to generate ${pdfFileName}: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function createPDFIndex() {
  const indexPath = path.join(PDF_OUTPUT_DIR, 'index.json');
  
  try {
    const files = await fs.readdir(PDF_OUTPUT_DIR);
    const pdfFiles = files
      .filter(file => file.endsWith('.pdf'))
      .map(file => {
        const [hymnal, number] = file.replace('.pdf', '').split('-');
        return {
          filename: file,
          hymnal: hymnal,
          number: parseInt(number),
          url: `/pdfs/${file}`,
          generated: new Date().toISOString()
        };
      })
      .sort((a, b) => a.hymnal.localeCompare(b.hymnal) || a.number - b.number);
    
    const index = {
      generated: new Date().toISOString(),
      count: pdfFiles.length,
      pdfs: pdfFiles
    };
    
    await fs.writeFile(indexPath, JSON.stringify(index, null, 2));
    console.log(`📋 Created PDF index: ${indexPath} (${pdfFiles.length} files)`);
    
  } catch (error) {
    console.error('❌ Error creating PDF index:', error);
  }
}

async function main() {
  console.log('🚀 Starting local PDF generation...\n');
  
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
    const hymnsToProcess = hymns.slice(0, Math.min(hymns.length, MAX_HYMNS));
    
    console.log(`   Found ${hymns.length} hymns, processing ${hymnsToProcess.length}`);
    
    for (const hymn of hymnsToProcess) {
      const result = await generateHymnPDF(browser, hymnal.url_slug, hymn, hymnal.name);
      
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
      
      // Small delay to prevent overwhelming the server
      await new Promise(resolve => setTimeout(resolve, 200));
    }
  }
  
  await browser.close();
  console.log('🌐 Browser closed');
  
  // Create index
  await createPDFIndex();
  
  // Summary
  console.log('\n✨ PDF Generation Complete!');
  console.log('============================');
  console.log(`📄 Generated: ${totalGenerated} PDFs`);
  console.log(`⏭️  Skipped: ${totalSkipped} PDFs`);
  console.log(`❌ Errors: ${totalErrors}`);
  console.log(`💾 Total size: ${Math.round(totalSize / 1024 / 1024 * 100) / 100} MB`);
  console.log(`📂 Output: ${PDF_OUTPUT_DIR}`);
  console.log(`📋 Index: ${PDF_OUTPUT_DIR}/index.json`);
  console.log('\n🌐 PDFs accessible at: http://localhost:3000/pdfs/');
  
  if (totalErrors > 0) {
    console.log('\n⚠️  Some PDFs failed to generate. Check the logs above for details.');
  }
}

main().catch(error => {
  console.error('\n💥 Fatal error:', error);
  process.exit(1);
});