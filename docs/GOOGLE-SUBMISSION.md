# Google Search Console Submission Guide

This guide explains how to submit your Advent Hymnals website to Google Search Console for better search engine visibility.

## Prerequisites

- Your website must be live and accessible
- You need a Google account
- Access to your website's files or DNS settings

## Step 1: Access Google Search Console

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Sign in with your Google account
3. Click "Add a property"

## Step 2: Choose Property Type

You can add your property in two ways:

### Option A: Domain Property (Recommended)
- Enter your domain: `adventhymnals.org`
- This covers all subdomains and protocols (http/https)
- Requires DNS verification

### Option B: URL Prefix Property
- Enter your full URL: `https://adventhymnals.org`
- Only covers the exact URL entered
- Multiple verification methods available

## Step 3: Verify Ownership

### Method 1: HTML File Upload (Easiest for developers)

1. Download the verification file provided by Google
2. Upload it to your website's root directory
3. Make sure it's accessible at: `https://adventhymnals.org/google[code].html`
4. Click "Verify" in Search Console

### Method 2: HTML Meta Tag (Already Implemented)

The website already includes the verification meta tag in the layout:

```html
<meta name="google-site-verification" content="[YOUR_VERIFICATION_CODE]" />
```

To use this method:
1. Get your verification code from Google Search Console
2. Add it to your environment variables:
   ```bash
   GOOGLE_VERIFICATION=your-verification-code-here
   ```
3. Redeploy your application
4. Click "Verify" in Search Console

### Method 3: DNS Record (For domain property)

1. Add a TXT record to your domain's DNS:
   ```
   Name: @
   Type: TXT  
   Value: google-site-verification=[verification-code]
   ```
2. Wait for DNS propagation (up to 24 hours)
3. Click "Verify" in Search Console

## Step 4: Submit Your Sitemap

Once verified, submit your sitemap for better indexing:

1. In Search Console, go to "Sitemaps" in the left menu
2. Enter your sitemap URL: `https://adventhymnals.org/sitemap.xml`
3. Click "Submit"

The website automatically generates a sitemap at `/api/sitemap`.

## Step 5: Monitor Your Website

### Key Metrics to Watch

1. **Coverage**: Shows which pages are indexed
2. **Performance**: Search appearance and click data
3. **Enhancements**: Core Web Vitals and usability
4. **Security & Manual Actions**: Issues that affect rankings

### Important Pages to Monitor

- `/` (Homepage)
- `/[hymnal]` (Hymnal pages)
- `/[hymnal]/hymn-[number]-[title]` (Individual hymn pages)
- `/meters`, `/tunes`, `/themes`, `/authors`, `/composers` (Browse pages)

## Step 6: Request Indexing (Optional)

For faster indexing of new content:

1. Go to "URL Inspection" in Search Console
2. Enter the URL you want indexed
3. Click "Request Indexing" if the page isn't already indexed

## Step 7: Set Up Analytics Integration

Connect Google Search Console with Google Analytics:

1. In Google Analytics, go to Admin → Property Settings
2. Click "Link Search Console"
3. Select your Search Console property
4. Complete the linking process

## Common Issues and Solutions

### Verification Failed
- **DNS/HTML file**: Check if the verification file/record is accessible
- **Meta tag**: Ensure the tag is in the `<head>` section
- **Cache**: Clear browser cache and try again

### Pages Not Indexed
- Check `robots.txt`: `https://adventhymnals.org/robots.txt`
- Verify sitemap submission
- Check for crawl errors in Coverage report

### Low Performance
- Monitor Core Web Vitals
- Check mobile usability
- Optimize page loading speeds

## Best Practices

### 1. Regular Monitoring
- Check Search Console weekly
- Monitor new crawl errors
- Track ranking changes

### 2. Content Optimization
- Ensure all hymn pages have unique titles and descriptions
- Use structured data for hymn information
- Keep content fresh and updated

### 3. Technical SEO
- Maintain clean URL structure
- Ensure mobile responsiveness
- Optimize page loading speed
- Use HTTPS everywhere

### 4. Sitemap Maintenance
- Keep sitemaps updated automatically
- Include all important pages
- Remove broken or redirected URLs

## Structured Data Implementation

Consider adding structured data for better search results:

```json
{
  "@context": "https://schema.org",
  "@type": "MusicComposition",
  "name": "Hymn Title",
  "composer": "Composer Name",
  "lyricist": "Author Name",
  "genre": "Hymn",
  "datePublished": "Year",
  "inLanguage": "en"
}
```

## Monitoring Tools

### Google Search Console Reports
- **Performance**: Query rankings and impressions
- **Coverage**: Index status and errors
- **Core Web Vitals**: Page experience metrics
- **Mobile Usability**: Mobile-specific issues

### Additional Tools
- **PageSpeed Insights**: Performance analysis
- **Mobile-Friendly Test**: Mobile compatibility
- **Rich Results Test**: Structured data validation

## Troubleshooting

### Common Error Messages

1. **"Submitted URL not found (404)"**
   - Check if the page exists and is accessible
   - Verify URL format in sitemap

2. **"Server error (5xx)"**
   - Check server logs for errors
   - Ensure website is properly deployed

3. **"Redirect error"**
   - Check for redirect loops
   - Ensure proper HTTPS redirects

4. **"Blocked by robots.txt"**
   - Review robots.txt configuration
   - Ensure important pages aren't blocked

### Getting Help

- [Google Search Console Help Center](https://support.google.com/webmasters)
- [Google Search Central Documentation](https://developers.google.com/search)
- [Webmaster Guidelines](https://developers.google.com/search/docs/essentials)

## Success Metrics

Track these metrics to measure SEO success:

1. **Organic Traffic Growth**: Increase in search-driven visits
2. **Keyword Rankings**: Positions for hymn-related searches
3. **Index Coverage**: Percentage of pages successfully indexed
4. **Core Web Vitals**: Page experience scores
5. **Click-Through Rate**: Search result click rates

Remember: SEO is a long-term strategy. It may take several weeks to see significant results after implementation.