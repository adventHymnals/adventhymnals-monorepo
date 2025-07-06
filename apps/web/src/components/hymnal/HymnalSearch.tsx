'use client';

import { useParams } from 'next/navigation';
import SearchInput from '@/components/ui/SearchInput';

interface HymnalSearchProps {
  placeholder: string;
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

export default function HymnalSearch({ placeholder, className, size = 'lg' }: HymnalSearchProps) {
  const params = useParams();

  const handleSubmit = (query: string) => {
    if (typeof window !== 'undefined' && query.trim()) {
      window.location.href = `/${params.hymnal}/search?q=${encodeURIComponent(query.trim())}`;
    }
  };

  return (
    <SearchInput
      placeholder={placeholder}
      onSubmit={handleSubmit}
      size={size}
      className={className}
    />
  );
}