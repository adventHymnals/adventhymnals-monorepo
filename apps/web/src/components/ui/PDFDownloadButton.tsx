'use client';

import { useState, useEffect } from 'react';
import { ArrowDownTrayIcon, DocumentTextIcon, ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import { checkPDFAvailability, getPDFUrl, getDeviceType, supportsPDFGeneration, generatePDFFilename } from '@/lib/pdf-utils';

interface PDFDownloadButtonProps {
  hymnalSlug: string;
  hymnNumber: number;
  hymnTitle: string;
  hymnalName: string;
  className?: string;
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
}

type PDFStatus = 'checking' | 'available' | 'unavailable' | 'generating' | 'error';

export default function PDFDownloadButton({
  hymnalSlug,
  hymnNumber,
  hymnTitle,
  hymnalName,
  className = '',
  variant = 'secondary',
  size = 'md'
}: PDFDownloadButtonProps) {
  const [pdfStatus, setPDFStatus] = useState<PDFStatus>('checking');
  const [error, setError] = useState<string | null>(null);
  const deviceType = getDeviceType();
  const canGeneratePDF = supportsPDFGeneration();

  // Check PDF availability on component mount
  useEffect(() => {
    checkAvailability();
  }, [hymnalSlug, hymnNumber]);

  const checkAvailability = async () => {
    try {
      setPDFStatus('checking');
      const isAvailable = await checkPDFAvailability(hymnalSlug, hymnNumber);
      setPDFStatus(isAvailable ? 'available' : 'unavailable');
      setError(null);
    } catch (err) {
      setPDFStatus('error');
      setError('Failed to check PDF availability');
      console.error('PDF availability check failed:', err);
    }
  };

  const downloadPreGeneratedPDF = () => {
    const pdfUrl = getPDFUrl(hymnalSlug, hymnNumber);
    const filename = generatePDFFilename(hymnTitle, hymnNumber, hymnalSlug);
    
    // Create download link
    const link = document.createElement('a');
    link.href = pdfUrl;
    link.download = filename;
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const generatePDFOnDemand = async () => {
    if (!canGeneratePDF) {
      setError('PDF generation not supported on this device');
      return;
    }

    try {
      setPDFStatus('generating');
      setError(null);

      // Use browser's print API to generate PDF
      const printWindow = window.open('', '_blank');
      if (!printWindow) {
        throw new Error('Popup blocked - please allow popups for PDF generation');
      }

      // Get current page content
      const content = document.documentElement.outerHTML;
      
      // Create a clean version for printing
      const cleanContent = content.replace(
        /<head[^>]*>[\s\S]*?<\/head>/i,
        `<head>
          <title>${hymnTitle} - ${hymnalName} #${hymnNumber}</title>
          <style>
            @media print {
              .no-print, .action-buttons, nav, footer, .sidebar, button, .btn { display: none !important; }
              body { font-size: 14px; line-height: 1.6; }
              .hymn-content { max-width: none; }
              h1, h2, h3 { page-break-after: avoid; }
              .verse, .stanza { page-break-inside: avoid; margin-bottom: 16px; }
            }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
          </style>
        </head>`
      );

      printWindow.document.write(cleanContent);
      printWindow.document.close();

      // Wait for content to load, then trigger print
      setTimeout(() => {
        printWindow.print();
        printWindow.close();
        setPDFStatus('available'); // Reset status
      }, 1000);

    } catch (err) {
      setPDFStatus('error');
      setError(err instanceof Error ? err.message : 'Failed to generate PDF');
      console.error('PDF generation failed:', err);
    }
  };

  const handleDownload = () => {
    if (pdfStatus === 'available') {
      downloadPreGeneratedPDF();
    } else if (pdfStatus === 'unavailable' && canGeneratePDF) {
      generatePDFOnDemand();
    }
  };

  // Button styling based on variant and size
  const baseClasses = 'inline-flex items-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const variantClasses = {
    primary: 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500',
    secondary: 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-gray-500'
  };

  const sizeClasses = {
    sm: 'px-2 py-1 text-xs rounded',
    md: 'px-3 py-2 text-sm rounded-md',
    lg: 'px-4 py-2 text-base rounded-lg'
  };

  const iconSizes = {
    sm: 'h-3 w-3',
    md: 'h-4 w-4',
    lg: 'h-5 w-5'
  };

  const buttonClasses = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${className}`;
  const iconClass = `${iconSizes[size]} mr-1.5`;

  // Determine button state and content
  const getButtonContent = () => {
    switch (pdfStatus) {
      case 'checking':
        return (
          <>
            <div className={`${iconSizes[size]} mr-1.5 animate-spin rounded-full border-2 border-gray-300 border-t-gray-600`} />
            Checking...
          </>
        );
      
      case 'available':
        return (
          <>
            <ArrowDownTrayIcon className={iconClass} />
            Download PDF
          </>
        );
      
      case 'generating':
        return (
          <>
            <div className={`${iconSizes[size]} mr-1.5 animate-spin rounded-full border-2 border-gray-300 border-t-primary-600`} />
            Generating...
          </>
        );
      
      case 'unavailable':
        if (deviceType === 'mobile') {
          return (
            <>
              <ExclamationTriangleIcon className={iconClass} />
              PDF Unavailable
            </>
          );
        } else if (canGeneratePDF) {
          return (
            <>
              <DocumentTextIcon className={iconClass} />
              Generate PDF
            </>
          );
        } else {
          return (
            <>
              <ExclamationTriangleIcon className={iconClass} />
              PDF Unavailable
            </>
          );
        }
      
      case 'error':
        return (
          <>
            <ExclamationTriangleIcon className={iconClass} />
            {deviceType === 'mobile' ? 'Unavailable' : 'Retry'}
          </>
        );
      
      default:
        return (
          <>
            <ArrowDownTrayIcon className={iconClass} />
            PDF
          </>
        );
    }
  };

  const isDisabled = 
    pdfStatus === 'checking' || 
    pdfStatus === 'generating' ||
    (pdfStatus === 'unavailable' && deviceType === 'mobile') ||
    (pdfStatus === 'error' && deviceType === 'mobile');

  const title = (() => {
    switch (pdfStatus) {
      case 'available':
        return 'Download pre-generated PDF';
      case 'unavailable':
        return deviceType === 'mobile' 
          ? 'PDF not available on mobile devices' 
          : 'Generate PDF using browser';
      case 'generating':
        return 'Generating PDF...';
      case 'error':
        return error || 'Error loading PDF';
      default:
        return 'Download PDF';
    }
  })();

  return (
    <div className="relative">
      <button
        onClick={pdfStatus === 'error' && deviceType === 'desktop' ? checkAvailability : handleDownload}
        disabled={isDisabled}
        className={`${buttonClasses} ${isDisabled ? 'opacity-50 cursor-not-allowed' : ''}`}
        title={title}
      >
        {getButtonContent()}
      </button>
      
      {/* Mobile info tooltip */}
      {pdfStatus === 'unavailable' && deviceType === 'mobile' && (
        <div className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 text-xs text-white bg-gray-800 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
          Use desktop for PDF generation
        </div>
      )}
      
      {/* Error message */}
      {error && pdfStatus === 'error' && (
        <div className="absolute top-full left-0 mt-1 text-xs text-red-600 whitespace-nowrap">
          {error}
        </div>
      )}
    </div>
  );
}