#!/bin/bash

# Print table header
printf "%-35s | %-40s\n" "Application" "Homebrew Status"
printf "%s\n" "------------------------------------+------------------------------------------"

# Find apps
find /Applications ~/Applications -maxdepth 1 -type d -name "*.app" -print0 | while IFS= read -r -d $'\0' app_path; do
  app_name=$(basename "$app_path" .app)

  # Format app name
  search_term=$(echo "$app_name" | sed -e 's/@.*//' -e 's/ /-/g' -e 's/[^A-Za-z0-9-]/-/g')

  # Determine status
  if brew search --cask "$search_term" 2>/dev/null | grep -i -q "$search_term\$"; then
    status="Found cask ✅🍺"
  elif brew search "$search_term" 2>/dev/null | grep -i -q "$search_term\$"; then
    status="Found formulae ✅🧪"
  else
    status="Not found ❌"
  fi

  # Print formatted row
  printf "%-35s | %-40s\n" "$app_name" "$status"
done
