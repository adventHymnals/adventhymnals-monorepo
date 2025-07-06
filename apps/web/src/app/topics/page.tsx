import { Metadata } from 'next';
import Link from 'next/link';
import { TagIcon, HeartIcon, SparklesIcon, GlobeAltIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Browse by Topic - Advent Hymnals',
  description: 'Explore hymns by themes and topics including worship, praise, Christmas, Easter, communion, baptism, and more.',
  keywords: ['hymn topics', 'worship themes', 'Christmas hymns', 'Easter hymns', 'communion songs', 'baptism hymns'],
};

const topicCategories = [
  {
    title: 'Worship & Praise',
    icon: HeartIcon,
    color: 'bg-red-500',
    topics: [
      { name: 'Worship', count: 245, slug: 'worship' },
      { name: 'Praise', count: 189, slug: 'praise' },
      { name: 'Adoration', count: 156, slug: 'adoration' },
      { name: 'Thanksgiving', count: 134, slug: 'thanksgiving' },
      { name: 'Devotion', count: 98, slug: 'devotion' },
      { name: 'Prayer', count: 87, slug: 'prayer' },
    ]
  },
  {
    title: 'Church Calendar',
    icon: SparklesIcon,
    color: 'bg-green-500',
    topics: [
      { name: 'Christmas', count: 98, slug: 'christmas' },
      { name: 'Easter', count: 76, slug: 'easter' },
      { name: 'Advent', count: 54, slug: 'advent' },
      { name: 'Palm Sunday', count: 32, slug: 'palm-sunday' },
      { name: 'Good Friday', count: 28, slug: 'good-friday' },
      { name: 'Pentecost', count: 23, slug: 'pentecost' },
    ]
  },
  {
    title: 'Sacraments & Ordinances',
    icon: GlobeAltIcon,
    color: 'bg-blue-500',
    topics: [
      { name: 'Communion', count: 67, slug: 'communion' },
      { name: 'Baptism', count: 45, slug: 'baptism' },
      { name: 'Wedding', count: 34, slug: 'wedding' },
      { name: 'Funeral', count: 29, slug: 'funeral' },
      { name: 'Dedication', count: 23, slug: 'dedication' },
      { name: 'Ordination', count: 18, slug: 'ordination' },
    ]
  },
  {
    title: 'Theological Themes',
    icon: TagIcon,
    color: 'bg-purple-500',
    topics: [
      { name: 'Second Coming', count: 123, slug: 'second-coming' },
      { name: 'Salvation', count: 156, slug: 'salvation' },
      { name: 'Grace', count: 134, slug: 'grace' },
      { name: 'Faith', count: 98, slug: 'faith' },
      { name: 'Hope', count: 87, slug: 'hope' },
      { name: 'Love', count: 76, slug: 'love' },
      { name: 'Sabbath', count: 65, slug: 'sabbath' },
      { name: 'Prophecy', count: 54, slug: 'prophecy' },
    ]
  },
  {
    title: 'Christian Life',
    icon: HeartIcon,
    color: 'bg-orange-500',
    topics: [
      { name: 'Service', count: 89, slug: 'service' },
      { name: 'Mission', count: 78, slug: 'mission' },
      { name: 'Discipleship', count: 67, slug: 'discipleship' },
      { name: 'Stewardship', count: 56, slug: 'stewardship' },
      { name: 'Witnessing', count: 45, slug: 'witnessing' },
      { name: 'Fellowship', count: 34, slug: 'fellowship' },
    ]
  },
  {
    title: 'Comfort & Encouragement',
    icon: HeartIcon,
    color: 'bg-teal-500',
    topics: [
      { name: 'Comfort', count: 98, slug: 'comfort' },
      { name: 'Peace', count: 87, slug: 'peace' },
      { name: 'Strength', count: 76, slug: 'strength' },
      { name: 'Guidance', count: 65, slug: 'guidance' },
      { name: 'Trust', count: 54, slug: 'trust' },
      { name: 'Assurance', count: 43, slug: 'assurance' },
    ]
  },
];

export default async function TopicsPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center text-white">
              <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
                Browse by Topic
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore hymns organized by themes and topics to find the perfect songs for worship, study, or personal reflection
              </p>
            </div>
          </div>
        </div>

        {/* Topic Categories */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="space-y-12">
            {topicCategories.map((category) => (
              <div key={category.title} className="bg-white rounded-xl shadow-sm p-8">
                <div className="flex items-center mb-6">
                  <div className={`${category.color} p-3 rounded-lg mr-4`}>
                    <category.icon className="h-6 w-6 text-white" />
                  </div>
                  <h2 className="text-2xl font-bold text-gray-900">{category.title}</h2>
                </div>
                
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {category.topics.map((topic) => (
                    <Link
                      key={topic.slug}
                      href={`/search?topic=${topic.slug}`}
                      className="group relative rounded-lg border border-gray-200 bg-white p-4 hover:border-primary-300 hover:shadow-md transition-all duration-200"
                    >
                      <div className="flex items-center justify-between">
                        <div>
                          <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                            {topic.name}
                          </h3>
                          <p className="text-sm text-gray-600 mt-1">
                            {topic.count} hymns
                          </p>
                        </div>
                        <div className="flex-shrink-0">
                          <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center group-hover:bg-primary-100 transition-colors">
                            <TagIcon className="h-4 w-4 text-gray-600 group-hover:text-primary-600" />
                          </div>
                        </div>
                      </div>
                      <div className="absolute inset-0 bg-primary-50 opacity-0 group-hover:opacity-10 transition-opacity rounded-lg" />
                    </Link>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Search by Topic */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                Can&apos;t find what you&apos;re looking for?
              </h2>
              <p className="text-gray-600 mb-8">
                Use our search to find hymns by any topic, theme, or keyword
              </p>
              <Link
                href="/search"
                className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <TagIcon className="h-5 w-5 mr-2" />
                Search All Topics
              </Link>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}