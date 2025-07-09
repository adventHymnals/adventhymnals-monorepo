import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';

export const metadata: Metadata = {
  title: 'Privacy Policy - Advent Hymnals',
  description: 'Privacy policy for the Advent Hymnals website and services.',
};

export async function generateStaticParams() {
  // Static page with no dynamic params
  return [];
}

export default function PrivacyPage() {
  return (
    <Layout>
      <div className="min-h-screen bg-white">
        <div className="mx-auto max-w-4xl px-6 py-16 lg:px-8">
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Privacy Policy
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Last updated: December 2024
            </p>
          </div>

          <div className="prose prose-lg max-w-none">
            <h2>Information We Collect</h2>
            <p>
              Advent Hymnals is committed to protecting your privacy. This website is designed to provide 
              access to historical hymnal collections for educational and research purposes.
            </p>

            <h3>Automatically Collected Information</h3>
            <ul>
              <li>Basic analytics data (page views, time spent, general location)</li>
              <li>Technical information (browser type, device type, IP address)</li>
              <li>Usage patterns to improve site functionality</li>
            </ul>

            <h3>Information You Provide</h3>
            <ul>
              <li>Contact information when you reach out to us</li>
              <li>Feedback and suggestions you submit</li>
              <li>User-generated content in community features (if applicable)</li>
            </ul>

            <h2>How We Use Information</h2>
            <p>We use collected information to:</p>
            <ul>
              <li>Provide and improve our services</li>
              <li>Understand how users interact with our content</li>
              <li>Respond to user inquiries and feedback</li>
              <li>Ensure the security and integrity of our platform</li>
            </ul>

            <h2>Data Sharing</h2>
            <p>
              We do not sell, trade, or otherwise transfer your personal information to third parties. 
              We may share aggregated, non-personal statistical data for research purposes.
            </p>

            <h2>Cookies and Tracking</h2>
            <p>
              We use minimal cookies for essential website functionality and basic analytics. 
              You can disable cookies in your browser settings, though this may affect site functionality.
            </p>

            <h2>Data Security</h2>
            <p>
              We implement appropriate security measures to protect your information against 
              unauthorized access, alteration, disclosure, or destruction.
            </p>

            <h2>Your Rights</h2>
            <p>You have the right to:</p>
            <ul>
              <li>Access the personal information we hold about you</li>
              <li>Request correction of inaccurate information</li>
              <li>Request deletion of your personal information</li>
              <li>Opt out of certain data collection practices</li>
            </ul>

            <h2>Third-Party Services</h2>
            <p>
              Our website may contain links to external sites. We are not responsible for 
              the privacy practices of these third-party websites.
            </p>

            <h2>Changes to This Policy</h2>
            <p>
              We may update this privacy policy from time to time. We will notify users of 
              any material changes by posting the updated policy on this page.
            </p>

            <h2>Contact Us</h2>
            <p>
              If you have any questions about this privacy policy, please contact us at:
            </p>
            <ul>
              <li>Email: privacy@adventhymnals.com</li>
              <li>Through our <a href="/contact" className="text-primary-600">contact form</a></li>
            </ul>

            <div className="bg-gray-50 border border-gray-200 rounded-lg p-6 mt-8">
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Educational Use</h3>
              <p className="text-sm text-gray-600">
                This website provides access to historical hymnal collections for educational, 
                research, and worship purposes. All content is used under fair use provisions 
                for educational purposes.
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}