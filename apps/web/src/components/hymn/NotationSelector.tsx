'use client';

import { useState } from 'react';
import { NotationFormat } from '@advent-hymnals/shared';
import { 
  MusicalNoteIcon, 
  DocumentTextIcon, 
  Bars3Icon,
  BeakerIcon 
} from '@heroicons/react/24/outline';
import { classNames } from '@/lib/utils';

interface NotationSelectorProps {
  currentFormat: NotationFormat;
  availableFormats: NotationFormat[];
  onFormatChange: (format: NotationFormat) => void;
  className?: string;
}

const formatIcons: Record<NotationFormat, React.ComponentType<any>> = {
  lyrics: DocumentTextIcon,
  solfa: MusicalNoteIcon,
  staff: Bars3Icon,
  chord: BeakerIcon,
};

const formatLabels: Record<NotationFormat, string> = {
  lyrics: 'Lyrics',
  solfa: 'Sol-fa',
  staff: 'Staff Notation',
  chord: 'Chords',
};

const formatDescriptions: Record<NotationFormat, string> = {
  lyrics: 'Text only with verse structure',
  solfa: 'Do-Re-Mi notation system',
  staff: 'Traditional musical staff notation',
  chord: 'Guitar/piano chord symbols',
};

export default function NotationSelector({
  currentFormat,
  availableFormats,
  onFormatChange,
  className,
}: NotationSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className={classNames('relative', className)}>
      {/* Current Format Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-2 px-4 py-2 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-colors"
      >
        {(() => {
          const Icon = formatIcons[currentFormat];
          return <Icon className="h-5 w-5 text-gray-600" />;
        })()}
        <span className="text-sm font-medium text-gray-900">
          {formatLabels[currentFormat]}
        </span>
        <svg
          className={classNames(
            'h-4 w-4 text-gray-400 transition-transform',
            isOpen ? 'rotate-180' : ''
          )}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      {/* Dropdown Menu */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
          />
          
          {/* Menu */}
          <div className="absolute right-0 mt-2 w-64 bg-white border border-gray-200 rounded-lg shadow-lg z-20">
            <div className="py-2">
              <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide border-b border-gray-100">
                Display Format
              </div>
              
              {availableFormats.map((format) => {
                const Icon = formatIcons[format];
                const isSelected = format === currentFormat;
                
                return (
                  <button
                    key={format}
                    onClick={() => {
                      onFormatChange(format);
                      setIsOpen(false);
                    }}
                    className={classNames(
                      'w-full flex items-start space-x-3 px-4 py-3 text-left hover:bg-gray-50 transition-colors',
                      isSelected ? 'bg-primary-50 border-r-2 border-primary-500' : ''
                    )}
                  >
                    <Icon className={classNames(
                      'h-5 w-5 mt-0.5 flex-shrink-0',
                      isSelected ? 'text-primary-600' : 'text-gray-400'
                    )} />
                    <div className="flex-1 min-w-0">
                      <div className={classNames(
                        'text-sm font-medium',
                        isSelected ? 'text-primary-900' : 'text-gray-900'
                      )}>
                        {formatLabels[format]}
                      </div>
                      <div className="text-xs text-gray-500 mt-0.5">
                        {formatDescriptions[format]}
                      </div>
                    </div>
                    {isSelected && (
                      <div className="h-5 w-5 flex items-center justify-center">
                        <div className="h-2 w-2 bg-primary-600 rounded-full" />
                      </div>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        </>
      )}
    </div>
  );
}