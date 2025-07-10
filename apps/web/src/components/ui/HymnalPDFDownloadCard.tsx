'use client';

import { useState, useEffect } from 'react';
import { DocumentArrowDownIcon, ExclamationTriangleIcon } from '@heroicons/react/24/outline';

interface HymnalPDFDownloadCardProps {
  hymnal: {
    id: string;
    name: string;
    site_name?: string;
    year: number;
    total_songs: number;
    language_name: string;
    url_slug: string;
  };
}

type AvailabilityStatus = 'checking' | 'available' | 'partial' | 'unavailable';

interface PDFAvailability {
  status: AvailabilityStatus;
  availableCount: number;
  totalCount: number;
  samplePDFs: string[];
}

export default function HymnalPDFDownloadCard({ hymnal }: HymnalPDFDownloadCardProps) {
  const [availability, setAvailability] = useState<PDFAvailability>({
    status: 'checking',
    availableCount: 0,
    totalCount: hymnal.total_songs || 0,
    samplePDFs: []
  });

  useEffect(() => {
    checkHymnalPDFAvailability();
  }, [hymnal.id]);

  const checkHymnalPDFAvailability = async () => {
    try {
      setAvailability(prev => ({ ...prev, status: 'checking' }));

      // Check if complete hymnal PDF index exists first
      const indexResponse = await fetch('/pdfs/complete-hymnals/index.json', { 
        method: 'HEAD',
        cache: 'no-cache'
      });

      if (!indexResponse.ok) {
        setAvailability(prev => ({ 
          ...prev, 
          status: 'unavailable',
          availableCount: 0,
          samplePDFs: []
        }));
        return;
      }

      // Load complete hymnal PDF index
      const indexData = await fetch('/pdfs/complete-hymnals/index.json', { cache: 'no-cache' });
      const index = await indexData.json();
      
      // Check if this hymnal has a complete PDF
      const hymnalPDF = index.pdfs?.find((pdf: any) => 
        pdf.hymnal_slug.toLowerCase() === hymnal.url_slug.toLowerCase() ||
        pdf.hymnal_slug.toLowerCase() === hymnal.id.toLowerCase()
      );

      if (hymnalPDF) {
        setAvailability({
          status: 'available',
          availableCount: 1,
          totalCount: 1,
          samplePDFs: [hymnalPDF.filename]
        });
      } else {
        setAvailability({
          status: 'unavailable',
          availableCount: 0,
          totalCount: 1,
          samplePDFs: []
        });
      }

    } catch (error) {
      console.error('Error checking hymnal PDF availability:', error);
      setAvailability(prev => ({ 
        ...prev, 
        status: 'unavailable',
        availableCount: 0,
        samplePDFs: []
      }));
    }
  };

  const downloadCompleteHymnalPDF = () => {
    if (availability.status === 'unavailable' || availability.samplePDFs.length === 0) return;

    // Direct download of complete hymnal PDF
    const pdfUrl = `/pdfs/complete-hymnals/${availability.samplePDFs[0]}`;
    const link = document.createElement('a');
    link.href = pdfUrl;
    link.download = availability.samplePDFs[0];
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const getStatusInfo = () => {
    switch (availability.status) {
      case 'checking':
        return {
          text: 'Checking availability...',
          color: 'text-gray-600',
          bgColor: 'bg-gray-100',
          icon: null
        };
      
      case 'available':
        return {
          text: 'Complete Hymnal PDF Available',
          color: 'text-green-700',
          bgColor: 'bg-green-100',
          icon: DocumentArrowDownIcon
        };
      
      case 'partial':
        return {
          text: 'Complete Hymnal PDF Available',
          color: 'text-green-700',
          bgColor: 'bg-green-100',
          icon: DocumentArrowDownIcon
        };
      
      case 'unavailable':
        return {
          text: 'Coming Soon',
          color: 'text-gray-600',
          bgColor: 'bg-gray-100',
          icon: ExclamationTriangleIcon
        };
    }
  };

  const statusInfo = getStatusInfo();
  const canDownload = availability.status === 'available' || availability.status === 'partial';

  return (
    <div className="relative overflow-hidden rounded-xl bg-white p-6 shadow-sm hover:shadow-lg transition-shadow border border-gray-200">
      <div className="flex items-start justify-between">
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold text-gray-900 truncate">
            {hymnal.site_name || hymnal.name}
          </h3>
          <p className="text-sm text-gray-600 mt-1">
            {hymnal.year} • {hymnal.total_songs} hymns • {hymnal.language_name}
          </p>
          <p className="text-xs text-gray-500 mt-2">
            {availability.status === 'available' 
              ? 'Complete hymnal with all hymns, lyrics, music notation, and metadata'
              : 'Complete hymnal PDF with lyrics, music notation, and metadata'
            }
          </p>

          {/* PDF File info */}
          {availability.samplePDFs.length > 0 && availability.status === 'available' && (
            <div className="mt-3">
              <p className="text-xs text-gray-500 mb-1">Complete hymnal PDF:</p>
              <div className="flex flex-wrap gap-1">
                <span className="inline-flex items-center px-2 py-1 rounded text-xs bg-blue-50 text-blue-700">
                  {hymnal.total_songs} hymns included
                </span>
                <span className="inline-flex items-center px-2 py-1 rounded text-xs bg-green-50 text-green-700">
                  Ready to download
                </span>
              </div>
            </div>
          )}
        </div>
        <div className="ml-4 flex-shrink-0">
          <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
            <DocumentArrowDownIcon className="h-5 w-5 text-primary-600" />
          </div>
        </div>
      </div>
      
      <div className="mt-4 flex items-center justify-between">
        <span className="text-xs text-gray-500">PDF Format</span>
        <div className="flex space-x-2">
          <div className={`inline-flex items-center rounded-md px-3 py-1 text-xs font-medium ${statusInfo.bgColor} ${statusInfo.color}`}>
            {statusInfo.icon && <statusInfo.icon className="h-3 w-3 mr-1" />}
            {availability.status === 'checking' && (
              <div className="w-3 h-3 mr-1 animate-spin rounded-full border border-gray-400 border-t-transparent" />
            )}
            {statusInfo.text}
          </div>
          
          {canDownload && (
            <button
              onClick={downloadCompleteHymnalPDF}
              className="inline-flex items-center rounded-md bg-primary-600 px-3 py-1 text-xs font-medium text-white hover:bg-primary-700 transition-colors"
            >
              Download PDF
            </button>
          )}
        </div>
      </div>
    </div>
  );
}