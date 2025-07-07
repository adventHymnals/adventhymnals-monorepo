'use client';

import { useState, useEffect } from 'react';
import {
    ChevronLeftIcon,
    ChevronRightIcon,
    PhotoIcon,
    ArrowLeftIcon,
    ArrowRightIcon,
    ExclamationTriangleIcon,
    PlusIcon,
    TrashIcon,
    XMarkIcon
} from '@heroicons/react/24/outline';
import Link from 'next/link';
import CloseButton from '@/components/ui/CloseButton';

interface HymnEditViewProps {
    hymn: any;
    hymnalRef: any;
    allHymns: any[];
    params: {
        hymnal: string;
        slug: string;
    };
}

// Generate slug from hymn title
function generateHymnSlug(number: number, title: string): string {
    const cleanTitle = title
        .toLowerCase()
        .replace(/[^\w\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .trim();
    return `hymn-${number}-${cleanTitle}`;
}

export default function HymnEditView({ hymn, hymnalRef, allHymns, params }: HymnEditViewProps) {
    const [currentHymnIndex, setCurrentHymnIndex] = useState(0);
    const [currentImageIndex, setCurrentImageIndex] = useState(0);
    const [availableImages, setAvailableImages] = useState<number[]>([]);
    const [imageError, setImageError] = useState<Set<number>>(new Set());

    // Inline editing state
    const [editingVerse, setEditingVerse] = useState<number | null>(null);
    const [editingChorus, setEditingChorus] = useState(false);
    const [editingField, setEditingField] = useState<string | null>(null); // title, author, composer, tune, meter
    const [editedText, setEditedText] = useState<string>('');

    // Local hymn data for editing
    const [localHymn, setLocalHymn] = useState(hymn);

    // Image fallback state
    const [currentImageSrc, setCurrentImageSrc] = useState<string | null>(null);
    const [imageSourceIndex, setImageSourceIndex] = useState(0);

    // Find current hymn index
    useEffect(() => {
        const index = allHymns.findIndex(h => h.number === hymn.number);
        setCurrentHymnIndex(index >= 0 ? index : 0);
    }, [hymn.number, allHymns]);

    // Load available images for the hymnal
    useEffect(() => {
        const loadImages = async () => {
            try {
                // This is a simplified approach - in a real implementation,
                // you'd have an API endpoint that lists available images
                const images: number[] = [];

                // For CH1941, images are numbered 001.png, 002.png, etc.
                // For CS1900, images are page-001.png, page-002.png, etc.
                let maxImages = 700; // Reasonable limit for testing
                if (hymnalRef.id === 'CH1941') maxImages = 633;
                if (hymnalRef.id === 'CS1900') maxImages = 322;

                for (let i = 1; i <= maxImages; i++) {
                    images.push(i);
                }

                setAvailableImages(images);

                // Try to find an image close to the hymn number
                const startImage = Math.max(1, hymn.number - 5);
                const imageIndex = images.findIndex(img => img >= startImage);
                setCurrentImageIndex(imageIndex >= 0 ? imageIndex : 0);
            } catch (error) {
                console.error('Error loading images:', error);
            }
        };

        loadImages();
    }, [hymnalRef.id, hymn.number]);

    // Image naming configuration for each hymnal
    const getImageConfig = (hymnalId: string) => {
        const configs: Record<string, { prefix?: string; padding: number; includeUnpadded?: boolean }> = {
            'SDAH': { padding: 3, includeUnpadded: true },
            'CH1941': { padding: 3 },
            'CS1900': { prefix: 'page-', padding: 3 },
            'HGPP': { prefix: 'page-', padding: 2 },
            'HSAB': { padding: 0 },
        };
        return configs[hymnalId] || { padding: 3 };
    };

    const generateImageSources = (imageNum: number, hymnalId: string) => {
        const config = getImageConfig(hymnalId);
        const imageSources = [];
        
        // Use different base URLs for development vs production/static export
        const isDevelopment = process.env.NODE_ENV === 'development';
        let baseDir: string;
        
        if (isDevelopment) {
            // Development: use local API route
            baseDir = `/data/sources/images/${hymnalId}`;
        } else {
            // Production/Static export: use external GitHub URLs
            const resourceUrls: Record<string, string> = {
                'SDAH': 'https://raw.githubusercontent.com/GospelSounders/SDAHData/master/SDAHymnalsPhotos',
                'CH1941': 'https://raw.githubusercontent.com/GospelSounders/CHData/master/ChurchHymnalImages',
                'CS1900': 'https://raw.githubusercontent.com/GospelSounders/christ-in-song-pdfs/master/splitFiles',
            };
            baseDir = resourceUrls[hymnalId] || `/data/sources/images/${hymnalId}`;
        }

        if (config.padding === 0) {
            // No padding (HSAB: 1.png, 2.png)
            const fileName = `${config.prefix || ''}${imageNum}`;
            imageSources.push(`${baseDir}/${fileName}.png`, `${baseDir}/${fileName}.jpg`);
        } else {
            // With padding
            const paddedNum = imageNum.toString().padStart(config.padding, '0');
            const fileName = `${config.prefix || ''}${paddedNum}`;
            imageSources.push(`${baseDir}/${fileName}.png`, `${baseDir}/${fileName}.jpg`);

            // Also try unpadded version for some hymnals
            if (config.includeUnpadded) {
                const unpaddedFileName = `${config.prefix || ''}${imageNum}`;
                imageSources.push(`${baseDir}/${unpaddedFileName}.png`, `${baseDir}/${unpaddedFileName}.jpg`);
            }
        }

        return imageSources;
    };

    // Load current image with fallback logic
    useEffect(() => {
        const sources = getImageSources();
        if (sources.length > 0) {
            setCurrentImageSrc(sources[0]);
            setImageSourceIndex(0);
        } else {
            setCurrentImageSrc(null);
        }
    }, [currentImageIndex, hymnalRef.id]);

    const getCurrentImage = () => {
        if (availableImages.length === 0) return null;
        const imageNum = availableImages[currentImageIndex];
        const imageSources = generateImageSources(imageNum, hymnalRef.id);
        return imageSources.length > 0 ? imageSources[0] : null;
    };

    // Function to get all possible image sources for fallback
    const getImageSources = () => {
        if (availableImages.length === 0) return [];
        const imageNum = availableImages[currentImageIndex];
        return generateImageSources(imageNum, hymnalRef.id);
    };

    const getImageDisplayNumber = () => {
        if (availableImages.length === 0) return '';
        return availableImages[currentImageIndex];
    };

    const navigateHymn = (direction: 'prev' | 'next') => {
        let newIndex = currentHymnIndex;

        if (direction === 'prev' && currentHymnIndex > 0) {
            newIndex = currentHymnIndex - 1;
        } else if (direction === 'next' && currentHymnIndex < allHymns.length - 1) {
            newIndex = currentHymnIndex + 1;
        }

        if (newIndex !== currentHymnIndex) {
            const targetHymn = allHymns[newIndex];
            const slug = generateHymnSlug(targetHymn.number, targetHymn.title);
            window.location.href = `/${params.hymnal}/${slug}/edit`;
        }
    };

    const navigateImage = (direction: 'prev' | 'next') => {
        if (direction === 'prev' && currentImageIndex > 0) {
            setCurrentImageIndex(currentImageIndex - 1);
        } else if (direction === 'next' && currentImageIndex < availableImages.length - 1) {
            setCurrentImageIndex(currentImageIndex + 1);
        }
    };

    const handleImageError = () => {
        const sources = getImageSources();
        const nextIndex = imageSourceIndex + 1;

        console.log(`Image error for source ${imageSourceIndex}: ${currentImageSrc}`);

        if (nextIndex < sources.length) {
            // Try next fallback source
            console.log(`Trying fallback source ${nextIndex}: ${sources[nextIndex]}`);
            setImageSourceIndex(nextIndex);
            setCurrentImageSrc(sources[nextIndex]);
        } else {
            // All sources failed, mark as error
            console.log(`All ${sources.length} sources failed for image ${availableImages[currentImageIndex]}`);
            setImageError(prev => new Set([...Array.from(prev), availableImages[currentImageIndex]]));
            setCurrentImageSrc(null);
        }
    };

    // Inline editing functions
    const startEditingVerse = (verseNumber: number, currentText: string) => {
        setEditingVerse(verseNumber);
        setEditedText(currentText);
        setEditingField(null);
        setEditingChorus(false);
    };

    const startEditingChorus = (currentText: string) => {
        setEditingChorus(true);
        setEditedText(currentText);
        setEditingField(null);
        setEditingVerse(null);
    };

    const startEditingField = (field: string, currentText: string) => {
        setEditingField(field);
        setEditedText(currentText || '');
        setEditingVerse(null);
        setEditingChorus(false);
    };

    const saveEdit = () => {
        const updatedHymn = { ...localHymn };

        if (editingVerse !== null) {
            // Update verse text
            const verseIndex = updatedHymn.verses.findIndex((v: any) => v.number === editingVerse);
            if (verseIndex >= 0) {
                updatedHymn.verses[verseIndex].text = editedText;
            }
        } else if (editingChorus) {
            // Update chorus text
            if (updatedHymn.chorus) {
                updatedHymn.chorus.text = editedText;
            }
        } else if (editingField) {
            // Update metadata field
            updatedHymn[editingField] = editedText;
        }

        setLocalHymn(updatedHymn);

        // In a real implementation, this would save to a backend
        console.log('Saving edit:', {
            field: editingField,
            verseNumber: editingVerse,
            isChorus: editingChorus,
            newText: editedText
        });

        // Reset editing state
        cancelEdit();
    };

    const cancelEdit = () => {
        setEditingVerse(null);
        setEditingChorus(false);
        setEditingField(null);
        setEditedText('');
    };

    const addVerse = (afterVerseNumber?: number) => {
        const updatedHymn = { ...localHymn };
        const newVerseNumber = afterVerseNumber ? afterVerseNumber + 1 : updatedHymn.verses.length + 1;

        // Shift verse numbers if inserting in middle
        if (afterVerseNumber) {
            updatedHymn.verses.forEach((verse: any) => {
                if (verse.number >= newVerseNumber) {
                    verse.number += 1;
                }
            });
        }

        const newVerse = {
            number: newVerseNumber,
            text: 'New verse text...'
        };

        updatedHymn.verses.push(newVerse);
        updatedHymn.verses.sort((a: any, b: any) => a.number - b.number);

        setLocalHymn(updatedHymn);
        startEditingVerse(newVerseNumber, newVerse.text);
    };

    const deleteVerse = (verseNumber: number) => {
        const updatedHymn = { ...localHymn };
        updatedHymn.verses = updatedHymn.verses.filter((v: any) => v.number !== verseNumber);

        // Renumber remaining verses
        updatedHymn.verses.forEach((verse: any, index: number) => {
            verse.number = index + 1;
        });

        setLocalHymn(updatedHymn);
    };

    const addChorus = () => {
        const updatedHymn = { ...localHymn };
        if (!updatedHymn.chorus) {
            updatedHymn.chorus = { text: 'New chorus text...' };
            setLocalHymn(updatedHymn);
            startEditingChorus(updatedHymn.chorus.text);
        }
    };

    const deleteChorus = () => {
        const updatedHymn = { ...localHymn };
        delete updatedHymn.chorus;
        setLocalHymn(updatedHymn);
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && e.ctrlKey) {
            saveEdit();
        } else if (e.key === 'Escape') {
            cancelEdit();
        }
    };

    const currentImageNum = getImageDisplayNumber();

    return (
        <div className="h-screen flex gap-4 p-4 overflow-hidden">
            {/* Left Panel - Hymn Text with internal scrolling */}
            <div className="w-1/2 bg-white rounded-xl shadow-sm border flex flex-col h-full overflow-hidden">
                {/* Header with Navigation */}
                <div className="flex items-center justify-between p-4 border-b border-gray-200 flex-shrink-0">
                    <div className="flex items-center gap-4">
                        <h2 className="text-lg font-semibold text-gray-900">Edit Hymn</h2>
                        <div className="flex items-center space-x-2">
                            <button
                                onClick={() => navigateHymn('prev')}
                                disabled={currentHymnIndex === 0}
                                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                                title="Previous hymn"
                            >
                                <ChevronLeftIcon className="h-4 w-4" />
                            </button>
                            <span className="text-sm text-gray-600 px-3">
                                {currentHymnIndex + 1} of {allHymns.length}
                            </span>
                            <button
                                onClick={() => navigateHymn('next')}
                                disabled={currentHymnIndex === allHymns.length - 1}
                                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                                title="Next hymn"
                            >
                                <ChevronRightIcon className="h-4 w-4" />
                            </button>
                        </div>
                    </div>
                    <CloseButton />
                </div>

                {/* Hymn Content with custom scrollbar positioned on the right */}
                <div className="flex-1 overflow-y-auto p-6" style={{
                    scrollbarWidth: 'thin',
                    scrollbarColor: '#cbd5e0 #f7fafc'
                }}>
                    {/* Hymn Header - Editable */}
                    <div className="mb-6">
                        {/* Title */}
                        <div className="mb-4">
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1 block">
                                Hymn #{localHymn.number} - Title
                            </label>
                            {editingField === 'title' ? (
                                <div className="relative">
                                    <input
                                        type="text"
                                        value={editedText}
                                        onChange={(e) => setEditedText(e.target.value)}
                                        onKeyDown={handleKeyDown}
                                        className="w-full text-2xl font-bold text-gray-900 border border-primary-300 rounded-lg p-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                        autoFocus
                                    />
                                    <div className="flex items-center justify-end gap-2 mt-2">
                                        <button
                                            onClick={saveEdit}
                                            className="px-3 py-1 bg-primary-600 text-white text-sm rounded hover:bg-primary-700 transition-colors"
                                        >
                                            Save
                                        </button>
                                        <button
                                            onClick={cancelEdit}
                                            className="px-3 py-1 bg-gray-300 text-gray-700 text-sm rounded hover:bg-gray-400 transition-colors"
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </div>
                            ) : (
                                <h1
                                    className="text-2xl font-bold text-gray-900 cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors"
                                    onClick={() => startEditingField('title', localHymn.title)}
                                    title="Click to edit title"
                                >
                                    {localHymn.title}
                                </h1>
                            )}
                        </div>

                        {/* Metadata - Editable */}
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            {/* Author */}
                            <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1 block">Words</label>
                                {editingField === 'author' ? (
                                    <div className="relative">
                                        <input
                                            type="text"
                                            value={editedText}
                                            onChange={(e) => setEditedText(e.target.value)}
                                            onKeyDown={handleKeyDown}
                                            className="w-full text-gray-600 border border-primary-300 rounded p-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                            autoFocus
                                        />
                                        <div className="flex items-center justify-end gap-1 mt-1">
                                            <button onClick={saveEdit} className="px-2 py-1 bg-primary-600 text-white text-xs rounded">Save</button>
                                            <button onClick={cancelEdit} className="px-2 py-1 bg-gray-300 text-gray-700 text-xs rounded">Cancel</button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="text-gray-600 cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors min-h-[2rem] flex items-center"
                                        onClick={() => startEditingField('author', localHymn.author)}
                                        title="Click to edit author"
                                    >
                                        {localHymn.author || 'Click to add author'}
                                    </div>
                                )}
                            </div>

                            {/* Composer */}
                            <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1 block">Music</label>
                                {editingField === 'composer' ? (
                                    <div className="relative">
                                        <input
                                            type="text"
                                            value={editedText}
                                            onChange={(e) => setEditedText(e.target.value)}
                                            onKeyDown={handleKeyDown}
                                            className="w-full text-gray-600 border border-primary-300 rounded p-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                            autoFocus
                                        />
                                        <div className="flex items-center justify-end gap-1 mt-1">
                                            <button onClick={saveEdit} className="px-2 py-1 bg-primary-600 text-white text-xs rounded">Save</button>
                                            <button onClick={cancelEdit} className="px-2 py-1 bg-gray-300 text-gray-700 text-xs rounded">Cancel</button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="text-gray-600 cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors min-h-[2rem] flex items-center"
                                        onClick={() => startEditingField('composer', localHymn.composer)}
                                        title="Click to edit composer"
                                    >
                                        {localHymn.composer || 'Click to add composer'}
                                    </div>
                                )}
                            </div>

                            {/* Tune */}
                            <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1 block">Tune</label>
                                {editingField === 'tune' ? (
                                    <div className="relative">
                                        <input
                                            type="text"
                                            value={editedText}
                                            onChange={(e) => setEditedText(e.target.value)}
                                            onKeyDown={handleKeyDown}
                                            className="w-full text-gray-600 border border-primary-300 rounded p-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                            autoFocus
                                        />
                                        <div className="flex items-center justify-end gap-1 mt-1">
                                            <button onClick={saveEdit} className="px-2 py-1 bg-primary-600 text-white text-xs rounded">Save</button>
                                            <button onClick={cancelEdit} className="px-2 py-1 bg-gray-300 text-gray-700 text-xs rounded">Cancel</button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="text-gray-600 cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors min-h-[2rem] flex items-center"
                                        onClick={() => startEditingField('tune', localHymn.tune)}
                                        title="Click to edit tune"
                                    >
                                        {localHymn.tune || 'Click to add tune'}
                                    </div>
                                )}
                            </div>

                            {/* Meter */}
                            <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1 block">Meter</label>
                                {editingField === 'meter' ? (
                                    <div className="relative">
                                        <input
                                            type="text"
                                            value={editedText}
                                            onChange={(e) => setEditedText(e.target.value)}
                                            onKeyDown={handleKeyDown}
                                            className="w-full text-gray-600 border border-primary-300 rounded p-2 focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                                            autoFocus
                                        />
                                        <div className="flex items-center justify-end gap-1 mt-1">
                                            <button onClick={saveEdit} className="px-2 py-1 bg-primary-600 text-white text-xs rounded">Save</button>
                                            <button onClick={cancelEdit} className="px-2 py-1 bg-gray-300 text-gray-700 text-xs rounded">Cancel</button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="text-gray-600 cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors min-h-[2rem] flex items-center"
                                        onClick={() => startEditingField('meter', localHymn.meter)}
                                        title="Click to edit meter"
                                    >
                                        {localHymn.meter || 'Click to add meter'}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Verses with Add/Delete Controls */}
                    <div className="space-y-4">
                        {localHymn.verses.map((verse: any, index: number) => (
                            <div key={verse.number} className="relative group">
                                {/* Verse Number */}
                                <div className="absolute left-0 top-0 w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                                    <span className="text-sm font-bold text-primary-600">
                                        {verse.number}
                                    </span>
                                </div>

                                {/* Delete Button */}
                                <button
                                    onClick={() => deleteVerse(verse.number)}
                                    className="absolute -right-2 -top-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                                    title="Delete verse"
                                >
                                    <XMarkIcon className="h-3 w-3" />
                                </button>

                                {/* Verse Content */}
                                <div className="ml-12 mr-8">
                                    {editingVerse === verse.number ? (
                                        <div className="relative">
                                            <textarea
                                                value={editedText}
                                                onChange={(e) => setEditedText(e.target.value)}
                                                onKeyDown={handleKeyDown}
                                                className="w-full text-lg leading-relaxed text-gray-800 font-serif border border-primary-300 rounded-lg p-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
                                                rows={4}
                                                autoFocus
                                            />
                                            <div className="flex items-center justify-end gap-2 mt-2">
                                                <button
                                                    onClick={saveEdit}
                                                    className="px-3 py-1 bg-primary-600 text-white text-sm rounded hover:bg-primary-700 transition-colors"
                                                >
                                                    Save (Ctrl+Enter)
                                                </button>
                                                <button
                                                    onClick={cancelEdit}
                                                    className="px-3 py-1 bg-gray-300 text-gray-700 text-sm rounded hover:bg-gray-400 transition-colors"
                                                >
                                                    Cancel (Esc)
                                                </button>
                                            </div>
                                        </div>
                                    ) : (
                                        <div
                                            className="text-lg leading-relaxed text-gray-800 whitespace-pre-line font-serif cursor-pointer hover:bg-gray-50 p-2 rounded transition-colors"
                                            onClick={() => startEditingVerse(verse.number, verse.text)}
                                            title="Click to edit this verse"
                                        >
                                            {verse.text}
                                        </div>
                                    )}
                                </div>

                                {/* Add Verse After Button */}
                                <div className="flex justify-center mt-2">
                                    <button
                                        onClick={() => addVerse(verse.number)}
                                        className="opacity-0 group-hover:opacity-100 transition-opacity px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 flex items-center gap-1"
                                        title="Add verse after this one"
                                    >
                                        <PlusIcon className="h-3 w-3" />
                                        Add Verse
                                    </button>
                                </div>
                            </div>
                        ))}

                        {/* Add New Verse at End */}
                        <div className="flex justify-center pt-4">
                            <button
                                onClick={() => addVerse()}
                                className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 flex items-center gap-2 transition-colors"
                            >
                                <PlusIcon className="h-4 w-4" />
                                Add New Verse
                            </button>
                        </div>
                    </div>

                    {/* Chorus */}
                    {localHymn.chorus ? (
                        <div className="relative mt-8 p-6 bg-primary-50 border-l-4 border-primary-500 rounded-r-lg group">
                            <div className="absolute left-0 top-0 w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center -ml-6 mt-2">
                                <span className="text-sm font-bold text-white">C</span>
                            </div>

                            {/* Delete Chorus Button */}
                            <button
                                onClick={deleteChorus}
                                className="absolute -right-2 -top-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                                title="Delete chorus"
                            >
                                <XMarkIcon className="h-3 w-3" />
                            </button>

                            <div className="ml-6 mr-8">
                                <h3 className="text-lg font-semibold text-primary-900 mb-2">Chorus</h3>
                                {editingChorus ? (
                                    <div className="relative">
                                        <textarea
                                            value={editedText}
                                            onChange={(e) => setEditedText(e.target.value)}
                                            onKeyDown={handleKeyDown}
                                            className="w-full text-lg leading-relaxed text-primary-800 font-serif border border-primary-300 rounded-lg p-3 focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none bg-white"
                                            rows={4}
                                            autoFocus
                                        />
                                        <div className="flex items-center justify-end gap-2 mt-2">
                                            <button
                                                onClick={saveEdit}
                                                className="px-3 py-1 bg-primary-600 text-white text-sm rounded hover:bg-primary-700 transition-colors"
                                            >
                                                Save (Ctrl+Enter)
                                            </button>
                                            <button
                                                onClick={cancelEdit}
                                                className="px-3 py-1 bg-gray-300 text-gray-700 text-sm rounded hover:bg-gray-400 transition-colors"
                                            >
                                                Cancel (Esc)
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="text-lg leading-relaxed text-primary-800 whitespace-pre-line font-serif cursor-pointer hover:bg-primary-100 p-2 rounded transition-colors"
                                        onClick={() => startEditingChorus(localHymn.chorus.text)}
                                        title="Click to edit the chorus"
                                    >
                                        {localHymn.chorus.text}
                                    </div>
                                )}
                            </div>
                        </div>
                    ) : (
                        // Add Chorus Button
                        <div className="flex justify-center mt-8">
                            <button
                                onClick={addChorus}
                                className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 flex items-center gap-2 transition-colors"
                            >
                                <PlusIcon className="h-4 w-4" />
                                Add Chorus
                            </button>
                        </div>
                    )}
                </div>
            </div>

            {/* Right Panel - Images with navigation overlay */}
            <div className="w-1/2 bg-white rounded-xl shadow-sm border flex flex-col h-full relative overflow-hidden">
                {/* Header with just title and page info */}
                <div className="flex items-center justify-between p-4 border-b border-gray-200 flex-shrink-0">
                    <h2 className="text-lg font-semibold text-gray-900 flex items-center">
                        <PhotoIcon className="h-5 w-5 mr-2" />
                        Original Images
                    </h2>
                    <span className="text-sm text-gray-600 px-3">
                        {availableImages.length > 0 ? `Page ${currentImageNum}` : 'Loading...'}
                    </span>
                </div>

                {/* Full width image container with overlay navigation */}
                <div className="flex-1 relative bg-gray-50">
                    {/* Scrollable image area */}
                    <div className="h-full overflow-auto">
                        {currentImageSrc && !imageError.has(availableImages[currentImageIndex]) ? (
                            <img
                                src={currentImageSrc}
                                alt={`${hymnalRef.name} page ${currentImageNum}`}
                                className="w-full h-auto object-contain min-h-full"
                                onError={handleImageError}
                            />
                        ) : imageError.has(availableImages[currentImageIndex]) ? (
                            <div className="h-full flex items-center justify-center">
                                <div className="text-center text-gray-500 p-8">
                                    <ExclamationTriangleIcon className="h-12 w-12 mx-auto mb-4 text-gray-400" />
                                    <p className="text-lg font-medium">Image not available</p>
                                    <p className="text-sm">Page {currentImageNum} could not be loaded from any source</p>
                                </div>
                            </div>
                        ) : (
                            <div className="h-full flex items-center justify-center">
                                <div className="text-center text-gray-500 p-8">
                                    <PhotoIcon className="h-12 w-12 mx-auto mb-4 text-gray-400" />
                                    <p className="text-lg font-medium">No images available</p>
                                    <p className="text-sm">Images for {hymnalRef.name} are not currently available in the repository</p>
                                    <p className="text-xs mt-2 text-gray-400">Current page: {currentImageNum}</p>
                                </div>
                            </div>
                        )}
                    </div>
                    
                    {/* Fixed navigation buttons overlay */}
                    {currentImageSrc && !imageError.has(availableImages[currentImageIndex]) && (
                        <>
                            <button
                                onClick={() => navigateImage('prev')}
                                disabled={currentImageIndex === 0}
                                className="absolute left-0 top-1/2 transform -translate-y-1/2 p-3 bg-black/50 text-white rounded-r-full hover:bg-black/70 disabled:opacity-30 disabled:cursor-not-allowed transition-all z-10"
                                title="Previous image"
                            >
                                <ArrowLeftIcon className="h-6 w-6" />
                            </button>
                            
                            <button
                                onClick={() => navigateImage('next')}
                                disabled={currentImageIndex === availableImages.length - 1}
                                className="absolute right-0 top-1/2 transform -translate-y-1/2 p-3 bg-black/50 text-white rounded-l-full hover:bg-black/70 disabled:opacity-30 disabled:cursor-not-allowed transition-all z-10"
                                title="Next image"
                            >
                                <ArrowRightIcon className="h-6 w-6" />
                            </button>
                        </>
                    )}
                </div>
            </div>
        </div>
    );
}
