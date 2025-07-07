'use client';

import { useState, useRef, useEffect } from 'react';
import { ChevronDownIcon, XMarkIcon } from '@heroicons/react/24/outline';

interface MultiSelectOption {
  value: string;
  label: string;
}

interface MultiSelectProps {
  options: MultiSelectOption[];
  selectedValues: string[];
  onChange: (values: string[]) => void;
  placeholder: string;
  className?: string;
}

export default function MultiSelect({
  options,
  selectedValues,
  onChange,
  placeholder,
  className = ''
}: MultiSelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleToggleOption = (value: string) => {
    if (selectedValues.includes(value)) {
      onChange(selectedValues.filter(v => v !== value));
    } else {
      onChange([...selectedValues, value]);
    }
  };

  const handleRemoveOption = (value: string, e: React.MouseEvent) => {
    e.stopPropagation();
    onChange(selectedValues.filter(v => v !== value));
  };

  const getDisplayText = () => {
    if (selectedValues.length === 0) {
      return placeholder;
    }
    if (selectedValues.length === 1) {
      const option = options.find(opt => opt.value === selectedValues[0]);
      return option?.label || selectedValues[0];
    }
    return `${selectedValues.length} selected`;
  };

  return (
    <div className={`relative ${className}`} ref={dropdownRef}>
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="relative w-full rounded-md border border-gray-300 bg-white py-1 px-2 text-left text-xs sm:text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
      >
        <span className="block truncate">{getDisplayText()}</span>
        <span className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
          <ChevronDownIcon className="h-3 w-3 text-gray-400" aria-hidden="true" />
        </span>
      </button>

      {isOpen && (
        <div className="absolute z-50 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-xs sm:text-sm shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
          {options.map((option) => (
            <div
              key={option.value}
              className={`relative cursor-pointer select-none py-2 pl-3 pr-9 hover:bg-gray-50 ${
                selectedValues.includes(option.value) ? 'bg-primary-50 text-primary-600' : 'text-gray-900'
              }`}
              onClick={() => handleToggleOption(option.value)}
            >
              <span className="block truncate">{option.label}</span>
              {selectedValues.includes(option.value) && (
                <span className="absolute inset-y-0 right-0 flex items-center pr-4 text-primary-600">
                  ✓
                </span>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Selected items as chips (for mobile view) */}
      {selectedValues.length > 0 && (
        <div className="mt-1 flex flex-wrap gap-1 sm:hidden">
          {selectedValues.map((value) => {
            const option = options.find(opt => opt.value === value);
            return (
              <span
                key={value}
                className="inline-flex items-center rounded-full bg-primary-100 px-2 py-0.5 text-xs text-primary-800"
              >
                {option?.label || value}
                <button
                  type="button"
                  onClick={(e) => handleRemoveOption(value, e)}
                  className="ml-1 inline-flex h-3 w-3 flex-shrink-0 items-center justify-center rounded-full text-primary-400 hover:bg-primary-200 hover:text-primary-500"
                >
                  <XMarkIcon className="h-2 w-2" />
                </button>
              </span>
            );
          })}
        </div>
      )}
    </div>
  );
}