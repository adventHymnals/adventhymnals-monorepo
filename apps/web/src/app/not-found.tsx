import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
        <div className="mb-6">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.29.82-5.877 2.172M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.25a.25.25 0 11-.5 0 .25.25 0 01.5 0zm-7.5 0a.25.25 0 11-.5 0 .25.25 0 01.5 0z" />
          </svg>
        </div>
        
        <h1 className="text-xl font-semibold text-gray-900 mb-3">
          Page Not Found
        </h1>
        
        <p className="text-gray-600 mb-6">
          The page you're looking for doesn't exist. Some features like projection mode and editing are not available in the static version.
        </p>
        
        <div className="space-y-3">
          <Link
            href="/"
            className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
          >
            Back to Home
          </Link>
          
          <Link
            href="/hymnals"
            className="block w-full bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Browse Hymnals
          </Link>
        </div>
        
        <div className="mt-6 pt-6 border-t border-gray-200">
          <p className="text-sm text-gray-500">
            For full functionality including projection and editing features, visit{' '}
            <a 
              href="https://adventhymnals.org" 
              className="text-primary-600 hover:text-primary-700 underline"
            >
              adventhymnals.org
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}