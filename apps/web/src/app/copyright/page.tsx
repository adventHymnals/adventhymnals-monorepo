import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Copyright Information - Advent Hymnals',
  description: 'Copyright information and legal details for hymnal collections on Advent Hymnals.',
};

export default async function CopyrightPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        <div className="mx-auto max-w-4xl px-6 py-16 lg:px-8">
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Copyright Information
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Understanding the copyright status of our hymnal collections
            </p>
          </div>

          <div className="prose prose-lg max-w-none">
            <h2>Copyright Status Overview</h2>
            <p>
              The hymnal collections available on Advent Hymnals represent works published 
              between 1838 and 2000, with varying copyright statuses based on publication 
              date, renewal status, and applicable copyright law.
            </p>

            <h2>Public Domain Works</h2>
            <p>
              Many of the hymnal collections in our archive are in the public domain due to:
            </p>
            <ul>
              <li>Publication before 1928 (automatically in public domain in the US)</li>
              <li>Failure to renew copyright during the renewal period</li>
              <li>Publication by government entities or certain organizations</li>
              <li>Explicit dedication to public domain by copyright holders</li>
            </ul>

            <h3>Collections Likely in Public Domain</h3>
            <ul>
              <li>Hymns for the Poor of the Flock (1838)</li>
              <li>Millenial Harp (1843)</li>
              <li>Hymns and Tunes (1869, 1876, 1886)</li>
              <li>Church Hymnal (1941) - may require verification</li>
            </ul>

            <h2>Protected Works</h2>
            <p>
              Some collections may still be under copyright protection:
            </p>
            <ul>
              <li>Seventh-day Adventist Hymnal (1985)</li>
              <li>Christ in Song (1900s editions)</li>
              <li>More recent language translations</li>
            </ul>

            <h2>Fair Use Considerations</h2>
            <p>
              For works that may still be under copyright, our use is justified under 
              fair use provisions (17 U.S.C. § 107) for the following reasons:
            </p>

            <h3>Purpose and Character</h3>
            <ul>
              <li>Educational and research purposes</li>
              <li>Historical preservation and archival</li>
              <li>Non-commercial academic use</li>
              <li>Transformative digital presentation for study</li>
            </ul>

            <h3>Nature of the Work</h3>
            <ul>
              <li>Published works of religious and cultural significance</li>
              <li>Historical documents of public interest</li>
              <li>Works intended for widespread community use</li>
            </ul>

            <h3>Amount Used</h3>
            <ul>
              <li>Complete works necessary for historical and educational context</li>
              <li>No alternative means to achieve educational goals</li>
              <li>Usage proportionate to educational purpose</li>
            </ul>

            <h3>Market Impact</h3>
            <ul>
              <li>No commercial competition with current publications</li>
              <li>Educational use that may increase interest in original works</li>
              <li>Preservation of historical materials that might otherwise be lost</li>
            </ul>

            <h2>Permissions and Rights</h2>
            <p>
              Where possible, we have sought permissions from relevant organizations and 
              copyright holders. We continue to work with institutions to clarify rights 
              and ensure appropriate use.
            </p>

            <h2>User Responsibilities</h2>
            <p>
              Users of this website should be aware of their responsibilities:
            </p>
            <ul>
              <li>Respect applicable copyright laws in your jurisdiction</li>
              <li>Use materials for educational, research, or worship purposes</li>
              <li>Seek permission for any commercial use</li>
              <li>Provide appropriate attribution when using materials</li>
            </ul>

            <h2>Copyright Notices</h2>
            <p>
              Individual hymns and collections may contain specific copyright notices. 
              These notices are preserved in our digital presentations and should be 
              respected by users.
            </p>

            <h2>Removal Requests</h2>
            <p>
              If you believe any content on this website infringes upon your copyright, 
              please contact us immediately with:
            </p>
            <ul>
              <li>Specific identification of the copyrighted work</li>
              <li>Proof of copyright ownership</li>
              <li>Contact information</li>
              <li>Good faith statement of infringement belief</li>
            </ul>

            <h2>Digital Millennium Copyright Act</h2>
            <p>
              We comply with the Digital Millennium Copyright Act (DMCA) and will respond 
              promptly to valid takedown notices. Our designated copyright agent can be 
              contacted at: copyright@adventhymnals.com
            </p>

            <div className="bg-amber-50 border border-amber-200 rounded-lg p-6 mt-8">
              <h3 className="text-lg font-semibold text-amber-900 mb-2">⚖️ Legal Disclaimer</h3>
              <p className="text-sm text-amber-800">
                This information is provided for educational purposes and should not be 
                considered legal advice. Copyright law is complex and varies by jurisdiction. 
                Users should consult with legal counsel for specific copyright questions.
              </p>
            </div>

            <div className="bg-green-50 border border-green-200 rounded-lg p-6 mt-6">
              <h3 className="text-lg font-semibold text-green-900 mb-2">🤝 Supporting Copyright Holders</h3>
              <p className="text-sm text-green-800">
                We encourage users to support current publishers and copyright holders by 
                purchasing official editions of hymnals still in print. Our archive serves 
                to complement, not replace, official publications.
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}