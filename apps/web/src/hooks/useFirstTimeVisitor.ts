'use client';

import { useState, useEffect } from 'react';

export function useFirstTimeVisitor() {
  const [isFirstTime, setIsFirstTime] = useState(false);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const checkFirstTimeVisitor = () => {
      try {
        const hasVisited = localStorage.getItem('advent-hymnals-visited');
        const hasSubscribed = localStorage.getItem('advent-hymnals-subscribed');
        
        // Show popup if it's their first time and they haven't subscribed
        const shouldShowPopup = !hasVisited && !hasSubscribed;
        
        setIsFirstTime(shouldShowPopup);
        
        // Mark as visited
        if (!hasVisited) {
          localStorage.setItem('advent-hymnals-visited', 'true');
        }
      } catch (error) {
        // localStorage might not be available (SSR, privacy mode, etc.)
        console.log('LocalStorage not available:', error);
        setIsFirstTime(false);
      }
      
      setIsChecking(false);
    };

    // Small delay to avoid showing popup too quickly
    const timer = setTimeout(checkFirstTimeVisitor, 2000);
    
    return () => clearTimeout(timer);
  }, []);

  return { isFirstTime, isChecking };
}