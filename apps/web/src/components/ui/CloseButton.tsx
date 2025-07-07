'use client';

export default function CloseButton() {
  const handleClose = () => {
    if (window.opener) {
      window.close();
    } else {
      // Fallback if window.close() doesn't work
      window.history.back();
    }
  };

  return (
    <button
      onClick={handleClose}
      className="inline-flex items-center px-3 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-sm"
    >
      Close
    </button>
  );
}