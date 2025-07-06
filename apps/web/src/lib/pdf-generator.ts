import jsPDF from 'jspdf';

interface HymnData {
  id: string;
  number: number;
  title: string;
  author?: string;
  composer?: string;
  tune?: string;
  meter?: string;
  language: string;
  verses?: Array<{
    number: number;
    text: string;
  }> | string[];
  chorus?: {
    text: string;
  } | string;
  metadata?: {
    year?: number;
    copyright?: string;
    themes?: string[];
    scripture_references?: string[];
    tune_source?: string;
    translator?: string;
  };
}

interface HymnalData {
  id: string;
  name: string;
  abbreviation: string;
  year?: number;
  total_songs: number;
  language: string;
  compiler?: string;
  publisher?: string;
}

export class HymnalPDFGenerator {
  private pdf: jsPDF;
  private currentPage = 1;
  private pageHeight: number;
  private pageWidth: number;
  private margin = 20;
  private lineHeight = 6;
  private titleFontSize = 16;
  private headerFontSize = 12;
  private bodyFontSize = 10;
  private currentY = 0;

  constructor() {
    this.pdf = new jsPDF();
    this.pageHeight = this.pdf.internal.pageSize.height;
    this.pageWidth = this.pdf.internal.pageSize.width;
  }

  public async generateHymnalPDF(hymnal: HymnalData, hymns: HymnData[]): Promise<Uint8Array> {
    // Generate title page
    this.generateTitlePage(hymnal);
    
    // Generate table of contents
    this.generateTableOfContents(hymns);
    
    // Generate hymn pages
    for (const hymn of hymns) {
      this.generateHymnPage(hymn);
    }

    return this.pdf.output('arraybuffer') as Uint8Array;
  }

  private generateTitlePage(hymnal: HymnalData): void {
    this.pdf.setFontSize(24);
    this.pdf.setFont('helvetica', 'bold');
    
    // Center the title
    const title = hymnal.name;
    const titleWidth = this.pdf.getTextWidth(title);
    const titleX = (this.pageWidth - titleWidth) / 2;
    
    this.currentY = 60;
    this.pdf.text(title, titleX, this.currentY);
    
    // Subtitle with year
    if (hymnal.year) {
      this.pdf.setFontSize(16);
      this.pdf.setFont('helvetica', 'normal');
      const subtitle = `${hymnal.year}`;
      const subtitleWidth = this.pdf.getTextWidth(subtitle);
      const subtitleX = (this.pageWidth - subtitleWidth) / 2;
      this.currentY += 20;
      this.pdf.text(subtitle, subtitleX, this.currentY);
    }

    // Hymnal details
    this.pdf.setFontSize(12);
    this.currentY += 40;
    
    if (hymnal.compiler) {
      const compiler = `Compiled by: ${hymnal.compiler}`;
      const compilerWidth = this.pdf.getTextWidth(compiler);
      const compilerX = (this.pageWidth - compilerWidth) / 2;
      this.pdf.text(compiler, compilerX, this.currentY);
      this.currentY += this.lineHeight * 2;
    }

    if (hymnal.publisher) {
      const publisher = `Published by: ${hymnal.publisher}`;
      const publisherWidth = this.pdf.getTextWidth(publisher);
      const publisherX = (this.pageWidth - publisherWidth) / 2;
      this.pdf.text(publisher, publisherX, this.currentY);
      this.currentY += this.lineHeight * 2;
    }

    const totalSongs = `${hymnal.total_songs} Hymns`;
    const totalWidth = this.pdf.getTextWidth(totalSongs);
    const totalX = (this.pageWidth - totalWidth) / 2;
    this.pdf.text(totalSongs, totalX, this.currentY);

    // Add generation date
    this.currentY += 40;
    this.pdf.setFontSize(10);
    const date = `Generated on ${new Date().toLocaleDateString()}`;
    const dateWidth = this.pdf.getTextWidth(date);
    const dateX = (this.pageWidth - dateWidth) / 2;
    this.pdf.text(date, dateX, this.currentY);

    // Add new page for table of contents
    this.addNewPage();
  }

  private generateTableOfContents(hymns: HymnData[]): void {
    this.pdf.setFontSize(this.titleFontSize);
    this.pdf.setFont('helvetica', 'bold');
    this.currentY = this.margin + 20;
    this.pdf.text('Table of Contents', this.margin, this.currentY);

    this.pdf.setFontSize(this.bodyFontSize);
    this.pdf.setFont('helvetica', 'normal');
    this.currentY += 20;

    let pageNumber = 3; // Start after title page and TOC
    
    for (const hymn of hymns) {
      if (this.currentY > this.pageHeight - 30) {
        this.addNewPage();
        this.currentY = this.margin + 20;
      }

      const line = `${hymn.number}. ${hymn.title}`;
      const dots = this.generateDots(line, pageNumber.toString());
      
      this.pdf.text(line, this.margin, this.currentY);
      this.pdf.text(dots, this.margin + this.pdf.getTextWidth(line), this.currentY);
      this.pdf.text(pageNumber.toString(), this.pageWidth - this.margin - this.pdf.getTextWidth(pageNumber.toString()), this.currentY);
      
      this.currentY += this.lineHeight;
      pageNumber++;
    }

    this.addNewPage();
  }

