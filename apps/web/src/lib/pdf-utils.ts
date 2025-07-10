export interface PDFIndex {
  generated: string;
  count: number;
  pdfs: PDFInfo[];
}

export interface PDFInfo {
  filename: string;
  hymnal: string;
  number: number;
  url: string;
  generated: string;
}

/**
 * Check if a PDF exists for a specific hymn
 */
export async function checkPDFAvailability(hymnalSlug: string, hymnNumber: number): Promise<boolean> {
  try {
    // Try direct HEAD request first (fastest)
    const pdfUrl = `/pdfs/${hymnalSlug}-${hymnNumber}.pdf`;
    const response = await fetch(pdfUrl, { 
      method: 'HEAD',
      cache: 'force-cache' // Cache the result
    });
    
    return response.ok;
  } catch {
    return false;
  }
}

/**
 * Get PDF URL for a hymn (if available)
 */
export function getPDFUrl(hymnalSlug: string, hymnNumber: number): string {
  return `/pdfs/${hymnalSlug}-${hymnNumber}.pdf`;
}

/**
 * Load the PDF index to get all available PDFs
 */
export async function loadPDFIndex(): Promise<PDFIndex | null> {
  try {
    const response = await fetch('/pdfs/index.json', {
      cache: 'default',
      next: { revalidate: 3600 } // Cache for 1 hour
    });
    
    if (!response.ok) {
      return null;
    }
    
    return await response.json();
  } catch {
    return null;
  }
}

/**
 * Check if PDF is available using the index (more efficient for bulk checks)
 */
export function isPDFAvailableFromIndex(index: PDFIndex | null, hymnalSlug: string, hymnNumber: number): boolean {
  if (!index) return false;
  
  return index.pdfs.some(pdf => 
    pdf.hymnal === hymnalSlug && pdf.number === hymnNumber
  );
}

/**
 * Get device type for PDF generation strategy
 */
export function getDeviceType(): 'desktop' | 'mobile' {
  if (typeof window === 'undefined') return 'desktop';
  
  // Check for mobile device
  const userAgent = navigator.userAgent.toLowerCase();
  const isMobile = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent);
  
  // Also check viewport width
  const isSmallScreen = window.innerWidth < 768;
  
  return isMobile || isSmallScreen ? 'mobile' : 'desktop';
}

/**
 * Check if browser supports client-side PDF generation
 */
export function supportsPDFGeneration(): boolean {
  if (typeof window === 'undefined') return false;
  
  // Check for PDF.js support
  const hasPDFJS = 'PDFViewerApplication' in window || 'pdfjs' in window;
  
  // Check for modern browser features needed for PDF generation
  const hasModernFeatures = 
    'fetch' in window &&
    'Promise' in window &&
    'URL' in window &&
    'Blob' in window;
  
  return hasModernFeatures && !getDeviceType().includes('mobile');
}

/**
 * Generate filename for PDF download
 */
export function generatePDFFilename(hymnTitle: string, hymnNumber: number, hymnalName: string): string {
  const sanitizedTitle = hymnTitle
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .substring(0, 50); // Limit length
  
  return `${hymnalName}-${hymnNumber}-${sanitizedTitle}.pdf`;
}