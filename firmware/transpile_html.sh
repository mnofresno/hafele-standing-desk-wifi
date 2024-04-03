#!/bin/bash

template_file="html/html_header_template.h"

if [ ! -f "$template_file" ]; then
    echo "Error: html_header_template.h not found."
    exit 1
fi

for html_file in html/*.html; do
    filename=$(basename "$html_file" .html)
    uppercase_filename="${filename^^}"

    html_content=$(cat "$html_file")

    escaped_content=$(printf "%s" "$html_content" | tr '\n' '\\n' | sed -e 's/\\/\\\\/g' -e 's/\*/\\*/g' -e 's/\$/\\$/g' -e 's/"/\\"/g' -e 's/\//\\\//g')
    replaced_content=$(sed -e "s/%REPLACE_FILENAME%/$uppercase_filename/g" -e "s/%REPLACE_CONTENT%/$escaped_content/g" "$template_file")
    replaced_content=$(echo "$replaced_content" | tr '\\' '\n')

    new_file="html/$filename.h"
    echo "$replaced_content" > "$new_file"

    echo "Created $new_file"
done

echo "All .h files created successfully."
