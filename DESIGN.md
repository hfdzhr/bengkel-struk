# Design System: OtoNota

## 1. Visual Theme & Atmosphere
A high-contrast, tactile workshop POS interface with utilitarian density (Density: 7, Variance: 4, Motion: 4). Built for speed, oil-stained thumbs, and elderly eyes under harsh shop lighting. The aesthetic blends rugged physical workshop tools with crisp digital clarity: confident oversized touch targets, structural dividers, and zero decorative fluff.

## 2. Color Palette & Roles
- **Workshop Canvas** (`#F8FAFC` / `Slate-50`) — Main screen background surface
- **Card Surface** (`#FFFFFF`) — Service tile and cart surface
- **Industrial Charcoal** (`#0F172A` / `Slate-900`) — Primary headings, high-contrast totals, bold button labels
- **Muted Steel** (`#475569` / `Slate-600`) — Secondary descriptions, plate numbers, unit prices
- **Structural Border** (`#CBD5E1` / `Slate-300`) — 1.5px tactile tile boundaries and dividers
- **Safety Amber Accent** (`#D97706` / `Amber-600`) — Singular functional accent for action triggers, active selections, and connection state indicators

## 3. Typography Rules
- **Display / Totals:** `Satoshi` or `Geist` — Heavy weight (700/800), tight letter-spacing, maximum immediate readability
- **Body / Labels:** `Satoshi` or `Geist` — High legibility at large base sizes (minimum 16px body, 18px-24px for primary interactive targets)
- **Mono / Numbers:** `JetBrains Mono` or `Geist Mono` — For currency values (Rupiah), timestamps, thermal receipt previews, and license plate badges
- **Banned:** Inter, generic serifs (Times/Georgia), thin font weights (<400) anywhere in UI.

## 4. Component Stylings
- **Service Action Tiles:** Solid card surface with 1.5px `#CBD5E1` structural border, rounded corners (16px / `1rem`), tactile -2px push depression on press. Clear bold name with monospace price below.
- **Cart & Total Summary:** High-density summary block with top-border separation. Giant monospace total figure in Industrial Charcoal.
- **Print / Primary Action Button:** Full-width, minimum 56px height, high-contrast `#0F172A` fill with `#FFFFFF` text or `#D97706` accent highlight. Zero glowing borders or soft neon blur.
- **Input Fields:** Generous touch field (minimum 52px), prominent label above, solid 1.5px neutral border focusing to `#D97706`. Monospace formatter for license plates and currency.
- **Connection Indicator / Status Pill:** Compact status badge using subtle amber/slate indicators with explicit text ("Tersambung" / "Terputus").

## 5. Layout Principles
- **Single-Screen Focused Workflow:** Zero nested navigation required to complete a transaction. Catalog on top/left, active receipt cart and instant action docked at bottom/right.
- **No Overlapping Elements:** Clean vertical flow with dedicated spacing blocks (`clamp(12px, 2vw, 20px)`).
- **Physical Touch Ergonomics:** Minimum interactive target size 48x48px (preferred 56px+ for main POS actions) to prevent miss-taps.
- **Mobile First & Tablet Adaptive:** Single-column split stack on mobile phones (<600px), 2-column split (Catalog left, Cart & Checkout right) on tablet/desktop viewports.

## 6. Motion & Interaction
- **Tactile Feedback:** Crisp, instant response on tap (`scale: 0.97`, duration: 100ms) mimicking physical cash register buttons.
- **Spring Physics:** `stiffness: 220, damping: 24` for dialogs and bottom sheets.
- **No CPU Bloat:** Hardware-accelerated transforms only; no heavy continuous blur filters or unneeded continuous loops.

## 7. Anti-Patterns (Banned)
- No emojis
- No `Inter` or generic serif fonts
- No pure black (`#000000`)
- No purple/neon glows or futuristic AI aesthetics
- No decorative low-contrast text below 14px
- No multi-step checkout modals or hidden print triggers
- No fake filler copy or placeholder jargon
