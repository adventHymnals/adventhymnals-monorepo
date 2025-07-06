'use client';

import { useState } from 'react';
import { Hymn, NotationFormat } from '@advent-hymnals/shared';
import NotationSelector from './NotationSelector';
import NotationDisplay from './NotationDisplay';
import ProjectionButton from './ProjectionButton';

interface HymnDisplaySectionProps {
  hymn: Hymn;
}

export default function HymnDisplaySection({ hymn }: HymnDisplaySectionProps) {
  // Determine available formats based on hymn data
  const availableFormats: NotationFormat[] = ['lyrics']; // Always have lyrics
  
  if (hymn.notations && hymn.notations.length > 0) {
    hymn.notations.forEach(notation => {
      if (!availableFormats.includes(notation.format)) {
        availableFormats.push(notation.format);
      }
    });
  }

  const [currentFormat, setCurrentFormat] = useState<NotationFormat>('lyrics');

  return (
    <div className="bg-white rounded-xl shadow-sm border">
      {/* Header with Format Selector and Projection Button */}
      <div className="flex items-center justify-between p-6 border-b border-gray-200">
        <div className="flex items-center space-x-4">
          <h2 className="text-2xl font-bold text-gray-900">Hymn Display</h2>
          <NotationSelector
            currentFormat={currentFormat}
            availableFormats={availableFormats}
            onFormatChange={setCurrentFormat}
          />
        </div>
        
        <ProjectionButton hymn={hymn} />
      </div>

      {/* Content */}
      <div className="p-8">
        <NotationDisplay
          hymn={hymn}
          format={currentFormat}
        />
      </div>
    </div>
  );
}