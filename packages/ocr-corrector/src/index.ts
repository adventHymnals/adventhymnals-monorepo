/**
 * OCR error detection and correction utilities
 */

export interface OCRCorrector {
  correctText(text: string): string;
  detectErrors(text: string): string[];
}

export interface ErrorPattern {
  pattern: RegExp;
  replacement: string;
  confidence: number;
}

export class DefaultOCRCorrector implements OCRCorrector {
  private patterns: ErrorPattern[] = [];

  constructor(patterns?: ErrorPattern[]) {
    this.patterns = patterns || this.getDefaultPatterns();
  }

  correctText(text: string): string {
    let correctedText = text;
    
    for (const pattern of this.patterns) {
      correctedText = correctedText.replace(pattern.pattern, pattern.replacement);
    }
    
    return correctedText;
  }

  detectErrors(text: string): string[] {
    const errors: string[] = [];
    
    for (const pattern of this.patterns) {
      const matches = text.match(pattern.pattern);
      if (matches) {
        errors.push(...matches);
      }
    }
    
    return errors;
  }

  private getDefaultPatterns(): ErrorPattern[] {
    return [
      // Common OCR errors for hymnal text
      { pattern: /\bl\b/g, replacement: 'I', confidence: 0.8 },
      { pattern: /\b0\b/g, replacement: 'O', confidence: 0.7 },
      { pattern: /rn/g, replacement: 'm', confidence: 0.6 },
    ];
  }
}

export * from '@advent-hymnals/shared';