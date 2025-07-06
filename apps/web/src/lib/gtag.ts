// Google Analytics configuration
export const GA_TRACKING_ID = process.env.NEXT_PUBLIC_GA_ID;

// https://developers.google.com/analytics/devguides/collection/gtagjs/pages
export const pageview = (url: string) => {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('config', GA_TRACKING_ID!, {
      page_location: url,
    });
  }
};

// https://developers.google.com/analytics/devguides/collection/gtagjs/events
export const event = ({
  action,
  category,
  label,
  value,
}: {
  action: string;
  category: string;
  label?: string;
  value?: number;
}) => {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', action, {
      event_category: category,
      event_label: label,
      value: value,
    });
  }
};

// Track hymn views
export const trackHymnView = (hymnId: string, hymnTitle: string, hymnal: string) => {
  event({
    action: 'view_hymn',
    category: 'Hymns',
    label: `${hymnal}: ${hymnTitle}`,
  });
};

// Track search queries
export const trackSearch = (query: string, resultsCount: number) => {
  event({
    action: 'search',
    category: 'Search',
    label: query,
    value: resultsCount,
  });
};

// Track PDF downloads
export const trackPdfDownload = (hymnalId: string, hymnalName: string) => {
  event({
    action: 'download_pdf',
    category: 'Downloads',
    label: `${hymnalId}: ${hymnalName}`,
  });
};

// Track navigation to browse pages
export const trackBrowse = (category: string, filter?: string) => {
  event({
    action: 'browse',
    category: 'Navigation',
    label: filter ? `${category}: ${filter}` : category,
  });
};