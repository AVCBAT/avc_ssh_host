#!/bin/bash

# Logo Processing Script for Behavioural Dragon Pro
# This script processes the uploaded DragonPro.png into multiple optimized formats

echo "🐉 Processing Behavioural Dragon Pro logo..."

# Create directories if they don't exist
mkdir -p /volume1/docker/behavioural_dragon_pro/public/images/processed
mkdir -p /volume1/docker/behavioural_dragon_pro/public/icons

# Paths
ORIGINAL="/volume1/docker/behavioural_dragon_pro/public/images/DragonPro.png"
OUTPUT_DIR="/volume1/docker/behavioural_dragon_pro/public/images"
ICONS_DIR="/volume1/docker/behavioural_dragon_pro/public/icons"

echo "📏 Creating horizontal logo versions (400x120px)..."
# Horizontal logo for header and landing
convert "$ORIGINAL" -resize 400x120 -background transparent -gravity center -extent 400x120 "$OUTPUT_DIR/logo-horizontal.png"

echo "🔲 Creating square version (120x120px)..."
# Square logo for avatars and social media  
convert "$ORIGINAL" -resize 120x120^ -background transparent -gravity center -extent 120x120 "$OUTPUT_DIR/logo-square.png"

echo "📱 Creating vertical version (200x300px)..."
# Vertical logo for mobile layouts
convert "$ORIGINAL" -resize 200x300 -background transparent -gravity center -extent 200x300 "$OUTPUT_DIR/logo-vertical.png"

echo "🌟 Creating favicons..."
# Favicon 32x32
convert "$ORIGINAL" -resize 32x32 -background transparent "$ICONS_DIR/favicon-32x32.png"

# Favicon 16x16  
convert "$ORIGINAL" -resize 16x16 -background transparent "$ICONS_DIR/favicon-16x16.png"

# Apple Touch Icon
convert "$ORIGINAL" -resize 180x180 -background transparent "$ICONS_DIR/apple-touch-icon.png"

# PWA Icons
convert "$ORIGINAL" -resize 192x192 -background transparent "$ICONS_DIR/android-chrome-192x192.png"
convert "$ORIGINAL" -resize 512x512 -background transparent "$ICONS_DIR/android-chrome-512x512.png"

echo "🖼️ Creando Open Graph image (1200x630px)..."
# Crear imagen para Open Graph con fondo
convert -size 1200x630 xc:"#f8fafc" \
        \( "$ORIGINAL" -resize 400x400 \) \
        -gravity center -composite \
        "$OUTPUT_DIR/og-image.png"

echo "✅ Logo processing complete!"
echo "📁 Archivos creados en:"
echo "   - $OUTPUT_DIR/logo-horizontal.png"
echo "   - $OUTPUT_DIR/logo-square.png" 
echo "   - $OUTPUT_DIR/logo-vertical.png"
echo "   - $ICONS_DIR/favicon-*.png"
echo "   - $OUTPUT_DIR/og-image.png"
