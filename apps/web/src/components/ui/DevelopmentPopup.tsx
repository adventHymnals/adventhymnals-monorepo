'use client';

import { useState, useEffect } from 'react';
import { XMarkIcon, ExclamationTriangleIcon } from '@heroicons/react/24/outline';

interface DevelopmentPopupProps {
  isVisible: boolean;
  onClose: () => void;
}

export default function DevelopmentPopup({ isVisible, onClose }: DevelopmentPopupProps) {
  const [email, setEmail] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [countdown, setCountdown] = useState(0);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;

    setIsSubmitting(true);
    setSubmitStatus('idle');

    try {
      // Submit to Google Sheets via Google Apps Script
      const response = await fetch('/api/subscribe', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email.trim(),
          source: 'development_popup',
          timestamp: new Date().toISOString(),
        }),
      });

      if (response.ok) {
        setSubmitStatus('success');
        // Store that user has subscribed to prevent popup from showing again
        localStorage.setItem('advent-hymnals-subscribed', 'true');
      } else {
        setSubmitStatus('error');
      }
    } catch (error) {
      console.error('Subscribe error:', error);
      setSubmitStatus('error');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Auto-close countdown when subscription is successful
  useEffect(() => {
    if (submitStatus === 'success') {
      setCountdown(3); // Start 3-second countdown
      
      const timer = setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            clearInterval(timer);
            onClose();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      return () => clearInterval(timer);
    }
  }, [submitStatus, onClose]);

  if (!isVisible) return null;

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-black bg-opacity-50">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full p-6 relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <XMarkIcon className="h-6 w-6" />
        </button>

        <div className="flex items-center space-x-3 mb-4">
          <ExclamationTriangleIcon className="h-8 w-8 text-amber-500" />
          <h3 className="text-lg font-semibold text-gray-900">
            Site Under Development
          </h3>
        </div>

        <div className="mb-6">
          <p className="text-gray-600 mb-4">
            Welcome to Advent Hymnals! We're actively developing this digital hymnal platform 
            to serve the global Adventist community. While you can explore our current features, 
            we're continuously adding new content and improvements.
          </p>
          <p className="text-gray-600 mb-4">
            Stay informed about our progress and be the first to know when new features are available:
          </p>
        </div>

        {submitStatus === 'success' ? (
          <div className="text-center">
            <div className="text-green-600 mb-2">
              <svg className="w-12 h-12 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <p className="text-green-600 font-semibold">Thank you for subscribing!</p>
            <p className="text-gray-600 text-sm mt-2 mb-4">
              We'll keep you updated on our development progress.
            </p>
            
            {/* Countdown indicator */}
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
              <span>Closing in</span>
              <div className="flex items-center justify-center w-8 h-8 bg-blue-100 text-blue-600 rounded-full font-semibold">
                {countdown}
              </div>
              <span>seconds</span>
            </div>
            
            <button
              onClick={onClose}
              className="mt-4 px-4 py-2 text-sm text-blue-600 hover:text-blue-800 transition-colors"
            >
              Close now
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                Email Address
              </label>
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="your@email.com"
                disabled={isSubmitting}
              />
            </div>

            {submitStatus === 'error' && (
              <div className="text-red-600 text-sm">
                Sorry, there was an error subscribing. Please try again later.
              </div>
            )}

            <div className="flex space-x-3">
              <button
                type="submit"
                disabled={isSubmitting || !email.trim()}
                className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {isSubmitting ? 'Subscribing...' : 'Subscribe'}
              </button>
              <button
                type="button"
                onClick={onClose}
                className="flex-1 bg-gray-200 text-gray-800 py-2 px-4 rounded-md hover:bg-gray-300 transition-colors"
              >
                Skip for now
              </button>
            </div>
          </form>
        )}

        <div className="mt-4 text-xs text-gray-500 text-center">
          We respect your privacy and won't share your email with third parties.
        </div>
      </div>
    </div>
  );
}