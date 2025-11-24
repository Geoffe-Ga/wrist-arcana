#!/bin/bash
# import_to_asset_catalog.sh - Import processed card images to Xcode Asset Catalog
#
# This script copies the prepared imagesets from RWS_Cards_ForXcode/ into the
# Xcode Asset Catalog, replacing any existing distorted images.

set -e

SOURCE_DIR="RWS_Cards_ForXcode"
ASSET_CATALOG="../WristArcana/Resources/Assets.xcassets"
TARGET_DIR="$ASSET_CATALOG/RiderWaite"

echo "📦 Importing card images to Xcode Asset Catalog..."
echo ""

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: $SOURCE_DIR not found"
    echo "   Run ./prepare_files_for_xcode.sh first"
    exit 1
fi

# Verify Asset Catalog exists
if [ ! -d "$ASSET_CATALOG" ]; then
    echo "❌ Error: Asset Catalog not found at $ASSET_CATALOG"
    echo "   Are you running from the scripts/ directory?"
    exit 1
fi

# Create RiderWaite folder if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "📁 Creating RiderWaite folder in Asset Catalog..."
    mkdir -p "$TARGET_DIR"

    # Create Contents.json for the folder
    cat > "$TARGET_DIR/Contents.json" <<EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "provides-namespace" : true
  }
}
EOF
else
    echo "📁 RiderWaite folder already exists in Asset Catalog"
fi

# Count imagesets to import
total_imagesets=$(ls -1d "$SOURCE_DIR"/*.imageset 2>/dev/null | wc -l | xargs)
if [ "$total_imagesets" -eq 0 ]; then
    echo "❌ Error: No imagesets found in $SOURCE_DIR"
    exit 1
fi

echo "📊 Importing $total_imagesets card imagesets..."
echo ""

imported=0
updated=0
failed=0

for imageset in "$SOURCE_DIR"/*.imageset; do
    basename=$(basename "$imageset")
    cardname="${basename%.imageset}"

    target_path="$TARGET_DIR/$basename"

    if [ -d "$target_path" ]; then
        # Update existing imageset
        echo "  🔄 Updating $cardname..."
        rm -rf "$target_path"
        ((updated++))
    else
        # Create new imageset
        echo "  ➕ Adding $cardname..."
        ((imported++))
    fi

    # Copy imageset directory
    if cp -R "$imageset" "$target_path" 2>/dev/null; then
        # Verify all three resolutions exist
        if [ ! -f "$target_path/${cardname}@1x.png" ] || \
           [ ! -f "$target_path/${cardname}@2x.png" ] || \
           [ ! -f "$target_path/${cardname}@3x.png" ]; then
            echo "     ⚠️  Missing resolution files for $cardname"
            ((failed++))
        fi
    else
        echo "     ❌ Failed to copy $cardname"
        ((failed++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

total_in_catalog=$(ls -1d "$TARGET_DIR"/*.imageset 2>/dev/null | wc -l | xargs)
echo "✅ Import complete!"
echo "   New imagesets:     $imported"
echo "   Updated imagesets: $updated"
echo "   Total in catalog:  $total_in_catalog"

if [ $failed -gt 0 ]; then
    echo "   ⚠️  Failed:          $failed"
fi

echo ""

# Verify aspect ratios of imported images
echo "🔍 Verifying imported image aspect ratios..."
sample_cards=("major_00" "cups_01" "wands_01" "swords_01" "pentacles_01")
all_correct=true

for card in "${sample_cards[@]}"; do
    img_path="$TARGET_DIR/${card}.imageset/${card}@3x.png"
    if [ -f "$img_path" ]; then
        aspect=$(identify -format "%[fx:w/h]" "$img_path" 2>/dev/null)
        if [ -n "$aspect" ]; then
            # Check if aspect is within acceptable range (0.55-0.60)
            is_too_wide=$(echo "$aspect > 0.60" | bc -l)
            is_too_narrow=$(echo "$aspect < 0.55" | bc -l)

            if [ "$is_too_wide" -eq 1 ] || [ "$is_too_narrow" -eq 1 ]; then
                echo "   ❌ $card: aspect $aspect (out of range)"
                all_correct=false
            else
                echo "   ✅ $card: aspect $aspect"
            fi
        fi
    fi
done

echo ""

if [ "$all_correct" = true ]; then
    echo "🎯 Success! All card images imported with correct aspect ratios"
    echo "   Asset Catalog: $TARGET_DIR"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Xcode will automatically detect the changes"
    echo "   2. Build and run to verify: xcodebuild build -scheme \"WristArcana Watch App\""
    echo "   3. Test on simulator or device"
    exit 0
else
    echo "⚠️  Warning: Some images may have incorrect aspect ratios"
    echo "   Review the verification output above"
    exit 1
fi
