#!/bin/bash

# Find the WristArcana database in the simulator

echo "🔍 Finding WristArcana database..."
echo ""

# Find all running simulators
DEVICE_ID=$(xcrun simctl list devices | grep "Apple Watch Series 10" | grep "Booted" | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No booted Apple Watch Series 10 simulator found"
    echo "Please launch the simulator first"
    exit 1
fi

echo "✅ Found booted simulator: $DEVICE_ID"
echo ""

# Find the app container
CONTAINER=$(xcrun simctl get_app_container "$DEVICE_ID" com.creekmasons.WristArcana.watchkitapp data 2>/dev/null)

if [ -z "$CONTAINER" ]; then
    echo "❌ WristArcana app not installed on simulator"
    echo "Please install and run the app first"
    exit 1
fi

echo "✅ App container: $CONTAINER"
echo ""

# Find database files
echo "🔍 Searching for database files..."
DB_FILES=$(find "$CONTAINER" -name "*.store" 2>/dev/null)

if [ -z "$DB_FILES" ]; then
    echo "❌ No .store files found"
    echo "The app may not have created the database yet"
    exit 1
fi

echo "✅ Found database files:"
echo "$DB_FILES" | while read -r db; do
    echo "  📁 $db"
    SIZE=$(du -h "$db" | cut -f1)
    echo "     Size: $SIZE"
   echo "     Row count: $(sqlite3 "$db" 'SELECT COUNT(*) FROM ZCARDPULL;' 2>/dev/null || echo 'N/A')"
    echo ""
done

echo ""
echo "🔍 To query the database, run:"
echo "sqlite3 \"$CONTAINER/Library/Application Support/default.store\" 'SELECT * FROM ZCARDPULL;'"
echo ""
echo "🔍 To watch for changes:"
echo "fswatch -o \"$CONTAINER/Library/Application Support/default.store\" | while read; do echo \"Database modified at \$(date)\"; done"
