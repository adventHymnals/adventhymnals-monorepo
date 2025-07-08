'use client';

import { useState } from 'react';
import { ArrowDownTrayIcon } from '@heroicons/react/24/outline';
import { getApiUrl } from '@/lib/data';

interface PDFDownloadButtonProps {
  hymnalId: string;
  hymnalName: string;
  totalHymns: number;
  className?: string;
  size?: 'sm' | 'md' | 'lg';
  variant?: 'primary' | 'secondary';
}

export default function PDFDownloadButton({
  hymnalId,
  hymnalName,
  totalHymns,
  className = '',
  size = 'md',
  variant = 'primary'
}: PDFDownloadButtonProps) {
  const [isDownloading, setIsDownloading] = useState(false);
  const [progress, setProgress] = useState(0);

  const handleDownload = async () => {
    if (isDownloading) return;
    
    setIsDownloading(true);
    setProgress(0);

    try {
      // Start the download
      const response = await fetch(getApiUrl(`/api/hymnals/${hymnalId}/pdf`));
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const reader = response.body?.getReader();
      const contentLength = +(response.headers.get('content-length') ?? 0);
      
      if (!reader) {
        throw new Error('ReadableStream not supported');
      }

      // Read the stream and track progress
      const chunks: Uint8Array[] = [];
      let receivedLength = 0;

      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;
        
        chunks.push(value);
        receivedLength += value.length;
        
        if (contentLength > 0) {
          setProgress(Math.round((receivedLength / contentLength) * 100));
        }
      }

      // Combine chunks and create blob
      const allChunks = new Uint8Array(receivedLength);
      let position = 0;
      for (const chunk of chunks) {
        allChunks.set(chunk, position);
        position += chunk.length;
      }

      // Create download link
      const blob = new Blob([allChunks], { type: 'application/pdf' });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `${hymnalName.replace(/[^a-zA-Z0-9\s]/g, '')}_Hymnal.pdf`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);

    } catch (error) {
      console.error('Download failed:', error);
      alert('Failed to download PDF. Please try again.');
    } finally {
      setIsDownloading(false);
      setProgress(0);
    }
  };

  const sizeClasses = {
    sm: 'px-3 py-1.5 text-xs',
    md: 'px-4 py-2 text-sm',
    lg: 'px-6 py-3 text-base'
  };

  const variantClasses = {
    primary: 'bg-primary-600 hover:bg-primary-700 text-white',
    secondary: 'bg-white hover:bg-gray-50 text-gray-700 border border-gray-300'
  };

  const iconSizes = {
    sm: 'h-3 w-3',
    md: 'h-4 w-4',
    lg: 'h-5 w-5'
  };

  return (
    <button
      onClick={handleDownload}
      disabled={isDownloading}
      className={`
        inline-flex items-center font-medium rounded-md transition-colors duration-200 
        ${sizeClasses[size]} 
        ${variantClasses[variant]}
        ${isDownloading ? 'opacity-50 cursor-not-allowed' : ''}
        ${className}
      `}
      title={`Download ${hymnalName} PDF (${totalHymns} hymns)`}
    >
      <ArrowDownTrayIcon className={`${iconSizes[size]} mr-1.5`} />
      {isDownloading ? (
        <span className="flex items-center">
          {progress > 0 ? `${progress}%` : 'Generating...'}
          <svg
            className={`animate-spin ml-2 ${iconSizes[size]}`}
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            ></circle>
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
        </span>
      ) : size === 'sm' ? (
        'PDF'
      ) : size === 'lg' ? (
        `Download PDF (${totalHymns} hymns)`
      ) : (
        'Download'
      )}
    </button>
  );
}