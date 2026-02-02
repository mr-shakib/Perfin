# PerFin App Icon Setup Guide

## Overview
This guide will help you set up a custom app icon for PerFin using the `flutter_launcher_icons` package.

## What You Need

You need to create **2 icon images**:

### 1. Main App Icon (`app_icon.png`)
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Location**: `assets/icon/app_icon.png`
- **Design**: Your full app icon design

### 2. Adaptive Icon Foreground (`app_icon_foreground.png`)
- **Size**: 1024x1024 pixels  
- **Format**: PNG with transparency
- **Location**: `assets/icon/app_icon_foreground.png`
- **Design**: Just the logo/symbol part (for Android adaptive icons)
- **Note**: The background will be `#1A1A1A` (dark navy)

## Design Recommendations

### Color Scheme
- **Primary**: `#1A1A1A` (Deep navy/black)
- **Accent**: `#F5E6D3` (Cream/gold)

### Icon Concept Ideas
1. **Stylized "P" with coin**: A modern "P" letter combined with a coin symbol
2. **Wallet icon**: Minimalist wallet with a "P" or currency symbol
3. **Piggy bank**: Modern, geometric piggy bank design
4. **Graph + Currency**: Upward trending graph with dollar/currency symbol

### Design Tips
- Keep it simple - icons are viewed at small sizes
- Use high contrast colors
- Avoid fine details or thin lines
- Make sure the icon is recognizable at 48x48px
- Leave some padding around the edges (safe zone)

## How to Create the Icons

### Option 1: Use an Online Tool
1. Go to [Canva](https://www.canva.com) or [Figma](https://www.figma.com)
2. Create a 1024x1024px canvas
3. Design your icon
4. Export as PNG

### Option 2: Use AI Image Generator
1. Use DALL-E, Midjourney, or similar
2. Prompt: "Modern minimalist app icon for personal finance app, navy blue and gold colors, flat design, 1024x1024"
3. Download and save

### Option 3: Hire a Designer
- Fiverr, Upwork, or 99designs
- Budget: $5-50 depending on complexity

## Installation Steps

Once you have your icon images:

1. **Place the icons** in the correct location:
   ```
   assets/icon/app_icon.png
   assets/icon/app_icon_foreground.png
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate the icons**:
   ```bash
   dart run flutter_launcher_icons
   ```

4. **Build and test**:
   ```bash
   flutter build apk
   ```
   
5. **Install on device** and check the home screen!

## Current Configuration

The `pubspec.yaml` is already configured with:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A1A1A"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

## What This Generates

The tool will automatically create:
- **Android**: All required icon sizes (mipmap folders)
- **iOS**: All required icon sizes (Assets.xcassets)
- **Adaptive icons**: For Android 8.0+ with custom background color

## Quick Start (Temporary Icon)

If you want to test the setup quickly, you can:
1. Use any 1024x1024 PNG image as a placeholder
2. Copy it to both locations (app_icon.png and app_icon_foreground.png)
3. Run the generator
4. Replace with your final design later

## Troubleshooting

### "Image not found" error
- Make sure the files are exactly at `assets/icon/app_icon.png`
- Check file names are lowercase
- Verify PNG format

### Icons not updating
- Uninstall the app completely
- Rebuild: `flutter clean && flutter build apk`
- Reinstall

### Adaptive icon looks wrong
- Make sure foreground image has transparency
- Check that the important parts are in the center "safe zone"
- Test on different Android devices/launchers

## Next Steps

1. Create or obtain your icon images
2. Place them in `assets/icon/`
3. Run `flutter pub get`
4. Run `dart run flutter_launcher_icons`
5. Build and enjoy your custom icon!

---

**Need help with icon design?** Let me know and I can provide more specific guidance or design suggestions!
