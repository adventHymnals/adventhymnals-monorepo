import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Terms of Service - Advent Hymnals',
  description: 'Terms of service for using the Advent Hymnals website and services.',
};

export default async function TermsPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        <div className="mx-auto max-w-4xl px-6 py-16 lg:px-8">
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Terms of Service
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Last updated: December 2024
            </p>
          </div>

          <div className="prose prose-lg max-w-none">
            <h2>Acceptance of Terms</h2>
            <p>
              By accessing and using the Advent Hymnals website, you accept and agree to be bound by 
              the terms and provision of this agreement. This is an independent project providing 
              educational access to historical hymnal collections.
            </p>

            <h2>Use License</h2>
            <p>
              Permission is granted to temporarily access the materials on Advent Hymnals' website 
              for personal, non-commercial transitory viewing only. This is the grant of a license, 
              not a transfer of title, and under this license you may not:
            </p>
            <ul>
              <li>Modify or copy the materials</li>
              <li>Use the materials for any commercial purpose or for any public display</li>
              <li>Attempt to reverse engineer any software contained on the website</li>
              <li>Remove any copyright or other proprietary notations from the materials</li>
            </ul>

            <h2>Educational and Fair Use</h2>
            <p>
              This website provides access to historical hymnal collections under fair use provisions 
              for educational, research, and worship purposes. All hymnal content is used for 
              educational purposes and historical preservation.
            </p>

            <h3>Permitted Uses</h3>
            <ul>
              <li>Personal study and research</li>
              <li>Educational instruction</li>
              <li>Worship services and religious gatherings</li>
              <li>Academic research and scholarship</li>
            </ul>

            <h3>Prohibited Uses</h3>
            <ul>
              <li>Commercial redistribution of hymnal content</li>
              <li>Bulk downloading or systematic extraction</li>
              <li>Creating derivative commercial products</li>
              <li>Violating copyright holders' rights</li>
            </ul>

            <h2>Disclaimer</h2>
            <p>
              The materials on Advent Hymnals' website are provided on an 'as is' basis. 
              Advent Hymnals makes no warranties, expressed or implied, and hereby disclaims 
              and negates all other warranties including without limitation, implied warranties 
              or conditions of merchantability, fitness for a particular purpose, or 
              non-infringement of intellectual property or other violation of rights.
            </p>

            <h2>Limitations</h2>
            <p>
              In no event shall Advent Hymnals or its suppliers be liable for any damages 
              (including, without limitation, damages for loss of data or profit, or due to 
              business interruption) arising out of the use or inability to use the materials 
              on the website, even if Advent Hymnals or an authorized representative has been 
              notified orally or in writing of the possibility of such damage.
            </p>

            <h2>Accuracy of Materials</h2>
            <p>
              The materials appearing on Advent Hymnals' website could include technical, 
              typographical, or photographic errors. Advent Hymnals does not warrant that 
              any of the materials on its website are accurate, complete, or current.
            </p>

            <h2>Links</h2>
            <p>
              Advent Hymnals has not reviewed all of the sites linked to our website and is 
              not responsible for the contents of any such linked site. The inclusion of any 
              link does not imply endorsement by Advent Hymnals of the site.
            </p>

            <h2>Modifications</h2>
            <p>
              Advent Hymnals may revise these terms of service at any time without notice. 
              By using this website, you are agreeing to be bound by the then current version 
              of these terms of service.
            </p>

            <h2>Copyright and Attribution</h2>
            <p>
              All hymnal collections remain under their original copyright. This website 
              serves as an educational archive and research tool. Users are responsible for 
              respecting applicable copyright laws in their use of the materials.
            </p>

            <h2>Contact Information</h2>
            <p>
              Questions about the Terms of Service should be sent to us at:
            </p>
            <ul>
              <li>Email: legal@adventhymnals.com</li>
              <li>Through our <a href="/contact" className="text-primary-600">contact form</a></li>
            </ul>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mt-8">
              <h3 className="text-lg font-semibold text-blue-900 mb-2">Independent Project</h3>
              <p className="text-sm text-blue-800">
                This is an independent project not officially affiliated with the 
                Seventh-day Adventist Church or any other organization. It is maintained 
                by volunteers for educational and historical preservation purposes.
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}