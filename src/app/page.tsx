'use client';

import { useState, useEffect } from 'react';
import { setServoPosition, setServoSpeed, getServoStatus } from './actions';

export default function Home() {
  const [position, setPosition] = useState<number | null>(null);
  const [speed, setSpeed] = useState<number>(50);
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState<'online' | 'offline'>('offline');
  const [lastAction, setLastAction] = useState<string>('Ready');

  // Fetch initial status
  useEffect(() => {
    const fetchStatus = async () => {
      const res = await getServoStatus();
      if (res.success) {
        setPosition(res.position);
        setStatus('online');
      } else {
        setStatus('offline');
      }
    };
    fetchStatus();
    const interval = setInterval(fetchStatus, 5000); // Poll every 5s
    return () => clearInterval(interval);
  }, []);

  const handlePositionChange = async (newPos: number) => {
    setLoading(true);
    setLastAction(`Moving to ${newPos === 1 ? '90°' : '0°'}...`);
    const res = await setServoPosition(newPos);
    if (res.success) {
      setPosition(newPos);
      setLastAction(`Success: Servo at ${newPos === 1 ? '90°' : '0°'}`);
    } else {
      setLastAction('Error: Failed to move servo');
    }
    setLoading(false);
  };

  const handleSpeedChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const newSpeed = parseInt(e.target.value);
    setSpeed(newSpeed);
    setLastAction(`Setting speed to ${newSpeed}...`);
    const res = await setServoSpeed(newSpeed);
    if (res.success) {
      setLastAction(`Success: Speed set to ${newSpeed}`);
    } else {
      setLastAction('Error: Failed to set speed');
    }
  };

  const getSpeedLabel = (val: number) => {
    if (val <= 30) return 'Sangat Lambat 🐢';
    if (val <= 60) return 'Normal 👍';
    if (val <= 90) return 'Cepat ⚡';
    if (val <= 110) return 'Sangat Cepat 🔥';
    return 'TURBO 🚀';
  };

  return (
    <main className="fade-in">
      <header className="header">
        <div className="logo">
          <div className="logo-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
              <line x1="12" y1="22.08" x2="12" y2="12"></line>
            </svg>
          </div>
          <h1 className="tech-font">SMART CLOCHES</h1>
        </div>
        <div className="status-indicator">
          <div className={`dot ${status === 'online' ? 'online' : ''}`}></div>
          <span>System {status === 'online' ? 'Active' : 'Disconnected'}</span>
        </div>
      </header>

      <section className="dashboard-grid">
        {/* Servo Control Card */}
        <div className="card">
          <h2 className="tech-font" style={{ fontSize: '1.25rem', marginBottom: '1rem' }}>SERVO CONTROL</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Adjust position and speed of the cloche servo motor.</p>
          
          <div className="servo-visual">
            <div className="servo-base"></div>
            <div 
              className="servo-arm" 
              style={{ transform: `rotate(${position === 1 ? '90deg' : '0deg'})` }}
            ></div>
          </div>

          <div className="switch-container">
            <label className="switch">
              <input 
                type="checkbox" 
                checked={position === 1}
                onChange={(e) => handlePositionChange(e.target.checked ? 1 : 0)}
                disabled={loading}
              />
              <span className="slider-toggle"></span>
            </label>
            <div className={`switch-status-text ${position === 1 ? 'text-on' : 'text-off'}`}>
              {position === 1 ? 'ON (90°)' : 'OFF (0°)'}
            </div>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.75rem', textAlign: 'center' }}>
              Tap switch to toggle position
            </p>
          </div>
        </div>

        {/* Speed Control Card */}
        <div className="card">
          <h2 className="tech-font" style={{ fontSize: '1.25rem', marginBottom: '1rem' }}>SPEED CONFIG</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Configure the rotation velocity of the servo motor.</p>
          
          <div style={{ marginTop: '2rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
              <span style={{ fontWeight: 600 }}>{speed}</span>
              <span style={{ color: speed > 100 ? '#ff4444' : 'var(--accent-primary)', fontWeight: 600 }}>
                {speed > 100 ? 'TURBO 🚀' : getSpeedLabel(speed)}
              </span>
            </div>
            <input 
              type="range" 
              min="0" 
              max="120" 
              step="1"
              value={speed} 
              onChange={handleSpeedChange}
              className="speed-slider"
              style={{
                background: speed > 100 
                  ? 'linear-gradient(90deg, rgba(255, 255, 255, 0.1) 0%, #ff4444 100%)' 
                  : 'rgba(255, 255, 255, 0.1)'
              }}
            />
            <div className="speed-labels">
              <span>0 (Sangat Lambat)</span>
              <span>120 (Max Turbo)</span>
            </div>
          </div>

          <div style={{ marginTop: '2.5rem', padding: '1rem', background: 'rgba(0,0,0,0.2)', borderRadius: '12px', border: '1px solid var(--glass-border)' }}>
            <h3 style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>LAST ACTION</h3>
            <div style={{ fontFamily: 'monospace', fontSize: '0.875rem', color: status === 'online' ? 'var(--accent-primary)' : '#ef4444' }}>
              {lastAction}
            </div>
          </div>
        </div>
      </section>

      <footer className="footer">
        <p>&copy; 2026 Smart Cloches IoT Dashboard • Powered by Blynk Cloud</p>
      </footer>
    </main>
  );
}
