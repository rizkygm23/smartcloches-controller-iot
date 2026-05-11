# Deployment Guide - Smart Cloches Web Dashboard

## ✅ Fix untuk Error Vercel Build

### Problem
Error saat deploy di Vercel:
```
Type error: Cannot find module 'expo-status-bar' or its corresponding type declarations.
> 1 | import { StatusBar } from 'expo-status-bar';
```

### Root Cause
TypeScript checker Next.js mencoba memeriksa file di folder `/mobile` (React Native project) yang bukan bagian dari web app.

### Solution
Update `tsconfig.json` untuk exclude folder-folder yang bukan bagian dari Next.js app:

```json
{
  "exclude": [
    "node_modules",
    "mobile",              // React Native app
    "smartcloches-mobile", // Flutter app
    "server",              // Node.js server
    "sketch_apr25b"        // Arduino firmware
  ]
}
```

---

## 🚀 Deploy ke Vercel

### 1. Push ke GitHub
```bash
git add .
git commit -m "Fix: Exclude mobile folders from TypeScript build"
git push origin main
```

### 2. Deploy di Vercel

#### Via Vercel Dashboard
1. Login ke [vercel.com](https://vercel.com)
2. Click **"Add New Project"**
3. Import repository dari GitHub
4. Configure project:
   - **Framework Preset:** Next.js
   - **Root Directory:** `./` (default)
   - **Build Command:** `npm run build` (default)
   - **Output Directory:** `.next` (default)

#### Environment Variables
Tambahkan di Vercel dashboard → Settings → Environment Variables:

```env
BLYNK_TOKEN=your_blynk_token_here
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

5. Click **"Deploy"**

#### Via Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

---

## 📋 Pre-Deployment Checklist

- [x] TypeScript build passes (`npx tsc --noEmit`)
- [x] Production build succeeds (`npm run build`)
- [x] Environment variables configured
- [x] Mobile/Flutter folders excluded from build
- [x] `.env.local` in `.gitignore`
- [x] All pages render correctly:
  - [x] `/` - Main dashboard
  - [x] `/demo` - Rain network demo
  - [x] `/maps` - Location maps

---

## 🔧 Build Configuration

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts",
    "**/*.mts"
  ],
  "exclude": [
    "node_modules",
    "mobile",
    "smartcloches-mobile",
    "server",
    "sketch_apr25b"
  ]
}
```

### .gitignore
Pastikan file-file ini tidak ter-commit:
```
.env.local
.env*.local
node_modules/
.next/
```

---

## 🌐 Post-Deployment

### 1. Verify Deployment
- Check homepage: `https://your-app.vercel.app`
- Check demo page: `https://your-app.vercel.app/demo`
- Check maps page: `https://your-app.vercel.app/maps`

### 2. Test Functionality
- [ ] Servo control toggle works
- [ ] Speed slider updates
- [ ] Status polling works (online/offline)
- [ ] Demo page loads user data from Supabase
- [ ] Generate dummy users works
- [ ] Maps page displays location correctly

### 3. Monitor
- Check Vercel dashboard for:
  - Build logs
  - Runtime logs
  - Analytics
  - Error tracking

---

## 🐛 Troubleshooting

### Build Fails with TypeScript Error
```bash
# Run locally to debug
npx tsc --noEmit

# Check which files are causing issues
npx tsc --listFiles | grep -v node_modules
```

### Environment Variables Not Working
- Ensure variables start with `NEXT_PUBLIC_` for client-side access
- Redeploy after adding new env vars
- Check Vercel dashboard → Settings → Environment Variables

### 404 on Routes
- Next.js App Router uses file-based routing
- Check file structure in `src/app/`
- Ensure `page.tsx` exists in each route folder

### API Calls Failing
- Check CORS settings on Blynk/Supabase
- Verify API tokens are correct
- Check browser console for errors

---

## 📊 Build Output

Successful build should show:
```
Route (app)
┌ ○ /                    # Main dashboard
├ ○ /_not-found          # 404 page
├ ○ /demo                # Rain network demo
└ ○ /maps                # Location maps

○  (Static)  prerendered as static content
```

All routes are **static** (○) which means:
- Fast loading
- CDN cached
- No server-side rendering needed
- Lower costs

---

## 🔐 Security Notes

- Never commit `.env.local` to git
- Use Vercel environment variables for secrets
- Blynk token is server-side only (not exposed to browser)
- Supabase keys are public (protected by RLS policies)

---

## 📱 Mobile App Integration

Web dashboard works alongside:
- **Flutter Mobile App** (`smartcloches-mobile/`)
- **React Native App** (`mobile/`)
- **Node.js Server** (`server/`)

All share the same:
- Blynk Cloud for IoT control
- Supabase for distributed rain warning

---

*Last updated: 2026-05-10*
*Build status: ✅ Passing*
