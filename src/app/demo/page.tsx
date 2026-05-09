'use client';

import { createClient } from '@supabase/supabase-js';
import { useState, useEffect, useCallback } from 'react';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

interface RainUser {
  id: string;
  username: string;
  latitude: number | null;
  longitude: number | null;
  is_raining: boolean;
  updated_at: string;
}

const RANDOM_NAMES = [
  'tetangga_adi', 'bu_sari', 'pak_joko', 'mbak_dewi', 'mas_budi',
  'ibu_rina', 'pak_agus', 'nisa_rt03', 'hendra_blokB', 'lisa_perumahan',
];

export default function DemoPage() {
  const [users, setUsers] = useState<RainUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [message, setMessage] = useState('');

  const fetchUsers = useCallback(async () => {
    const { data, error } = await supabase
      .from('rain_users')
      .select('*')
      .order('updated_at', { ascending: false });
    if (!error && data) setUsers(data);
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchUsers();
    const interval = setInterval(fetchUsers, 5000);
    return () => clearInterval(interval);
  }, [fetchUsers]);

  const toggleRain = async (user: RainUser) => {
    await supabase
      .from('rain_users')
      .update({ is_raining: !user.is_raining, updated_at: new Date().toISOString() })
      .eq('id', user.id);
    fetchUsers();
  };

  const deleteUser = async (id: string) => {
    await supabase.from('rain_users').delete().eq('id', id);
    fetchUsers();
  };

  const generateNearbyUsers = async () => {
    const baseUser = users.find(u => u.latitude !== null && u.longitude !== null);
    if (!baseUser) {
      setMessage('Belum ada user dengan lokasi. Set lokasi di mobile app dulu.');
      return;
    }
    setGenerating(true);
    setMessage('');
    const usedNames = users.map(u => u.username);
    const available = RANDOM_NAMES.filter(n => !usedNames.includes(n));
    for (let i = 0; i < 3; i++) {
      const name = available.length > 0
        ? available.splice(Math.floor(Math.random() * available.length), 1)[0]
        : `test_user_${Date.now()}_${i}`;
      const offsetLat = (Math.random() - 0.5) * 0.014;
      const offsetLng = (Math.random() - 0.5) * 0.014;
      const isRaining = Math.random() > 0.5;
      await supabase.from('rain_users').upsert({
        username: name,
        latitude: baseUser.latitude! + offsetLat,
        longitude: baseUser.longitude! + offsetLng,
        is_raining: isRaining,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'username' });
    }
    setGenerating(false);
    setMessage('3 user dummy berhasil dibuat di sekitar ' + baseUser.username);
    fetchUsers();
  };

  const clearDummyUsers = async () => {
    for (const name of RANDOM_NAMES) {
      await supabase.from('rain_users').delete().eq('username', name);
    }
    await supabase.from('rain_users').delete().like('username', 'test_user_%');
    setMessage('User dummy dihapus');
    fetchUsers();
  };

  const calcDistance = (lat1: number, lng1: number, lat2: number, lng2: number) => {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  };

  const baseUser = users.find(u => u.latitude !== null && u.longitude !== null);
  const rainingCount = users.filter(u => u.is_raining).length;

  return (
    <main className="fade-in">
      {/* Header */}
      <div className="header">
        <div className="logo">
          <div className="logo-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
          </div>
          <div>
            <h1 style={{ fontSize: '1.25rem', margin: 0 }}>Rain Network</h1>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', margin: 0, fontFamily: 'Inter' }}>Distributed Warning Demo</p>
          </div>
        </div>
        <div className="status-indicator">
          <span className={`dot ${users.length > 0 ? 'online' : ''}`}></span>
          <span style={{ fontFamily: 'Inter' }}>{users.length} user terdaftar</span>
        </div>
      </div>

      {/* Stats cards */}
      <div className="dashboard-grid" style={{ marginTop: '1rem', gridTemplateColumns: 'repeat(3, 1fr)' }}>
        <div className="card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', letterSpacing: '1px', fontFamily: 'Inter' }}>TOTAL USER</p>
          <p className="tech-font" style={{ fontSize: '2rem', marginTop: '0.25rem', color: 'var(--accent-secondary)' }}>{users.length}</p>
        </div>
        <div className="card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', letterSpacing: '1px', fontFamily: 'Inter' }}>SEDANG HUJAN</p>
          <p className="tech-font" style={{ fontSize: '2rem', marginTop: '0.25rem', color: rainingCount > 0 ? '#ef4444' : 'var(--accent-primary)' }}>{rainingCount}</p>
        </div>
        <div className="card" style={{ padding: '1.25rem' }}>
          <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', letterSpacing: '1px', fontFamily: 'Inter' }}>CERAH</p>
          <p className="tech-font" style={{ fontSize: '2rem', marginTop: '0.25rem', color: 'var(--accent-primary)' }}>{users.length - rainingCount}</p>
        </div>
      </div>

      {/* Actions */}
      <div style={{ display: 'flex', gap: '0.75rem', marginTop: '1.5rem', flexWrap: 'wrap' }}>
        <button onClick={generateNearbyUsers} disabled={generating} className="btn btn-primary" style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem' }}>
          {generating ? 'Generating...' : '+ Generate 3 Random Users'}
        </button>
        <button onClick={clearDummyUsers} className="btn btn-secondary" style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem', borderColor: '#ef444433', color: '#ef4444' }}>
          Hapus Dummy
        </button>
        <button onClick={fetchUsers} className="btn btn-secondary" style={{ fontSize: '0.8rem', padding: '0.75rem 1.25rem' }}>
          Refresh
        </button>
      </div>

      {message && (
        <div className="card" style={{ marginTop: '1rem', padding: '0.75rem 1.25rem', borderColor: 'rgba(16,185,129,0.3)' }}>
          <p style={{ fontSize: '0.8rem', color: 'var(--accent-primary)', fontFamily: 'Inter', margin: 0 }}>{message}</p>
        </div>
      )}

      {/* Table */}
      {loading ? (
        <p style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-secondary)', fontFamily: 'Inter' }}>Loading...</p>
      ) : users.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', marginTop: '2rem', padding: '3rem' }}>
          <p style={{ color: 'var(--text-secondary)', fontFamily: 'Inter' }}>Belum ada data. Buka mobile app dan login.</p>
        </div>
      ) : (
        <div className="card" style={{ marginTop: '1.5rem', padding: 0, overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontFamily: 'Inter', fontSize: '0.8rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--glass-border)' }}>
                {['Username', 'Lat', 'Lng', 'Jarak', 'Status', 'Update', 'Aksi'].map(h => (
                  <th key={h} style={{ padding: '0.875rem 1rem', textAlign: 'left', fontSize: '0.65rem', letterSpacing: '1px', color: 'var(--text-secondary)', fontWeight: 600 }}>{h.toUpperCase()}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {users.map(user => {
                const dist = baseUser && user.latitude && user.longitude && baseUser.id !== user.id
                  ? calcDistance(baseUser.latitude!, baseUser.longitude!, user.latitude, user.longitude)
                  : null;
                return (
                  <tr key={user.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.04)', background: user.is_raining ? 'rgba(239,68,68,0.06)' : 'transparent', transition: 'background 0.3s' }}>
                    <td style={{ padding: '0.75rem 1rem', fontWeight: 600, color: 'var(--text-primary)' }}>{user.username}</td>
                    <td style={{ padding: '0.75rem 1rem', color: 'var(--text-secondary)' }}>{user.latitude?.toFixed(5) ?? '—'}</td>
                    <td style={{ padding: '0.75rem 1rem', color: 'var(--text-secondary)' }}>{user.longitude?.toFixed(5) ?? '—'}</td>
                    <td style={{ padding: '0.75rem 1rem' }}>
                      {dist !== null ? (
                        <span style={{ padding: '2px 10px', borderRadius: 20, fontSize: '0.7rem', fontWeight: 700, background: dist <= 1 ? 'rgba(16,185,129,0.15)' : 'rgba(245,158,11,0.15)', color: dist <= 1 ? '#10b981' : '#f59e0b' }}>
                          {(dist * 1000).toFixed(0)} m
                        </span>
                      ) : (
                        <span style={{ padding: '2px 10px', borderRadius: 20, fontSize: '0.65rem', fontWeight: 800, background: 'rgba(59,130,246,0.15)', color: '#3b82f6' }}>BASE</span>
                      )}
                    </td>
                    <td style={{ padding: '0.75rem 1rem' }}>
                      <button onClick={() => toggleRain(user)} style={{ padding: '4px 14px', borderRadius: 20, border: '1px solid', cursor: 'pointer', fontWeight: 700, fontSize: '0.7rem', background: user.is_raining ? 'rgba(239,68,68,0.12)' : 'rgba(16,185,129,0.12)', color: user.is_raining ? '#ef4444' : '#10b981', borderColor: user.is_raining ? 'rgba(239,68,68,0.25)' : 'rgba(16,185,129,0.25)', transition: 'all 0.2s' }}>
                        {user.is_raining ? 'Hujan' : 'Cerah'}
                      </button>
                    </td>
                    <td style={{ padding: '0.75rem 1rem', color: 'var(--text-secondary)', fontSize: '0.7rem' }}>
                      {user.updated_at
                        ? user.updated_at.replace(/^.*T/, '').replace(/\.\d+.*$/, '').replace(/\+.*$/, '')
                        : '—'}
                    </td>
                    <td style={{ padding: '0.75rem 1rem' }}>
                      <button onClick={() => deleteUser(user.id)} style={{ padding: '3px 10px', borderRadius: 6, border: '1px solid var(--glass-border)', cursor: 'pointer', background: 'transparent', color: 'var(--text-secondary)', fontSize: '0.7rem', transition: 'all 0.2s' }}>
                        Hapus
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Info */}
      <div className="card" style={{ marginTop: '1.5rem', padding: '1.25rem' }}>
        <h3 style={{ fontSize: '0.7rem', letterSpacing: '1px', color: 'var(--text-secondary)', marginBottom: '0.75rem' }}>CARA TES</h3>
        <ol style={{ margin: 0, paddingLeft: '1.25rem', lineHeight: 2, color: 'var(--text-secondary)', fontSize: '0.8rem', fontFamily: 'Inter' }}>
          <li>Buka mobile app → login → tekan &quot;Set Lokasi&quot;</li>
          <li>Klik &quot;Generate 3 Random Users&quot; di atas</li>
          <li>Toggle status hujan user dummy</li>
          <li>Cek mobile app — servo auto-close jika ada hujan dalam 1km</li>
        </ol>
      </div>
    </main>
  );
}
