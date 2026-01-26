# Bottom Sheet Login Screen Design

## Overview
A modern, bottom sheet style login screen for the Personal Finance Management App that features a dark ambient background with a white card rising from the bottom with heavily rounded corners. The "Welcome Back" text floats above the white card for a layered effect.

## Design Specifications

### Layout Structure
- **Mobile-First Design**: Bottom sheet aesthetic
- **Dark Background**: Top area with dark ambient background (`#1A1A2E`)
- **Login Icon**: Centered login_icon.png (100px height)
- **Welcome Text**: Positioned above white card with white text
- **White Card**: Rises from bottom with 30px rounded top corners
- **Back Button**: Top-left with semi-transparent white background
- **Slide-Up Animation**: Smooth 600ms entrance animation

### Visual Hierarchy
1. **Back Button** (top-left, white icon)
2. **Login Icon** (centered in dark area)
3. **Welcome Text** (floating above card, white)
4. **White Card** (bottom 70% of screen)
5. **Form Content** (inside white card)

### Color Scheme

```dart
Dark Background: #1A1A2E (ambient dark navy)
Card Background: #FFFFFF (pure white)
Button Navy: #303E50 (dark navy for text)
Accent Orange: #FF7A4A (warm gradient button)
Text Navy: #303E50 (primary text)
Text Medium: #4A5568 (secondary text)
Input Border: #E5E5E5 (soft gray borders)
Input Background: #F8F9FA (light gray fill)
White Text: #FFFFFF (for dark background)
```

### Typography
- **Font**: Modern sans-serif (system default)
- **Title**: 28px, Bold, Navy
- **Subtitle**: 15px, Regular, Medium Gray
- **Labels**: 14px, Semi-bold, Navy
- **Inputs**: 15px, Regular
- **Buttons**: 17px, Bold, White

## Content & Copy

### Screen Elements

**Dark Background Section:**
- Back Button (top-left corner)
  - Icon: `arrow_back_ios_new`
  - Color: White
  - Background: Semi-transparent white (10% opacity)
  - Size: 24px
- Login Icon (centered)
  - Image: `assets/images/login_icon.png`
  - Height: 100px

**Welcome Text (Floating Above Card):**
- Title: "Welcome Back"
  - Font: 32px, Bold, White
  - Letter-spacing: -0.5
- Subtitle: "Login to manage your wealth."
  - Font: 16px, Regular, White 80% opacity
  - Line height: 1.4

**White Card Section:**

1. **Email Input**
   - Label: "Email" (floating label)
   - Placeholder: "name@example.com"
   - Type: Email keyboard
   - Validation: Required, must contain @

2. **Password Input**
   - Label: "Password" (floating label)
   - Placeholder: "Enter your password"
   - Type: Password (with visibility toggle)
   - Icon: Eye icon on right
   - Validation: Required, minimum 6 characters

3. **Helper Options**
   - Checkbox: "Remember me" (left)
   - Link: "Forgot password?" (right, orange)

4. **Primary Button**
   - Text: "Log In"
   - Style: Full-width pill (28px radius)
   - Gradient: Orange to Deep Orange
   - Shadow: Orange glow

5. **Divider**
   - Text: "or"
   - Style: Horizontal lines with centered text

6. **Social Login Buttons**
   - Button 1: "Continue with Google" (G icon)
   - Button 2: "Continue with Apple" (Apple icon)
   - Style: Pill-shaped, light gray background

7. **Footer**
   - Text: "Don't have an account? Sign up"
   - Link: "Sign up" (orange, bold)

## Component Specifications

### Back Button
- **Position**: Top-left corner (16px padding)
- **Icon**: `arrow_back_ios_new`
- **Size**: 24px
- **Color**: White
- **Background**: White 10% opacity
- **Padding**: 8px
- **Border Radius**: Circular
- **Action**: Navigate back

### Welcome Text (Above Card)
- **Position**: 35% from top, 6% horizontal padding
- **Title**: 32px, bold, white, -0.5 letter-spacing
- **Subtitle**: 16px, white 80% opacity
- **Animation**: Slides up and fades in with card

### Input Fields
- **Border Radius**: 12px
- **Padding**: 16px horizontal, 16px vertical
- **Background**: Light gray (`#F8F9FA`)
- **Border**: 1px solid `#E5E5E5`
- **Focus State**: 2px solid navy (`#303E50`)
- **Error State**: 2px solid orange (`#FF7A4A`)
- **Font Size**: 15px

