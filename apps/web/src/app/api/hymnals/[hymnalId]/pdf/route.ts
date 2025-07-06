import { NextRequest, NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';
import { generateHymnalPDF } from '@/lib/pdf-generator';

export async function GET(
  request: NextRequest,
  { params }: { params: { hymnalId: string } }
) {
  try {
    const { hymnalId } = params;
    
    // Load hymnal references to get hymnal metadata
    const hymnalReferences = await loadHymnalReferences();
    const hymnal = hymnalReferences.hymnals[hymnalId];
    
    if (!hymnal) {
      return NextResponse.json(
        { error: `Hymnal ${hymnalId} not found` },
        { status: 404 }
      );
    }

    // Load all hymns for this hymnal
    const { hymns, totalHymns } = await loadHymnalHymns(hymnalId, 1, hymnal.total_songs || 1000);
    
    if (hymns.length === 0) {
      return NextResponse.json(
        { error: `No hymns found for hymnal ${hymnalId}` },
        { status: 404 }
      );
    }

    // Generate PDF
    console.log(`Generating PDF for ${hymnal.name} with ${hymns.length} hymns...`);
    const pdfBuffer = await generateHymnalPDF(hymnal, hymns);
    
    // Create filename
    const filename = `${hymnal.abbreviation}_${hymnal.year || 'Hymnal'}.pdf`;
    
    // Return PDF as download
    return new NextResponse(pdfBuffer, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'Content-Length': pdfBuffer.byteLength.toString(),
      },
    });
    
  } catch (error) {
    console.error('PDF Generation Error:', error);
    return NextResponse.json(
      { error: 'Failed to generate PDF', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: { hymnalId: string } }
) {
  // Same as GET but allows for future customization options via POST body
  return GET(request, { params });
}