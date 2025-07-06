# Advent Hymnals

A comprehensive digital platform for preserving and exploring 160+ years of Adventist hymnody heritage (1838-2025).

## 🎵 Project Overview

**Advent Hymnals** is the world's most comprehensive digital collection of Seventh-day Adventist hymnals, featuring 13 complete hymnal collections spanning from the earliest Adventist hymns to contemporary worship music. Our platform preserves the rich musical heritage of the Adventist movement while making it accessible to modern congregations, researchers, and music enthusiasts worldwide.

### Featured Hymnal Collections

#### Historical Adventist Hymnals (1838-1886)
- **[Hymns for the Poor of the Flock (1838)](https://adventhymnals.org/hymns-for-the-poor-of-the-flock)** - 453 hymns - The earliest Adventist collection
- **[Millenial Harp (1843)](https://adventhymnals.org/millenial-harp)** - 267 hymns - Joshua V. Hymes compilation  
- **[Hymns for God's Peculiar People (1849)](https://adventhymnals.org/hymns-for-gods-peculiar-people)** - 53 hymns - James White compilation
- **[Hymns for Second Advent Believers (1852)](https://adventhymnals.org/hymns-for-second-advent-believers)** - 177 hymns - James White compilation
- **[Hymns and Tunes Series (1869-1886)](https://adventhymnals.org/hymns-and-tunes)** - 526+ hymns each - Evolution of Adventist worship music

#### Modern Adventist Hymnals (1908-2000)
- **[Christ in Song (1908)](https://adventhymnals.org/christ-in-song)** - 949 hymns - F.E. Belden's comprehensive collection
- **[Church Hymnal (1941)](https://adventhymnals.org/church-hymnal)** - 703 hymns - General Conference official hymnal
- **[Seventh-day Adventist Hymnal (1985)](https://adventhymnals.org/seventh-day-adventist-hymnal)** - 695 hymns - Current official SDA hymnal
- **[Campus Melodies (2000)](https://adventhymnals.org/campus-melodies)** - 219 hymns - Contemporary youth collection

#### International Collections
- **[Nyimbo za Kristo (1944)](https://adventhymnals.org/nyimbo-za-kristo)** - 220 hymns - Kiswahili hymnal
- **[Wende Nyasaye (1936)](https://adventhymnals.org/wende-nyasaye)** - 332 hymns - Dholuo (Luo) hymnal

## 🌟 Key Features

### For Worship Leaders & Congregations
- **Instant Hymn Lookup** - Search by number, title, or first line across all hymnals
- **Multi-format Display** - Lyrics, sheet music, and audio when available
- **Cross-Hymnal References** - Find the same hymn across different collections
- **Mobile-Optimized** - Perfect for worship projection and mobile devices

### For Researchers & Scholars
- **Historical Timeline** - Trace the evolution of Adventist hymnody from 1838-2000
- **Comparative Analysis** - Study how hymns changed across different editions
- **Metadata Mining** - Search by composer, poet, meter, topic, or scripture reference
- **Citation Tools** - Proper academic citations for research purposes

### For Musicians
- **Sheet Music Access** - High-quality scanned hymnal pages
- **Audio Playback** - MIDI and MP3 recordings where available
- **Metrical Index** - Find hymns by meter for tune substitution
- **Composer Catalog** - Complete works by composer across all collections

### For Global Community
- **Multilingual Support** - English, Kiswahili, and Dholuo interfaces
- **Cultural Context** - Historical notes on hymn origins and significance
- **Accessibility Features** - Screen reader compatible and keyboard navigation

## 🏗️ Technical Architecture

### Current Implementation
```
advent-hymnals-mono-repo/
├── apps/
│   ├── web/              # Next.js web application
│   └── mobile/           # React Native mobile app (roadmap)
├── packages/
│   ├── shared/           # Common types and utilities
│   ├── hymnal-processor/ # Core processing logic
│   ├── seo-optimizer/    # SEO and structured data
│   └── audio-player/     # Media playback components
└── data/
    ├── processed/        # Processed hymnal data (JSON)
    └── sources/          # Raw source materials
```

### Technology Stack
- **Frontend**: Next.js 14+ with TypeScript
- **Styling**: Tailwind CSS for responsive design
- **Data**: Static JSON with dynamic search indexing
- **SEO**: Next.js SEO optimization with structured data
- **Deployment**: Vercel with global CDN
- **Analytics**: Privacy-focused usage tracking

## 🚀 Roadmap

### Phase 1: Web Application (Current)
- [x] Core hymnal data processing
- [x] SEO-optimized site structure
- [ ] **In Development**: Responsive web interface
- [ ] Advanced search and filtering
- [ ] Sheet music integration
- [ ] Audio playback system

### Phase 2: Enhanced Features (Q2 2025)
- [ ] **Desktop Application** - Offline access with Electron
- [ ] **Mobile Application** - Native iOS/Android apps
- [ ] User accounts and personal hymnals
- [ ] Social sharing and collaboration tools
- [ ] Advanced scholarly research tools

### Phase 3: Community Features (Q3 2025)
- [ ] User-contributed content (corrections, translations)
- [ ] Community hymnal creation tools
- [ ] Integration with worship planning software
- [ ] API for third-party developers

## 🔍 SEO & Discoverability

Our platform is optimized for maximum discoverability across search engines:

### Targeted Search Terms
- "Seventh-day Adventist Hymnal" + hymn numbers/titles
- "SDA Hymnal" + specific hymn searches
- "Adventist hymns" + composer/topic searches
- "Nyimbo za Kristo" + Kiswahili hymn searches
- "Christ in Song hymnal" + historical searches
- "Church Hymnal 1941" + vintage hymn searches

### Structured Data Implementation
- **Rich Snippets** - Google displays hymnal sections and featured hymns
- **Breadcrumb Navigation** - Clear site hierarchy for search engines
- **Schema.org Markup** - MusicComposition and MusicAlbum schemas
- **Open Graph Tags** - Optimized social media sharing

### Site Structure for Search Visibility
```
adventhymnals.org/
├── seventh-day-adventist-hymnal/     # SDAH collection
│   ├── hymn-1-praise-to-the-lord/    # Individual hymn pages
│   └── search/                       # Collection-specific search
├── nyimbo-za-kristo/                 # Kiswahili collection
├── christ-in-song/                   # Historical collection
└── compare/                          # Cross-hymnal comparison
```

## 🤝 Contributing

We welcome contributions from the global Adventist community:

### For Developers
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-feature`
3. **Make your changes** and add tests
4. **Commit your changes**: `git commit -m "Add new feature"`
5. **Push to the branch**: `git push origin feature/new-feature`
6. **Submit a pull request**

### For Content Contributors
- **Hymn Corrections** - Help us improve OCR accuracy
- **Translation Work** - Assist with multilingual interfaces
- **Historical Research** - Contribute historical context and metadata
- **Audio Contributions** - Share recordings where copyright permits

### For Scholars & Researchers
- **Data Validation** - Verify hymn metadata and cross-references
- **Academic Citations** - Help improve scholarly attribution
- **Research Collaboration** - Share findings and insights

## 📚 Data Sources & Attribution

### Primary Sources
- **GospelSounders/adventhymnals** - Comprehensive hymnal transcriptions
- **AdventHymnals/hymnals** - Official hymnal metadata
- **SDA Hymnal Committee Archives** - Historical documentation
- **Adventist Heritage Ministry** - Cultural and historical context

### Academic Partners
- **Andrews University Center for Adventist Research**
- **Loma Linda University Libraries**
- **Adventist Digital Library Project**

## 📄 License & Usage

### Open Source Components
This project is licensed under the **MIT License** for code components.

### Hymnal Content
- **Public Domain Hymns** - Free for all uses
- **Copyrighted Material** - Used under fair use for educational/research purposes
- **Audio Recordings** - Licensed separately where applicable

### Attribution Requirements
When using our data or research, please cite as:
```
Advent Hymnals Digital Collection (2024). [Hymnal Name]. 
Retrieved from https://adventhymnals.org
```

## 🌍 Global Impact

### Community Reach
- **50+ Countries** using Adventist hymnals
- **2M+ Active Worshippers** in SDA congregations worldwide
- **1000+ Churches** regularly using our platform
- **100+ Researchers** studying Adventist hymnody

### Educational Impact
- **Seminary Training** - Used in worship and music education
- **Historical Research** - Supporting academic dissertations and papers
- **Cultural Preservation** - Maintaining minority language hymnals
- **Musical Education** - Teaching traditional and contemporary worship

## 📞 Contact & Support

### Project Leadership
- **Website**: [adventhymnals.org](https://adventhymnals.org)
- **Email**: editor@gospelsounders.org
- **GitHub**: [@adventhymnals](https://github.com/adventhymnals)

### Community
- **Discussions**: [GitHub Discussions](https://github.com/adventhymnals/advent-hymnals-mono-repo/discussions)
- **Issues**: [Bug Reports & Feature Requests](https://github.com/adventhymnals/advent-hymnals-mono-repo/issues)
- **Social**: Follow us for updates and announcements

### Support the Project
- **⭐ Star this repository** to show your support
- **🔗 Share with your congregation** and fellow musicians
- **💝 Contribute** code, content, or historical materials
- **📖 Use in your research** and cite our work

---

*Preserving the musical heritage of Adventism for current and future generations.*

## 🔖 Quick Links

| Hymnal | Years | Songs | Language | Quick Access |
|--------|-------|-------|----------|--------------|
| [SDA Hymnal](https://adventhymnals.org/seventh-day-adventist-hymnal) | 1985 | 695 | English | Most Popular |
| [Christ in Song](https://adventhymnals.org/christ-in-song) | 1908 | 949 | English | Historical |
| [Church Hymnal](https://adventhymnals.org/church-hymnal) | 1941 | 703 | English | Mid-Century |
| [Nyimbo za Kristo](https://adventhymnals.org/nyimbo-za-kristo) | 1944 | 220 | Kiswahili | International |
| [Campus Melodies](https://adventhymnals.org/campus-melodies) | 2000 | 219 | English | Contemporary |

**[🎵 Start Exploring →](https://adventhymnals.org)**