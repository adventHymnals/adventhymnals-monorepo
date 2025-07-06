import Link from 'next/link';
import { ChevronRightIcon, HomeIcon } from '@heroicons/react/24/outline';
import { BreadcrumbItem } from '@advent-hymnals/shared';
import { classNames } from '@advent-hymnals/shared';

interface BreadcrumbsProps {
  items: BreadcrumbItem[];
  className?: string;
}

export default function Breadcrumbs({ items, className }: BreadcrumbsProps) {
  if (!items.length) return null;

  return (
    <nav className={classNames('flex', className)} aria-label="Breadcrumb">
      <ol role="list" className="flex items-center space-x-2">
        {/* Home icon */}
        <li>
          <div>
            <Link
              href="/"
              className="text-gray-400 hover:text-gray-500 transition-colors duration-200"
            >
              <HomeIcon className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
              <span className="sr-only">Home</span>
            </Link>
          </div>
        </li>

        {/* Breadcrumb items */}
        {items.map((item) => (
          <li key={item.label}>
            <div className="flex items-center">
              <ChevronRightIcon
                className="h-4 w-4 flex-shrink-0 text-gray-400"
                aria-hidden="true"
              />
              {item.href && !item.current ? (
                <Link
                  href={item.href}
                  className="ml-2 text-sm font-medium text-gray-500 hover:text-gray-700 transition-colors duration-200"
                >
                  {item.label}
                </Link>
              ) : (
                <span
                  className={classNames(
                    'ml-2 text-sm font-medium',
                    item.current
                      ? 'text-gray-900'
                      : 'text-gray-500'
                  )}
                  aria-current={item.current ? 'page' : undefined}
                >
                  {item.label}
                </span>
              )}
            </div>
          </li>
        ))}
      </ol>
    </nav>
  );
}

// Utility function to generate common breadcrumb patterns
export function generateHymnalBreadcrumbs(
  hymnalName: string,
  hymnalSlug: string,
  hymnTitle?: string,
  hymnNumber?: number
): BreadcrumbItem[] {
  const breadcrumbs: BreadcrumbItem[] = [
    {
      label: 'Hymnals',
      href: '/hymnals'
    },
    {
      label: hymnalName,
      href: `/${hymnalSlug}`
    }
  ];

  if (hymnTitle && hymnNumber) {
    breadcrumbs.push({
      label: `${hymnNumber}. ${hymnTitle}`,
      current: true
    });
  }

  return breadcrumbs;
}

export function generateSearchBreadcrumbs(
  query?: string,
  hymnalName?: string,
  hymnalSlug?: string
): BreadcrumbItem[] {
  const breadcrumbs: BreadcrumbItem[] = [
    {
      label: 'Search',
      href: '/search'
    }
  ];

  if (hymnalName && hymnalSlug) {
    breadcrumbs.push({
      label: hymnalName,
      href: `/${hymnalSlug}/search`
    });
  }

  if (query) {
    breadcrumbs.push({
      label: `"${query}"`,
      current: true
    });
  }

  return breadcrumbs;
}

export function generateTopicBreadcrumbs(
  topic: string,
  hymnalName?: string,
  hymnalSlug?: string
): BreadcrumbItem[] {
  const breadcrumbs: BreadcrumbItem[] = [
    {
      label: 'Topics',
      href: '/topics'
    }
  ];

  if (hymnalName && hymnalSlug) {
    breadcrumbs.push({
      label: hymnalName,
      href: `/${hymnalSlug}`
    });
  }

  breadcrumbs.push({
    label: topic.charAt(0).toUpperCase() + topic.slice(1),
    current: true
  });

  return breadcrumbs;
}