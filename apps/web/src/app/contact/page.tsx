import { Metadata } from 'next';
import { EnvelopeIcon, ClockIcon, ChatBubbleLeftRightIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Contact Us - Advent Hymnals',
  description: 'Get in touch with the Advent Hymnals team. We\'d love to hear from you about contributions, feedback, or questions.',
  keywords: ['contact', 'support', 'feedback', 'Advent Hymnals team', 'help'],
};

export default async function ContactPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Contact Us
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                We&apos;d love to hear from you. Send us a message and we&apos;ll respond as soon as possible.
              </p>
            </div>
          </div>
        </div>

        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-12 lg:grid-cols-2">
            {/* Contact Form */}
            <div>
              <div className="bg-white rounded-xl shadow-sm p-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Send us a message</h2>
                
                <form className="space-y-6">
                  <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                    <div>
                      <label htmlFor="first-name" className="block text-sm font-medium text-gray-700">
                        First name
                      </label>
                      <input
                        type="text"
                        name="first-name"
                        id="first-name"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                      />
                    </div>
                    <div>
                      <label htmlFor="last-name" className="block text-sm font-medium text-gray-700">
                        Last name
                      </label>
                      <input
                        type="text"
                        name="last-name"
                        id="last-name"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                      />
                    </div>
                  </div>

                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                      Email
                    </label>
                    <input
                      type="email"
                      name="email"
                      id="email"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                    />
                  </div>

                  <div>
                    <label htmlFor="subject" className="block text-sm font-medium text-gray-700">
                      Subject
                    </label>
                    <select
                      id="subject"
                      name="subject"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                    >
                      <option>General Inquiry</option>
                      <option>Technical Support</option>
                      <option>Content Contribution</option>
                      <option>Research Collaboration</option>
                      <option>Bug Report</option>
                      <option>Feature Request</option>
                      <option>Partnership Opportunity</option>
                    </select>
                  </div>

                  <div>
                    <label htmlFor="message" className="block text-sm font-medium text-gray-700">
                      Message
                    </label>
                    <textarea
                      id="message"
                      name="message"
                      rows={4}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                      placeholder="Tell us how we can help you..."
                    />
                  </div>

                  <div>
                    <button
                      type="submit"
                      className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors"
                    >
                      Send Message
                    </button>
                  </div>
                </form>
              </div>
            </div>

            {/* Contact Information */}
            <div className="space-y-8">
              {/* Email */}
              <div className="bg-white rounded-xl shadow-sm p-6">
                <div className="flex items-center mb-4">
                  <EnvelopeIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h3 className="text-lg font-semibold text-gray-900">Email</h3>
                </div>
                <p className="text-gray-600 mb-2">
                  Send us an email and we&apos;ll get back to you within 24 hours.
                </p>
                <a
                  href="mailto:editor@gospelsounders.org"
                  className="text-primary-600 hover:text-primary-700 font-medium"
                >
                  editor@gospelsounders.org
                </a>
              </div>

              {/* Response Time */}
              <div className="bg-white rounded-xl shadow-sm p-6">
                <div className="flex items-center mb-4">
                  <ClockIcon className="h-6 w-6 text-green-600 mr-3" />
                  <h3 className="text-lg font-semibold text-gray-900">Response Time</h3>
                </div>
                <p className="text-gray-600">
                  We typically respond to inquiries within 24 hours during business days. 
                  For urgent technical issues, we aim to respond within a few hours.
                </p>
              </div>

              {/* Community */}
              <div className="bg-white rounded-xl shadow-sm p-6">
                <div className="flex items-center mb-4">
                  <ChatBubbleLeftRightIcon className="h-6 w-6 text-blue-600 mr-3" />
                  <h3 className="text-lg font-semibold text-gray-900">Community</h3>
                </div>
                <p className="text-gray-600 mb-4">
                  Join our community discussions and connect with other users and contributors.
                </p>
                <div className="space-y-2">
                  <a
                    href="https://github.com/adventhymnals"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block text-primary-600 hover:text-primary-700 font-medium"
                  >
                    GitHub Repository
                  </a>
                  <a
                    href="https://twitter.com/adventhymnals"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block text-primary-600 hover:text-primary-700 font-medium"
                  >
                    Twitter Updates
                  </a>
                </div>
              </div>

              {/* Project Information */}
              <div className="bg-primary-50 border border-primary-200 rounded-xl p-6">
                <h3 className="text-lg font-semibold text-primary-900 mb-4">
                  About This Project
                </h3>
                <p className="text-primary-800 text-sm mb-4">
                  Advent Hymnals is an independent, community-driven project dedicated to 
                  preserving and sharing Adventist musical heritage. We are not officially 
                  affiliated with the Seventh-day Adventist Church.
                </p>
                <p className="text-primary-800 text-sm">
                  Our mission is to make these historical hymnal collections accessible 
                  for worship, education, and research purposes under fair use guidelines.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* FAQ Section */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Frequently Asked Questions
              </h2>
              <p className="text-lg text-gray-600">
                Quick answers to common questions
              </p>
            </div>

            <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  How can I contribute to the project?
                </h3>
                <p className="text-gray-600 mb-6">
                  There are many ways to contribute including code development, content research, 
                  quality assurance, and community building. Visit our contribute page for details.
                </p>

                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  Is this project officially endorsed by the SDA Church?
                </h3>
                <p className="text-gray-600 mb-6">
                  This is an independent project not officially affiliated with the Seventh-day 
                  Adventist Church. We use hymnal content for educational and research purposes.
                </p>
              </div>

              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  Can I use this content for my church or organization?
                </h3>
                <p className="text-gray-600 mb-6">
                  Yes, the platform is designed to support worship leaders, educators, and 
                  researchers. Please respect copyright guidelines for any copyrighted material.
                </p>

                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  How do I report errors or suggest improvements?
                </h3>
                <p className="text-gray-600">
                  You can report issues through our contact form, GitHub repository, or email. 
                  We appreciate all feedback to help improve the platform.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}