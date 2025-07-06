import Link from 'next/link';
import { 
  MusicalNoteIcon,
  HeartIcon,
  EnvelopeIcon,
  BookOpenIcon,
  GlobeAltIcon,
  AcademicCapIcon
} from '@heroicons/react/24/outline';

export default function Footer() {
  const navigation = {
    hymnals: [
      { name: 'Seventh-day Adventist Hymnal', href: '/seventh-day-adventist-hymnal' },
      { name: 'Christ in Song', href: '/christ-in-song' },
      { name: 'Church Hymnal', href: '/church-hymnal' },
      { name: 'Nyimbo za Kristo', href: '/nyimbo-za-kristo' },
      { name: 'View All Collections', href: '/hymnals' },
    ],
    tools: [
      { name: 'Search Hymns', href: '/search' },
      { name: 'Browse by Topic', href: '/topics' },
      { name: 'Composers Index', href: '/composers' },
      { name: 'Metrical Index', href: '/meters' },
      { name: 'Compare Hymnals', href: '/compare' },
    ],
    about: [
      { name: 'About the Project', href: '/about' },
      { name: 'Contributing', href: '/contribute' },
      { name: 'Academic Resources', href: '/academic' },
      { name: 'API Documentation', href: '/api-docs' },
      { name: 'Contact Us', href: '/contact' },
    ],
    legal: [
      { name: 'Privacy Policy', href: '/privacy' },
      { name: 'Terms of Service', href: '/terms' },
      { name: 'Copyright Information', href: '/copyright' },
      { name: 'Attribution', href: '/attribution' },
    ],
  };

  const social = [
    {
      name: 'GitHub',
      href: 'https://github.com/adventhymnals',
      icon: (props: React.SVGProps<SVGSVGElement>) => (
        <svg fill="currentColor" viewBox="0 0 24 24" {...props}>
          <path
            fillRule="evenodd"
            d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
            clipRule="evenodd"
          />
        </svg>
      ),
    },
    {
      name: 'YouTube',
      href: 'https://www.youtube.com/@adventhymnals',
      icon: (props: React.SVGProps<SVGSVGElement>) => (
        <svg fill="currentColor" viewBox="0 0 24 24" {...props}>
          <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
        </svg>
      ),
    },
    {
      name: 'Email',
      href: 'mailto:editor@gospelsounders.org',
      icon: (props: React.SVGProps<SVGSVGElement>) => (
        <EnvelopeIcon {...props} />
      ),
    },
  ];

  const stats = [
    { label: 'Hymnal Collections', value: '13' },
    { label: 'Total Hymns', value: '5,500+' },
    { label: 'Years of Heritage', value: '160+' },
    { label: 'Languages', value: '3' },
  ];

  return (
    <footer className="bg-gray-900" aria-labelledby="footer-heading">
      <h2 id="footer-heading" className="sr-only">
        Footer
      </h2>

      {/* Stats Section */}
      <div className="border-b border-gray-800">
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <dl className="grid grid-cols-2 gap-8 lg:grid-cols-4">
            {stats.map((stat) => (
              <div key={stat.label} className="text-center">
                <dt className="text-sm font-medium text-gray-400">{stat.label}</dt>
                <dd className="text-2xl font-bold text-white">{stat.value}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>

      {/* Main Footer Content */}
      <div className="mx-auto max-w-7xl px-6 pb-8 pt-16 sm:pt-24 lg:px-8 lg:pt-32">
        <div className="xl:grid xl:grid-cols-3 xl:gap-8">
          {/* Brand Section */}
          <div className="space-y-8">
            <Link href="/" className="flex items-center space-x-2">
              <MusicalNoteIcon className="h-8 w-8 text-primary-400" />
              <div className="text-xl font-bold text-white">
                Advent Hymnals
              </div>
            </Link>
            <p className="text-sm leading-6 text-gray-300">
              Preserving 160+ years of Adventist hymnody heritage through digital technology. 
              Making the rich musical tradition of the Seventh-day Adventist Church accessible 
              to congregations, researchers, and music enthusiasts worldwide.
            </p>
            <div className="flex space-x-6">
              {social.map((item) => (
                <a
                  key={item.name}
                  href={item.href}
                  className="text-gray-400 hover:text-gray-300 transition-colors duration-200"
                  target={item.href.startsWith('http') ? '_blank' : undefined}
                  rel={item.href.startsWith('http') ? 'noopener noreferrer' : undefined}
                >
                  <span className="sr-only">{item.name}</span>
                  <item.icon className="h-6 w-6" aria-hidden="true" />
                </a>
              ))}
            </div>
          </div>

          {/* Navigation Links */}
          <div className="mt-16 grid grid-cols-2 gap-8 xl:col-span-2 xl:mt-0">
            <div className="md:grid md:grid-cols-2 md:gap-8">
              <div>
                <h3 className="flex items-center text-sm font-semibold leading-6 text-white">
                  <BookOpenIcon className="mr-2 h-4 w-4" />
                  Hymnal Collections
                </h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.hymnals.map((item) => (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className="text-sm leading-6 text-gray-300 hover:text-white transition-colors duration-200"
                      >
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
              <div className="mt-10 md:mt-0">
                <h3 className="flex items-center text-sm font-semibold leading-6 text-white">
                  <GlobeAltIcon className="mr-2 h-4 w-4" />
                  Tools & Features
                </h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.tools.map((item) => (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className="text-sm leading-6 text-gray-300 hover:text-white transition-colors duration-200"
                      >
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
            <div className="md:grid md:grid-cols-2 md:gap-8">
              <div>
                <h3 className="flex items-center text-sm font-semibold leading-6 text-white">
                  <AcademicCapIcon className="mr-2 h-4 w-4" />
                  About & Support
                </h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.about.map((item) => (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className="text-sm leading-6 text-gray-300 hover:text-white transition-colors duration-200"
                      >
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
              <div className="mt-10 md:mt-0">
                <h3 className="text-sm font-semibold leading-6 text-white">Legal</h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.legal.map((item) => (
                    <li key={item.name}>
                      <Link
                        href={item.href}
                        className="text-sm leading-6 text-gray-300 hover:text-white transition-colors duration-200"
                      >
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Section */}
        <div className="mt-16 border-t border-gray-700 pt-8 sm:mt-20 lg:mt-24">
          <div className="flex flex-col items-center justify-between lg:flex-row">
            <div className="flex items-center space-x-4 text-xs text-gray-400">
              <p>&copy; 2024 Advent Hymnals Project. Content used under fair use for educational purposes.</p>
            </div>
            <div className="mt-4 flex items-center space-x-2 lg:mt-0">
              <HeartIcon className="h-4 w-4 text-red-500" />
              <span className="text-xs text-gray-400">
                Made with love for the global Adventist community
              </span>
            </div>
          </div>
          <div className="mt-4 text-center">
            <p className="text-xs text-gray-500">
              This is an independent project not officially affiliated with the Seventh-day Adventist Church. 
              Hymnal content is used for educational and research purposes.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}