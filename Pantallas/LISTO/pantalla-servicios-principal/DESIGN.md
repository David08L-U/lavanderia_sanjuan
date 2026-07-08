---
name: FreshClean Modern Corporate
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
  on-surface-variant: '#424753'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#727784'
  outline-variant: '#c2c6d5'
  surface-tint: '#095bbf'
  primary: '#00418f'
  on-primary: '#ffffff'
  primary-container: '#0058bc'
  on-primary-container: '#c3d4ff'
  inverse-primary: '#adc6ff'
  secondary: '#54606b'
  on-secondary: '#ffffff'
  secondary-container: '#d7e4f1'
  on-secondary-container: '#5a6671'
  tertiary: '#414546'
  on-tertiary: '#ffffff'
  tertiary-container: '#595c5e'
  on-tertiary-container: '#d2d4d7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004494'
  secondary-fixed: '#d7e4f1'
  secondary-fixed-dim: '#bbc8d5'
  on-secondary-fixed: '#111d26'
  on-secondary-fixed-variant: '#3c4853'
  tertiary-fixed: '#e1e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
  success-blue: '#0070eb'
  error-red: '#ba1a1a'
  surface-blue-tint: '#e7eeff'
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
  button:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1.25rem
  section-padding: 2rem
  inline-gap: 0.75rem
  stack-gap: 1rem
  hero-padding: 2.5rem
---

## Brand & Style
The brand personality is **trustworthy, efficient, and rejuvenating**. It leverages a "Modern Corporate" aesthetic that prioritizes clarity and utility while maintaining a friendly, approachable edge through soft rounded corners and airy layouts.

The design evokes a sense of "cleanliness" using a palette of crisp blues and soft greys. It avoids the rigidity of traditional enterprise software by incorporating subtle ambient shadows and decorative organic shapes (circles and blurs) that suggest water and movement. The interface should feel like a premium concierge service: helpful, unobtrusive, and impeccably organized.

## Colors
The color strategy uses **high-fidelity blues** to communicate reliability and hygiene. 
- **Primary:** A deep, vibrant blue used for calls to action, progress indicators, and branding.
- **Secondary/Tertiary:** Subdued slate greys that handle metadata and less prominent navigational elements.
- **Surface Palette:** Utilizes a multi-tiered system of "Surface Containers" (Low to Highest) to create functional grouping without relying on heavy borders.
- **Functional Colors:** A clear semantic red is reserved for urgent notifications or errors.
- **Decorative:** Light azure tints (`primary-fixed`) are used as background fills for high-priority hero sections to provide visual "breathing room."

## Typography
The system relies exclusively on **Inter** to maintain a highly legible, systematic, and utilitarian feel. 
- **Headlines:** Use tighter letter spacing and heavier weights (600-700) to create a strong visual anchor.
- **Body:** Standardized at 14px and 16px for optimal readability in data-heavy or instructional contexts.
- **Labels:** Used for micro-copy and metadata, employing a medium weight (500) to ensure legibility despite the small scale.
- **Scaling:** On mobile devices, the largest headlines should shift from 32px to a more contained 20px-24px range to avoid excessive wrapping.

## Layout & Spacing
The layout follows a **fluid grid model** with strict max-width constraints (1280px) for desktop viewing. 
- **Mobile:** Uses a consistent 20px (`1.25rem`) side margin.
- **Desktop:** Increases side margins to 32px (`2rem`) to handle the increased horizontal real estate.
- **Rhythm:** Vertical spacing between major sections is generous (32px to 48px) to reinforce the "fresh and airy" brand attribute. 
- **Grouping:** Elements within a card or section use a tighter 16px (`1rem`) "stack gap" to maintain visual association.

## Elevation & Depth
Depth is achieved through **ambient shadows** and **tonal layering** rather than traditional skeuomorphism.
- **Shadows:** Use a very diffused, low-opacity shadow (`rgba(89, 92, 94, 0.05)`) with a high blur radius (24px) for cards and banners. This creates a "floating" effect that feels light.
- **Borders:** Subtle 1px borders using `surface-variant` or `outline-variant` are used on cards to provide definition against the light background.
- **Interactive States:** On hover or active click, cards may transition to a slightly higher contrast border (Primary) or a subtle scale-down effect (95-98%) to provide tactile feedback.

## Shapes
The shape language is defined by **pronounced, friendly rounding**.
- **Cards & Banners:** Use a generous `1.5rem` (24px) corner radius to soften the interface.
- **Buttons:** Primary buttons use a `1rem` (16px) radius, while secondary buttons and inputs typically follow a `0.75rem` (12px) standard.
- **Icons:** Icons should be enclosed in circular or "squircle" containers when used as primary visual identifiers in lists or grids.

## Components
- **Buttons:** Primary buttons are high-contrast (Primary Blue/White) with a height of 56px for touch-friendliness. Include a trailing icon for directional actions.
- **Cards:** Feature a white or "lowest" surface background, a subtle border, and the signature ambient shadow. They should feel like "containers of information" with internal padding of 20px-24px.
- **Progress Bars:** Use a thick (8px) rounded track with a high-contrast primary fill.
- **Navigation:**
    - **Mobile:** A fixed bottom bar with labeled icons and a distinct active state (tonal background pill).
    - **Desktop:** A fixed top bar with clear text-based links and a subtle "surface" background.
- **Service Grid:** Interactive tiles with vertical stacks of Icon -> Title -> Price/Subtext. Icons should be housed in tonal containers (`primary-fixed`).
- **Banners:** Use semi-transparent decorative elements (blurs/circles) in the background to add visual interest without distracting from the CTA.