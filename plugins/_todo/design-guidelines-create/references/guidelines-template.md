# Design Guidelines: [App Name]

> Generated: [date]
> Version: 1.0

---

## 1. Design Philosophy

[2-3 sentences describing the intended look, feel, and emotional register of the UI.
Written to be actionable: what someone building this UI should aim for, and what they
should avoid.]

**Keywords**: [e.g. minimal, trustworthy, calm, professional]

**Style**: [chosen style name, e.g. "Clean & Minimal"]

---

## 2. Brand Colors

[One sentence on the color strategy — e.g. "A cool-toned neutral palette anchored by
a confident indigo primary, keeping the interface calm and focused."]

### Palette

| Role | Name | Hex | Usage |
|---|---|---|---|
| Primary | [name] | #XXXXXX | CTAs, active states, links, highlights |
| Primary Dark | [name] | #XXXXXX | Hover and pressed states on primary |
| Primary Light | [name] | #XXXXXX | Tinted backgrounds, badges, chips |
| Secondary | [name] | #XXXXXX | Supporting accents, secondary actions |
| Neutral 900 | [name] | #XXXXXX | Headings, primary body text |
| Neutral 600 | [name] | #XXXXXX | Secondary text, labels, placeholders |
| Neutral 300 | [name] | #XXXXXX | Borders, dividers, disabled states |
| Neutral 100 | [name] | #XXXXXX | Subtle section backgrounds, hover states |
| Neutral 50 | [name] | #XXXXXX | Page background |
| Success | — | #XXXXXX | Positive / completed states |
| Warning | — | #XXXXXX | Cautionary states |
| Error | — | #XXXXXX | Destructive actions, error messages |
| Info | — | #XXXXXX | Informational callouts |

### Usage Ratio
- ~60% Neutrals (backgrounds, text, borders)
- ~30% Primary
- ~10% Secondary / Accent

### Code Tokens

<!-- Tailwind (tailwind.config.js) -->
```js
colors: {
  primary: {
    DEFAULT: '#XXXXXX',
    dark: '#XXXXXX',
    light: '#XXXXXX',
  },
  secondary: '#XXXXXX',
  neutral: {
    50: '#XXXXXX',
    100: '#XXXXXX',
    300: '#XXXXXX',
    600: '#XXXXXX',
    900: '#XXXXXX',
  },
  success: '#XXXXXX',
  warning: '#XXXXXX',
  error: '#XXXXXX',
  info: '#XXXXXX',
},
```

<!-- CSS custom properties -->
```css
:root {
  --color-primary: #XXXXXX;
  --color-primary-dark: #XXXXXX;
  --color-primary-light: #XXXXXX;
  --color-secondary: #XXXXXX;
  --color-neutral-50: #XXXXXX;
  --color-neutral-100: #XXXXXX;
  --color-neutral-300: #XXXXXX;
  --color-neutral-600: #XXXXXX;
  --color-neutral-900: #XXXXXX;
  --color-success: #XXXXXX;
  --color-warning: #XXXXXX;
  --color-error: #XXXXXX;
  --color-info: #XXXXXX;
}
```

---

## 3. Typography

[One sentence on the typographic intent — e.g. "A single clean sans-serif used
throughout, relying on weight and scale for hierarchy rather than font mixing."]

### Font Scale

| Role | Font | Weight | Size | Line Height |
|---|---|---|---|---|
| Display / Hero | [font] | [700] | [48px] | [1.1] |
| H1 | [font] | [700] | [36px] | [1.2] |
| H2 | [font] | [600] | [28px] | [1.25] |
| H3 | [font] | [600] | [22px] | [1.3] |
| H4 | [font] | [500] | [18px] | [1.35] |
| Body (default) | [font] | [400] | [16px] | [1.5] |
| Body Small | [font] | [400] | [14px] | [1.5] |
| Label / Caption | [font] | [500] | [12px] | [1.4] |
| Code | [mono font] | [400] | [14px] | [1.6] |

**Font source**: [Google Fonts / self-hosted / system font]
**Heading scale ratio**: [e.g. 1.25 — Major Third]

### Code Tokens

<!-- Tailwind (tailwind.config.js) -->
```js
fontFamily: {
  sans: ['[Font Name]', 'sans-serif'],
  mono: ['[Mono Font Name]', 'monospace'],
},
fontSize: {
  xs: ['12px', { lineHeight: '1.4' }],
  sm: ['14px', { lineHeight: '1.5' }],
  base: ['16px', { lineHeight: '1.5' }],
  lg: ['18px', { lineHeight: '1.35' }],
  xl: ['22px', { lineHeight: '1.3' }],
  '2xl': ['28px', { lineHeight: '1.25' }],
  '3xl': ['36px', { lineHeight: '1.2' }],
  '4xl': ['48px', { lineHeight: '1.1' }],
},
```

<!-- CSS custom properties -->
```css
:root {
  --font-sans: '[Font Name]', sans-serif;
  --font-mono: '[Mono Font Name]', monospace;
  --text-xs: 12px;
  --text-sm: 14px;
  --text-base: 16px;
  --text-lg: 18px;
  --text-xl: 22px;
  --text-2xl: 28px;
  --text-3xl: 36px;
  --text-4xl: 48px;
}
```

---

## 4. Spacing Scale

[One sentence — e.g. "Base-8 grid provides consistent rhythm across all components."]

Base unit: 4px

| Token | Value | Common use |
|---|---|---|
| space-1 | 4px | Tight inline gaps, icon padding |
| space-2 | 8px | Icon-to-label gap, tight component padding |
| space-3 | 12px | Compact list items |
| space-4 | 16px | Default component padding |
| space-6 | 24px | Section gaps, card padding |
| space-8 | 32px | Large component padding, form sections |
| space-12 | 48px | Section separators |
| space-16 | 64px | Page section gaps |
| space-24 | 96px | Hero section spacing |

### Code Tokens

<!-- Tailwind uses default spacing scale (base 4px) — no override needed unless customizing -->

<!-- CSS custom properties -->
```css
:root {
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-12: 48px;
  --space-16: 64px;
  --space-24: 96px;
}
```

---

## 5. Layout

[One sentence on the layout approach — e.g. "Wide-canvas dashboard layout with
generous margins and a strict 12-column grid."]

| Property | Value |
|---|---|
| Max content width | [e.g. 1280px] |
| Grid columns | 12 |
| Gutter | 24px (desktop), 16px (mobile) |
| Page margin (desktop) | 32px |
| Page margin (mobile) | 16px |
| Breakpoints | sm: 640px / md: 768px / lg: 1024px / xl: 1280px / 2xl: 1536px |

---

## 6. Shape

[One sentence — e.g. "Subtly rounded corners throughout; no sharp edges, no
pill shapes except tags."]

| Property | Value | Use |
|---|---|---|
| Border radius (sm) | [e.g. 4px] | Tags, badges, chips |
| Border radius (default) | [e.g. 8px] | Inputs, buttons, cards |
| Border radius (lg) | [e.g. 12px] | Modals, panels, drawers |
| Border radius (pill) | 9999px | Pill-style tags or toggle buttons (if used) |
| Border color (default) | [hex from neutral palette] | — |
| Border width | 1px | — |

### Code Tokens

<!-- Tailwind (tailwind.config.js) -->
```js
borderRadius: {
  sm: '[Xpx]',
  DEFAULT: '[Xpx]',
  lg: '[Xpx]',
  full: '9999px',
},
```

<!-- CSS custom properties -->
```css
:root {
  --radius-sm: [Xpx];
  --radius: [Xpx];
  --radius-lg: [Xpx];
  --radius-full: 9999px;
  --border-color: [hex];
}
```

---

## 7. Elevation / Shadows

[One sentence — e.g. "Flat design with minimal shadow use — shadows only on
floating elements like dropdowns and modals."]

| Level | CSS value | Use |
|---|---|---|
| Flat | none | Inline elements, table rows, sections |
| Subtle | [e.g. 0 1px 3px rgba(0,0,0,0.08)] | Cards on colored backgrounds |
| Medium | [e.g. 0 4px 12px rgba(0,0,0,0.10)] | Dropdowns, popovers, tooltips |
| Strong | [e.g. 0 16px 40px rgba(0,0,0,0.14)] | Modals, dialogs, command palettes |

### Code Tokens

<!-- Tailwind (tailwind.config.js) -->
```js
boxShadow: {
  subtle: '[value]',
  medium: '[value]',
  strong: '[value]',
},
```

<!-- CSS custom properties -->
```css
:root {
  --shadow-subtle: [value];
  --shadow-medium: [value];
  --shadow-strong: [value];
}
```

---

## 8. Iconography

| Property | Value |
|---|---|
| Library | [e.g. Lucide Icons] |
| Default size (inline) | 20px |
| Default size (standalone) | 24px |
| Stroke width | [e.g. 1.5px] |
| Color | Inherits from surrounding text color |

---

## 9. Motion

[One sentence — e.g. "Subtle, quick transitions to keep the interface feeling
responsive without drawing attention to itself."]

| Property | Value |
|---|---|
| Duration (fast) | 150ms |
| Duration (normal) | 250ms |
| Duration (slow) | 400ms |
| Easing (entrance) | ease-out |
| Easing (exit) | ease-in |
| Reduced motion | Respect `prefers-reduced-motion` — disable all transitions |

### Code Tokens

<!-- CSS custom properties -->
```css
:root {
  --duration-fast: 150ms;
  --duration-normal: 250ms;
  --duration-slow: 400ms;
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
  }
}
```

---

## 10. Component Patterns

[One sentence framing — e.g. "Strict, opinionated rules for common components to
ensure visual consistency across the entire application."]

### Buttons

| Variant | Background | Text | Border | Use |
|---|---|---|---|---|
| Primary | Primary | White | — | Main CTA |
| Secondary | Transparent | Primary | 1px Primary | Secondary actions |
| Ghost | Transparent | Neutral 600 | — | Tertiary / destructive-safe |
| Destructive | Error | White | — | Irreversible actions |
| Disabled | Neutral 100 | Neutral 300 | — | Unavailable state |

- Height: 32px (sm) / 40px (default) / 48px (lg)
- Padding: 12px horizontal (sm), 16px (default), 20px (lg)
- Focus ring: 2px Primary, 2px offset

### Form Inputs

- Border: 1px Neutral 300, border-radius: default
- Focus: 2px Primary border (replace, do not add outline)
- Error state: Error color border + error message below in Error color
- Placeholder text: Neutral 600
- Height: 40px (default), 36px (compact)
- Label: 14px, weight 500, Neutral 900, 6px above input

### Cards

- Background: White (or Neutral 50 on white page background)
- Border: 1px Neutral 200 **or** shadow-subtle — choose one and apply consistently
- Padding: 24px
- Border radius: default (lg on modal-like cards)

### Navigation

- Active item: Primary color text + left-border indicator (3px Primary) for sidebars
- Hover: Neutral 100 background
- Font: 14px, weight 500
- Icon: 20px, same color as text

### Badges / Tags

- Border radius: pill (9999px) for status tags, sm (4px) for category labels
- Padding: 2px 8px
- Font: 12px, weight 500

---

## 11. Pencil Design Tokens

This section provides variables in the format used by Pencil MCP (`set_variables`).
Apply these to a Pencil file to configure its design token library.

```json
{
  "colors": {
    "primary": "[hex]",
    "primary-dark": "[hex]",
    "primary-light": "[hex]",
    "secondary": "[hex]",
    "neutral-50": "[hex]",
    "neutral-100": "[hex]",
    "neutral-300": "[hex]",
    "neutral-600": "[hex]",
    "neutral-900": "[hex]",
    "success": "[hex]",
    "warning": "[hex]",
    "error": "[hex]",
    "info": "[hex]"
  },
  "typography": {
    "font-sans": "[Font Name]",
    "font-mono": "[Mono Font Name]",
    "text-base": "16",
    "text-sm": "14",
    "text-xs": "12",
    "text-lg": "18",
    "text-xl": "22",
    "text-2xl": "28",
    "text-3xl": "36",
    "text-4xl": "48"
  },
  "spacing": {
    "space-1": "4",
    "space-2": "8",
    "space-3": "12",
    "space-4": "16",
    "space-6": "24",
    "space-8": "32",
    "space-12": "48",
    "space-16": "64"
  },
  "shape": {
    "radius-sm": "[X]",
    "radius": "[X]",
    "radius-lg": "[X]"
  }
}
```

---

## 12. Accessibility Baseline

- All body text meets WCAG AA contrast ratio (4.5:1 minimum)
- Large text and UI components meet 3:1 minimum
- All interactive elements have visible focus states (never `outline: none` without
  a custom replacement)
- Color is never the sole indicator of state — always pair with icon or label
- Form errors are announced to screen readers (use `aria-live` or `role="alert"`)