### Primary Button (Log In)
- **Height**: 56px
- **Border Radius**: 28px (pill shape)
- **Gradient**: `#FF7A4A` → `#FF6B3D`
- **Shadow**: 12px blur, 6px offset, orange 30% opacity
- **Text**: White, 17px, bold, 0.5 letter-spacing
- **Loading State**: White circular progress indicator

### Social Buttons
- **Height**: 56px
- **Border Radius**: 28px (pill shape)
- **Background**: `#F8F9FA`
- **Border**: 1px solid `#E5E5E5`
- **Icon Size**: 28px
- **Text**: Navy, 16px, semi-bold
- **Spacing**: 12px between buttons

### Remember Me Checkbox
- **Size**: 20x20px
- **Border Radius**: 4px
- **Active Color**: Navy (`#303E50`)
- **Label**: 14px, medium gray

## Animations

### Slide-Up Animation
- **Duration**: 600ms
- **Curve**: Ease-out cubic
- **Start**: Offset(0, 0.3) - 30% from bottom
- **End**: Offset(0, 0) - final position
- **Trigger**: On screen load

### Button States
- **Hover**: Slight opacity change
- **Press**: Scale down slightly
- **Loading**: Circular progress indicator

## Responsive Behavior

### Screen Adaptation
- **Max Height**: 85% of screen height
- **Horizontal Padding**: 6% of screen width
- **Vertical Padding**: 4% of screen height
- **Scrollable**: When content exceeds container

### Keyboard Handling
- **Resize**: Bottom inset adjusts automatically
- **Scroll**: Content scrolls to keep focused input visible
- **Physics**: Clamping scroll physics

## User Experience

### Validation
- **Real-time**: Shows errors on blur
- **Submit**: Validates all fields before login
- **Error Display**: Orange-tinted container below form
- **Error Icon**: Warning icon with message

### Loading States
- **Button**: Shows circular progress indicator
- **Disabled**: Prevents multiple submissions
- **Feedback**: Visual indication of processing

### Error Handling
- **Display**: Orange-tinted alert box
- **Icon**: Error outline icon
- **Message**: Clear, actionable error text
- **Dismissal**: Clears on new input

## Accessibility

- **Contrast**: High contrast text on white background
- **Touch Targets**: Minimum 44x44px (buttons are 56px)
- **Labels**: All inputs have visible labels
- **Keyboard**: Full keyboard navigation support
- **Screen Readers**: Semantic HTML structure

## Technical Implementation

### State Management
- Uses Provider for authentication state
- Form validation with GlobalKey
- Local state for password visibility and remember me

### Performance
- Single animation controller for slide-up
- Efficient rebuilds with Consumer widgets
- Optimized scroll physics

### Code Structure
```dart
- _buildDarkBackground() - Top dark section with login icon
- _buildLoginForm() - Email and password inputs with floating labels
- _buildRememberAndForgot() - Checkbox and link
- _buildLoginButton() - Primary CTA with gradient
- _buildDivider() - "or" separator
- _buildSocialLogins() - Google and Apple buttons
- _buildSocialButton() - Reusable social button
- _buildSignUpLink() - Footer link
```

### Key Features
- **Back Button**: iOS-style back arrow in top-left
- **Floating Welcome Text**: White text positioned above card
- **Login Icon**: Uses login_icon.png from assets
- **Layered Design**: Text floats above card for depth
- **Smooth Animations**: Welcome text and card slide up together

## Design Philosophy

1. **Trust**: Dark professional background builds confidence
2. **Clarity**: White card with clear hierarchy
3. **Simplicity**: Clean, uncluttered interface
4. **Modern**: Bottom sheet pattern feels contemporary
5. **Accessible**: High contrast and large touch targets
6. **Smooth**: Polished animations enhance experience

## Comparison with Onboarding

While onboarding uses warm cream colors (`#FFF8DB`), the login screen uses:
- **Dark background** for sophistication
- **Pure white card** for clarity
- **Same navy and orange** for consistency
- **Same button styles** (pill-shaped, 28px radius)
- **Same typography** and spacing patterns

This creates a professional login experience while maintaining brand consistency through shared accent colors and button styles.
