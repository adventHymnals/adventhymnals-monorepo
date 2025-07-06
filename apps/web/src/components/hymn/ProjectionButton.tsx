'use client';

import { useState } from 'react';
import { PresentationChartLineIcon, Cog6ToothIcon } from '@heroicons/react/24/outline';
import { Hymn, ProjectionSettings } from '@advent-hymnals/shared';
import { classNames } from '@/lib/utils';

interface ProjectionButtonProps {
  hymn: Hymn;
  className?: string;
}

const defaultSettings: ProjectionSettings = {
  showVerseNumbers: true,
  showChorusAfterEachVerse: true,
  fontSize: 'large',
  theme: 'light',
  showMetadata: true,
  autoAdvance: false,
};

export default function ProjectionButton({ hymn, className }: ProjectionButtonProps) {
  const [showSettings, setShowSettings] = useState(false);
  const [settings, setSettings] = useState<ProjectionSettings>(defaultSettings);

  const openProjection = () => {
    const params = new URLSearchParams({
      settings: JSON.stringify(settings),
    });
    
    const projectionUrl = `/projection/${hymn.id}?${params.toString()}`;
    
    // Open in new window/tab for projection
    window.open(projectionUrl, '_blank', 'width=1920,height=1080,fullscreen=yes');
  };

  const openSettings = () => {
    setShowSettings(true);
  };

  return (
    <div className={classNames('relative', className)}>
      {/* Main Buttons */}
      <div className="flex items-center space-x-2">
        <button
          onClick={openProjection}
          className="flex items-center space-x-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 transition-colors"
        >
          <PresentationChartLineIcon className="h-5 w-5" />
          <span className="text-sm font-medium">Project</span>
        </button>
        
        <button
          onClick={openSettings}
          className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
          title="Projection Settings"
        >
          <Cog6ToothIcon className="h-5 w-5" />
        </button>
      </div>

      {/* Settings Modal */}
      {showSettings && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 bg-black bg-opacity-50 z-50"
            onClick={() => setShowSettings(false)}
          />
          
          {/* Modal */}
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-xl shadow-xl max-w-md w-full max-h-screen overflow-y-auto">
              <div className="p-6">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-lg font-semibold text-gray-900">Projection Settings</h3>
                  <button
                    onClick={() => setShowSettings(false)}
                    className="text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Display Options */}
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-3">Display Options</h4>
                    <div className="space-y-3">
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.showVerseNumbers}
                          onChange={(e) => setSettings(prev => ({ ...prev, showVerseNumbers: e.target.checked }))}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-700">Show verse numbers</span>
                      </label>
                      
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.showChorusAfterEachVerse}
                          onChange={(e) => setSettings(prev => ({ ...prev, showChorusAfterEachVerse: e.target.checked }))}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-700">Show chorus after each verse</span>
                      </label>
                      
                      <label className="flex items-center">
                        <input
                          type="checkbox"
                          checked={settings.showMetadata}
                          onChange={(e) => setSettings(prev => ({ ...prev, showMetadata: e.target.checked }))}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-700">Show hymn information</span>
                      </label>
                    </div>
                  </div>

                  {/* Font Size */}
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-3">Font Size</h4>
                    <select
                      value={settings.fontSize}
                      onChange={(e) => setSettings(prev => ({ ...prev, fontSize: e.target.value as ProjectionSettings['fontSize'] }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                    >
                      <option value="small">Small</option>
                      <option value="medium">Medium</option>
                      <option value="large">Large</option>
                      <option value="extra-large">Extra Large</option>
                    </select>
                  </div>

                  {/* Theme */}
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-3">Theme</h4>
                    <select
                      value={settings.theme}
                      onChange={(e) => setSettings(prev => ({ ...prev, theme: e.target.value as ProjectionSettings['theme'] }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                    >
                      <option value="light">Light</option>
                      <option value="dark">Dark</option>
                      <option value="high-contrast">High Contrast</option>
                    </select>
                  </div>

                  {/* Auto Advance */}
                  <div>
                    <h4 className="text-sm font-medium text-gray-900 mb-3">Auto Advance</h4>
                    <label className="flex items-center mb-2">
                      <input
                        type="checkbox"
                        checked={settings.autoAdvance}
                        onChange={(e) => setSettings(prev => ({ ...prev, autoAdvance: e.target.checked }))}
                        className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                      />
                      <span className="ml-2 text-sm text-gray-700">Enable auto advance</span>
                    </label>
                    
                    {settings.autoAdvance && (
                      <div className="ml-6">
                        <label className="block text-xs text-gray-500 mb-1">Delay (seconds)</label>
                        <input
                          type="number"
                          min="3"
                          max="30"
                          value={settings.autoAdvanceDelay || 10}
                          onChange={(e) => setSettings(prev => ({ ...prev, autoAdvanceDelay: parseInt(e.target.value) }))}
                          className="w-20 px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                        />
                      </div>
                    )}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex space-x-3 mt-8">
                  <button
                    onClick={() => {
                      openProjection();
                      setShowSettings(false);
                    }}
                    className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 transition-colors"
                  >
                    Start Projection
                  </button>
                  <button
                    onClick={() => setShowSettings(false)}
                    className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}