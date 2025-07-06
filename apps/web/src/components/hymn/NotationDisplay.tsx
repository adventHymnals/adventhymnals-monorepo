'use client';

import { Hymn, NotationFormat, HymnNotation } from '@advent-hymnals/shared';
import { classNames } from '@/lib/utils';

interface NotationDisplayProps {
  hymn: Hymn;
  format: NotationFormat;
  className?: string;
}

function LyricsDisplay({ hymn, className }: { hymn: Hymn; className?: string }) {
  return (
    <div className={classNames('space-y-6', className)}>
      {hymn.verses.map((verse) => (
        <div key={verse.number} className="relative">
          <div className="absolute left-0 top-0 w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
            <span className="text-sm font-bold text-primary-600">
              {verse.number}
            </span>
          </div>
          <div className="ml-12">
            <div className="text-lg leading-relaxed text-gray-800 whitespace-pre-line">
              {verse.text}
            </div>
          </div>
        </div>
      ))}

      {/* Chorus */}
      {hymn.chorus && (
        <div className="relative mt-8 p-6 bg-primary-50 border-l-4 border-primary-500 rounded-r-lg">
          <div className="absolute left-0 top-0 w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center -ml-6 mt-2">
            <span className="text-sm font-bold text-white">C</span>
          </div>
          <div className="ml-6">
            <h3 className="text-lg font-semibold text-primary-900 mb-2">Chorus</h3>
            <div className="text-lg leading-relaxed text-primary-800 whitespace-pre-line">
              {hymn.chorus.text}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function SolfaDisplay({ hymn, notation, className }: { hymn: Hymn; notation?: HymnNotation; className?: string }) {
  if (!notation) {
    return (
      <div className={classNames('text-center py-12', className)}>
        <div className="text-gray-500">
          <svg className="mx-auto h-12 w-12 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
          <p className="text-lg font-medium">Sol-fa notation not available</p>
          <p className="text-sm mt-2">This hymn doesn't have sol-fa notation in our database yet.</p>
        </div>
      </div>
    );
  }

  return (
    <div className={classNames('space-y-6', className)}>
      <div className="bg-amber-50 border border-amber-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-amber-900 mb-4">Sol-fa Notation</h3>
        <div className="font-mono text-base leading-loose text-amber-800 whitespace-pre-line">
          {notation.content}
        </div>
      </div>
      
      {/* Legend */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h4 className="text-sm font-medium text-gray-900 mb-2">Sol-fa Guide</h4>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs text-gray-600">
          <div><strong>do</strong> - 1st degree</div>
          <div><strong>re</strong> - 2nd degree</div>
          <div><strong>mi</strong> - 3rd degree</div>
          <div><strong>fa</strong> - 4th degree</div>
          <div><strong>sol</strong> - 5th degree</div>
          <div><strong>la</strong> - 6th degree</div>
          <div><strong>ti</strong> - 7th degree</div>
          <div><strong>do'</strong> - 8th degree (octave)</div>
        </div>
      </div>
    </div>
  );
}

function StaffDisplay({ hymn, notation, className }: { hymn: Hymn; notation?: HymnNotation; className?: string }) {
  if (!notation) {
    return (
      <div className={classNames('text-center py-12', className)}>
        <div className="text-gray-500">
          <svg className="mx-auto h-12 w-12 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
          <p className="text-lg font-medium">Staff notation not available</p>
          <p className="text-sm mt-2">Musical staff notation is not available for this hymn yet.</p>
        </div>
      </div>
    );
  }

  return (
    <div className={classNames('space-y-6', className)}>
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-blue-900 mb-4">Staff Notation</h3>
        <div className="text-center">
          {/* This would be replaced with actual music notation rendering */}
          <div className="bg-white border-2 border-blue-200 rounded-lg p-8 min-h-96">
            <div className="text-blue-600 text-sm mb-4">Musical Score</div>
            <div className="text-gray-500 text-sm">
              Staff notation rendering would be displayed here using a music notation library like VexFlow or OSMD.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function ChordDisplay({ hymn, notation, className }: { hymn: Hymn; notation?: HymnNotation; className?: string }) {
  if (!notation) {
    return (
      <div className={classNames('text-center py-12', className)}>
        <div className="text-gray-500">
          <svg className="mx-auto h-12 w-12 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
          <p className="text-lg font-medium">Chord charts not available</p>
          <p className="text-sm mt-2">Guitar/piano chord notation is not available for this hymn yet.</p>
        </div>
      </div>
    );
  }

  return (
    <div className={classNames('space-y-6', className)}>
      <div className="bg-green-50 border border-green-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-green-900 mb-4">Chord Chart</h3>
        <div className="font-mono text-base leading-loose text-green-800 whitespace-pre-line">
          {notation.content}
        </div>
      </div>
    </div>
  );
}

export default function NotationDisplay({ hymn, format, className }: NotationDisplayProps) {
  const notation = hymn.notations?.find(n => n.format === format);

  switch (format) {
    case 'lyrics':
      return <LyricsDisplay hymn={hymn} className={className} />;
    case 'solfa':
      return <SolfaDisplay hymn={hymn} notation={notation} className={className} />;
    case 'staff':
      return <StaffDisplay hymn={hymn} notation={notation} className={className} />;
    case 'chord':
      return <ChordDisplay hymn={hymn} notation={notation} className={className} />;
    default:
      return <LyricsDisplay hymn={hymn} className={className} />;
  }
}