  private generateDots(leftText: string, rightText: string): string {
    const leftWidth = this.pdf.getTextWidth(leftText);
    const rightWidth = this.pdf.getTextWidth(rightText);
    const availableWidth = this.pageWidth - (2 * this.margin) - leftWidth - rightWidth - 10;
    const dotWidth = this.pdf.getTextWidth('.');
    const numDots = Math.floor(availableWidth / dotWidth);
    return '.'.repeat(Math.max(0, numDots));
  }

  private generateHymnPage(hymn: HymnData): void {
    this.currentY = this.margin + 20;

    // Hymn number and title
    this.pdf.setFontSize(this.titleFontSize);
    this.pdf.setFont('helvetica', 'bold');
    this.pdf.text(`${hymn.number}. ${hymn.title}`, this.margin, this.currentY);
    this.currentY += 15;

    // Metadata line
    this.pdf.setFontSize(this.bodyFontSize);
    this.pdf.setFont('helvetica', 'normal');
    
    const metadata = [];
    if (hymn.author) metadata.push(`Author: ${hymn.author}`);
    if (hymn.composer) metadata.push(`Composer: ${hymn.composer}`);
    if (hymn.tune) metadata.push(`Tune: ${hymn.tune}`);
    if (hymn.meter) metadata.push(`Meter: ${hymn.meter}`);
    
    if (metadata.length > 0) {
      this.pdf.text(metadata.join(' • '), this.margin, this.currentY);
      this.currentY += 10;
    }

    // Verses
    if (hymn.verses) {
      this.currentY += 5;
      
      if (Array.isArray(hymn.verses) && typeof hymn.verses[0] === 'string') {
        // Handle string array format
        hymn.verses.forEach((verse, index) => {
          this.addVerseText(`${index + 1}.`, verse as string);
        });
      } else {
        // Handle object format
        (hymn.verses as Array<{number: number; text: string}>).forEach((verse) => {
          this.addVerseText(`${verse.number}.`, verse.text);
        });
      }
    }

    // Chorus
    if (hymn.chorus) {
      this.currentY += 5;
      const chorusText = typeof hymn.chorus === 'string' ? hymn.chorus : hymn.chorus.text;
      this.addVerseText('Chorus:', chorusText);
    }

    // Additional metadata
    if (hymn.metadata) {
      this.currentY += 10;
      this.pdf.setFontSize(8);
      this.pdf.setFont('helvetica', 'italic');
      
      const metadataLines = [];
      if (hymn.metadata.copyright) metadataLines.push(`Copyright: ${hymn.metadata.copyright}`);
      if (hymn.metadata.year) metadataLines.push(`Year: ${hymn.metadata.year}`);
      if (hymn.metadata.scripture_references?.length) {
        metadataLines.push(`Scripture: ${hymn.metadata.scripture_references.join(', ')}`);
      }
      if (hymn.metadata.themes?.length) {
        metadataLines.push(`Themes: ${hymn.metadata.themes.join(', ')}`);
      }
      
      metadataLines.forEach(line => {
        if (this.currentY > this.pageHeight - 20) {
          this.addNewPage();
          this.currentY = this.margin + 20;
        }
        this.pdf.text(line, this.margin, this.currentY);
        this.currentY += 6;
      });
    }

    this.addNewPage();
  }

  private addVerseText(label: string, text: string): void {
    this.pdf.setFontSize(this.bodyFontSize);
    this.pdf.setFont('helvetica', 'normal');
    
    // Add verse label
    this.pdf.text(label, this.margin, this.currentY);
    
    // Split and wrap verse text
    const maxWidth = this.pageWidth - (2 * this.margin) - 20; // Leave space for verse number
    const lines = this.pdf.splitTextToSize(text, maxWidth);
    
    lines.forEach((line: string, index: number) => {
      if (this.currentY > this.pageHeight - 30) {
        this.addNewPage();
        this.currentY = this.margin + 20;
      }
      
      const x = index === 0 ? this.margin + 15 : this.margin + 15; // Indent all lines consistently
      this.pdf.text(line, x, this.currentY);
      this.currentY += this.lineHeight;
    });
    
    this.currentY += 3; // Space between verses
  }

  private addNewPage(): void {
    this.pdf.addPage();
    this.currentPage++;
    this.currentY = this.margin;
    
    // Add page number
    this.pdf.setFontSize(8);
    this.pdf.setFont('helvetica', 'normal');
    const pageText = this.currentPage.toString();
    const pageX = (this.pageWidth - this.pdf.getTextWidth(pageText)) / 2;
    this.pdf.text(pageText, pageX, this.pageHeight - 10);
  }
}

export async function generateHymnalPDF(hymnal: HymnalData, hymns: HymnData[]): Promise<Uint8Array> {
  const generator = new HymnalPDFGenerator();
  return generator.generateHymnalPDF(hymnal, hymns);
}