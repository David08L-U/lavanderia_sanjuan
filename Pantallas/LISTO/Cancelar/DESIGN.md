---
name: Hydro-Clean Modernist
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#414755'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#717786'
  outline-variant: '#c1c6d7'
  surface-tint: '#005bc1'
  primary: '#0058bc'
  on-primary: '#ffffff'
  primary-container: '#0070eb'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#54606b'
  on-secondary: '#ffffff'
  secondary-container: '#d8e4f2'
  on-secondary-container: '#5a6671'
  tertiary: '#595c5e'
  on-tertiary: '#ffffff'
  tertiary-container: '#727577'
  on-tertiary-container: '#fbfdff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#d8e4f2'
  secondary-fixed-dim: '#bcc8d5'
  on-secondary-fixed: '#111d26'
  on-secondary-fixed-variant: '#3d4853'
  tertiary-fixed: '#e0e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  button:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1.25rem
  stack-gap: 1rem
  inline-gap: 0.75rem
  section-padding: 2rem
---

## Brand & Style

The design system is centered on the concepts of clarity, hygiene, and seamless efficiency. It targets busy urban professionals and families who value their time and expect a premium, reliable service. The emotional response should be one of immediate relief—like walking into a freshly cleaned room.

The aesthetic follows a **Modern Corporate** approach with a heavy emphasis on **Minimalism**. By utilizing expansive white space and a monochromatic blue palette, the interface mimics the visual properties of water and fresh air. The design avoids clutter to ensure the user feels in control of their chores, rather than overwhelmed by them. High-quality typography and intentional breathing room between elements are the primary drivers of the premium feel.

## Colors

The palette is anchored by "Fresh Blue," a vibrant, high-energy primary color that signals action and reliability. "Soft Sky Blue" serves as the primary container and highlight color, providing a gentle contrast against the "Crisp White" base.

- **Primary (#007AFF):** Used for primary actions, progress indicators, and active states.
- **Secondary (#E5F1FF):** Used for large background surfaces, card backgrounds, and subtle button states.
- **Tertiary (#F8FAFC):** An off-white used for subtle grouping and sectioning to maintain depth without adding visual weight.
- **Neutral (#1E293B):** A deep slate blue-grey used for typography to ensure high legibility while appearing softer than pure black.

## Typography

This design system utilizes **Inter** for its systematic, utilitarian, and highly legible characteristics. The type hierarchy is designed to guide users through the service flow—from selecting laundry types to scheduling pickups—with zero ambiguity.

Weight is used strategically: Semi-bold and Bold weights are reserved for interactive elements and section headers, while Regular weight is used for descriptive text to maintain an airy feel. Tightened letter-spacing on larger headlines ensures a modern, "tucked-in" appearance.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile-first interactions. It relies on a consistent 4px baseline grid to ensure vertical rhythm. 

- **Margins:** A standard 20px (1.25rem) margin is applied to the left and right of all screens.
- **Vertical Spacing:** 16px (1rem) is the default gap between cards or list items. Larger 32px (2rem) gaps are used to separate major logical sections (e.g., "Active Orders" vs "Services").
- **Safe Areas:** Generous bottom padding is utilized to ensure primary action buttons remain clear of system gestures and home indicators.

## Elevation & Depth

To maintain a "clean" and "fresh" look, depth is communicated through **Tonal Layers** supplemented by very subtle, **Ambient Shadows**. 

Surfaces do not "float" high above the background; instead, they sit just above it. Use a shadow with a high blur radius (16px–24px) and very low opacity (approx. 4–6%) using the Neutral color as the shadow tint. This avoids the "dirty" look of grey shadows on white. 

Interactive cards use a white background on a Soft Sky Blue base to naturally pop without requiring heavy borders.

## Shapes

The shape language is defined by **Rounded** corners to evoke a sense of friendliness and safety. A standard radius of 16px (1rem) is applied to all primary containers, cards, and large buttons. This consistent curvature mirrors the "softness" of clean fabrics.

- **Standard Elements:** 16px corner radius.
- **Small Elements (Chips/Badges):** Fully rounded (pill-shaped) to distinguish them from structural cards.
- **Icon Enclosures:** 12px corner radius for a slightly tighter, more technical feel within the soft UI.

## Components

- **Buttons:** Primary buttons are Solid Fresh Blue with White text. Secondary buttons are Soft Sky Blue with Fresh Blue text. All buttons use 16px rounded corners and a height of 56px for easy thumb-tapping.
- **Cards:** Cards use a White background, the standard 16px radius, and a subtle 1px border in Soft Sky Blue to define edges against white backgrounds.
- **Input Fields:** Fields are styled with a Soft Sky Blue fill and no border in their default state. Upon focus, they transition to a White fill with a 2px Fresh Blue border.
- **Chips:** Used for selecting laundry preferences (e.g., "Eco-friendly," "Scent-free"). These are pill-shaped with a Soft Sky Blue background and Fresh Blue text.
- **Icons:** Use thin-line (1.5pt stroke) icons. Icons should be Fresh Blue. When used inside a primary button, icons transition to White.
- **Progress Indicators:** A thin, horizontal Fresh Blue bar is used to show the status of a laundry order (e.g., Washing, Drying, Out for Delivery).