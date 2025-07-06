'use client';

import { useState, useEffect } from 'react';
import { MagnifyingGlassIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { classNames } from '@advent-hymnals/shared';

interface SearchInputProps {
  value?: string;
  onChange?: (value: string) => void;
  onSubmit?: (value: string) => void;
  placeholder?: string;
  className?: string;
  autoFocus?: boolean;
  size?: 'sm' | 'md' | 'lg';
}

export default function SearchInput({
  value = '',
  onChange,
  onSubmit,
  placeholder = 'Search hymns...',
  className,
  autoFocus = false,
  size = 'md'
}: SearchInputProps) {
  const [inputValue, setInputValue] = useState(value);

  useEffect(() => {
    setInputValue(value);
  }, [value]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit?.(inputValue.trim());
  };

  const handleClear = () => {
    setInputValue('');
    onChange?.('');
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setInputValue(newValue);
    onChange?.(newValue);
  };

  const sizeClasses = {
    sm: 'pl-8 pr-8 py-1.5 text-sm',
    md: 'pl-10 pr-10 py-2 text-base',
    lg: 'pl-12 pr-12 py-3 text-lg',
  };

  const iconSizeClasses = {
    sm: 'h-4 w-4 left-2.5',
    md: 'h-5 w-5 left-3',
    lg: 'h-6 w-6 left-3.5',
  };

  const clearIconSizeClasses = {
    sm: 'h-4 w-4 right-2.5',
    md: 'h-5 w-5 right-3',
    lg: 'h-6 w-6 right-3.5',
  };

  return (
    <form onSubmit={handleSubmit} className={className}>
      <div className="relative">
        <input
          type="text"
          value={inputValue}
          onChange={handleChange}
          placeholder={placeholder}
          autoFocus={autoFocus}
          className={classNames(
            'w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all duration-200',
            sizeClasses[size]
          )}
        />
        
        {/* Search icon */}
        <MagnifyingGlassIcon
          className={classNames(
            'absolute top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none',
            iconSizeClasses[size]
          )}
        />
        
        {/* Clear button */}
        {inputValue && (
          <button
            type="button"
            onClick={handleClear}
            className={classNames(
              'absolute top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors duration-200',
              clearIconSizeClasses[size]
            )}
          >
            <XMarkIcon className="h-full w-full" />
            <span className="sr-only">Clear search</span>
          </button>
        )}
      </div>
    </form>
  );
}

// Quick search suggestions component
interface SearchSuggestionsProps {
  suggestions: string[];
  onSelect: (suggestion: string) => void;
  className?: string;
}

export function SearchSuggestions({ suggestions, onSelect, className }: SearchSuggestionsProps) {
  if (!suggestions.length) return null;

  return (
    <div className={classNames('absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-lg shadow-lg z-50 mt-1', className)}>
      <ul className="py-2">
        {suggestions.map((suggestion, index) => (
          <li key={index}>
            <button
              type="button"
              onClick={() => onSelect(suggestion)}
              className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-200"
            >
              {suggestion}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}