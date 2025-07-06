const { loadHymnalReferences, loadHymnalHymns } = require('./src/lib/data-server.ts');

async function testPDFData() {
  try {
    console.log('Loading hymnal references...');
    const hymnalReferences = await loadHymnalReferences();
    
    const hymnal = hymnalReferences.hymnals['HGPP'];
    console.log('Hymnal:', hymnal);
    
    console.log('Loading hymns...');
    const { hymns, totalHymns } = await loadHymnalHymns('HGPP', 1, 10);
    console.log(`Loaded ${hymns.length} of ${totalHymns} hymns`);
    
    if (hymns.length > 0) {
      console.log('Sample hymn:', JSON.stringify(hymns[0], null, 2));
    }
    
  } catch (error) {
    console.error('Error:', error);
  }
}

testPDFData();