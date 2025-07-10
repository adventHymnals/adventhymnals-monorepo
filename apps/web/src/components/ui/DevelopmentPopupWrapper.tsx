'use client';

import { useState, useEffect } from 'react';
import { useFirstTimeVisitor } from '@/hooks/useFirstTimeVisitor';
import DevelopmentPopup from './DevelopmentPopup';

export default function DevelopmentPopupWrapper() {
  const { isFirstTime, isChecking } = useFirstTimeVisitor();
  const [isVisible, setIsVisible] = useState(false);

  // Show popup once checking is complete and user is first time visitor
  useEffect(() => {
    if (!isChecking && isFirstTime) {
      setIsVisible(true);
    }
  }, [isChecking, isFirstTime]);

  const handleClose = () => {
    setIsVisible(false);
  };

  return (
    <DevelopmentPopup
      isVisible={isVisible}
      onClose={handleClose}
    />
  );
}