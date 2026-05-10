'use client';

import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';

function MapsContent() {
  const searchParams = useSearchParams();
  const lat = searchParams.get('lat');
  const lng = searchParams.get('lng');
  const username = searchParams.get('username') || 'Unknown User';

  if (!lat || !lng) {
    return (
      <div className="card" style={{ textAlign: 'center', padding: '3rem' }}>
        <p style={{ color: 'var(--text-secondary)', fontFamily: 'Inter' }}>
          Koordinat tidak valid. Kembali ke halaman demo.
        </p>
        <a href="/demo" className="btn btn-primary" style={{ marginTop: '1.5rem', display: 'inline-flex' }}>
          ← Kembali ke Demo
        </a>
      </div>
    );
  }

  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);

  // Google Maps embed URL
  const googleMapsUrl = `https://www.google.com/maps/embed/v1/place?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY || 'YOUR_API_KEY'}&q=${latitude},${longitude}&zoom=15`;
  
  // OpenStreetMap alternative (no API key needed)
  const osmUrl = `https://www.openstreetmap.org/export/embed.html?bbox=${longitude - 0.01},${latitude - 0.01},${longitude + 0.01},${latitude + 0.01}&layer=mapnik&marker=${latitude},${longitude}`;

  return (
    <main className="fade-in">
      {/* Header */}
      <div className="header">
        <div className="logo">
          <div className="logo-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
              <circle cx="12" cy="10" r="3"/>
            </svg>
          </div>
          <div>
            <h1 style={{ fontSize: '1.25rem', margin: 0 }}>Lokasi User</h1>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', margin: 0, fontFamily: 'Inter' }}>
              {username}
            </p>
          </div>
        </div>
        <a href="/demo" className="btn btn-secondary" style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem', textDecoration: 'none' }}>
          ← Kembali
        </a>
      </div>

      {/* Coordinate Info */}
      <div className="dashboard-grid" style={{ marginTop: '1rem', gridTemplateColumns: 'repeat(2, 1fr)' }}>
        <div className="card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', letterSpacing: '1px', fontFamily: 'Inter' }}>
            LATITUDE
          </p>
          <p className="tech-font" style={{ fontSize: '1.5rem', marginTop: '0.25rem', color: 'var(--accent-primary)' }}>
            {latitude.toFixed(6)}
          </p>
        </div>
        <div className="card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', letterSpacing: '1px', fontFamily: 'Inter' }}>
            LONGITUDE
          </p>
          <p className="tech-font" style={{ fontSize: '1.5rem', marginTop: '0.25rem', color: 'var(--accent-secondary)' }}>
            {longitude.toFixed(6)}
          </p>
        </div>
      </div>

      {/* Map Container */}
      <div className="card" style={{ marginTop: '1.5rem', padding: '1.5rem' }}>
        <h2 style={{ fontSize: '1rem', marginBottom: '1rem', fontFamily: 'Inter', fontWeight: 600 }}>
          Peta Lokasi
        </h2>
        
        {/* OpenStreetMap Embed */}
        <div style={{ position: 'relative', width: '100%', height: '500px', borderRadius: '12px', overflow: 'hidden', border: '1px solid var(--glass-border)' }}>
          <iframe
            width="100%"
            height="100%"
            frameBorder="0"
            scrolling="no"
            marginHeight={0}
            marginWidth={0}
            src={osmUrl}
            style={{ border: 0 }}
          />
        </div>

        {/* External Links */}
        <div style={{ display: 'flex', gap: '0.75rem', marginTop: '1.5rem', flexWrap: 'wrap' }}>
          <a
            href={`https://www.google.com/maps?q=${latitude},${longitude}`}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-primary"
            style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem', textDecoration: 'none' }}
          >
            🗺️ Buka di Google Maps
          </a>
          <a
            href={`https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}&zoom=15`}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-secondary"
            style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem', textDecoration: 'none' }}
          >
            🌍 Buka di OpenStreetMap
          </a>
          <button
            onClick={() => {
              navigator.clipboard.writeText(`${latitude}, ${longitude}`);
              alert('Koordinat berhasil disalin!');
            }}
            className="btn btn-secondary"
            style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem' }}
          >
            📋 Salin Koordinat
          </button>
        </div>
      </div>

      {/* Info Card */}
      <div className="card" style={{ marginTop: '1.5rem', padding: '1.25rem' }}>
        <h3 style={{ fontSize: '0.7rem', letterSpacing: '1px', color: 'var(--text-secondary)', marginBottom: '0.75rem' }}>
          INFORMASI
        </h3>
        <ul style={{ margin: 0, paddingLeft: '1.25rem', lineHeight: 2, color: 'var(--text-secondary)', fontSize: '0.8rem', fontFamily: 'Inter' }}>
          <li>Peta menggunakan OpenStreetMap (tidak perlu API key)</li>
          <li>Klik tombol di atas untuk membuka di aplikasi peta eksternal</li>
          <li>Marker menunjukkan lokasi user <strong>{username}</strong></li>
          <li>Koordinat: {latitude.toFixed(6)}, {longitude.toFixed(6)}</li>
        </ul>
      </div>
    </main>
  );
}

export default function MapsPage() {
  return (
    <Suspense fallback={
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh' }}>
        <p style={{ color: 'var(--text-secondary)', fontFamily: 'Inter' }}>Loading map...</p>
      </div>
    }>
      <MapsContent />
    </Suspense>
  );
}
