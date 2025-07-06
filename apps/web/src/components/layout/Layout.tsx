import { ReactNode } from 'react';
import Header from './Header';
import Footer from './Footer';
import { HymnalCollection } from '@advent-hymnals/shared';

interface LayoutProps {
  children: ReactNode;
  hymnalReferences?: HymnalCollection;
  className?: string;
}

export default function Layout({ children, hymnalReferences, className }: LayoutProps) {
  return (
    <div className="min-h-screen flex flex-col">
      <Header hymnalReferences={hymnalReferences} />
      <main className={`flex-grow ${className || ''}`}>
        {children}
      </main>
      <Footer />
    </div>
  );
}