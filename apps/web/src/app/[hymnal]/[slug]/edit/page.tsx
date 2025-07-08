import { Metadata } from 'next';


interface EditPageProps {
  params: {
    hymnal: string;
    slug: string;
  };
}


export async function generateMetadata({ params }: EditPageProps): Promise<Metadata> {
  return {
    title: 'Edit Mode Not Available',
    description: 'Hymn editing is not supported in fully static mode. This feature requires a dynamic server environment.',
  };
}

export async function generateStaticParams() {
  // Edit pages are not supported in fully static mode
  // Return empty array to prevent any static generation
  return [];
}

export default async function EditPage({ params }: EditPageProps) {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
        <div className="mb-6">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
        
        <h1 className="text-xl font-semibold text-gray-900 mb-3">
          Edit Mode Not Available
        </h1>
        
        <p className="text-gray-600 mb-6">
          Hymn editing is not supported in fully static mode. This feature requires a dynamic server environment.
        </p>
        
        <div className="space-y-3">
          <a
            href={`/${params.hymnal}/${params.slug}`}
            className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
          >
            View Hymn
          </a>
          
          <a
            href={`/${params.hymnal}`}
            className="block w-full bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Back to Hymnal
          </a>
        </div>
      </div>
    </div>
  );
}