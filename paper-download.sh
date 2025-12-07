#!/usr/bin/env bash

set -euo pipefail

# URL to fetch
URL="https://wg21.link/index.json"

# Fetch the JSON data
json=$(curl -s $URL)

# Parse the JSON and iterate over each entry
echo "$json" | jq -c 'to_entries | .[] | select(.value.type == "paper")' | while read -r i; do
    # Extract data
    key=$(echo $i | jq -r '.key')

    echo "check $key"

    if [[ "${key:0:1}" != P ]] ; then continue ; fi

    long_link=$(echo $i | jq -r '.value.long_link')
    link_ext="${long_link##*.}"

    # Download and convert if it's an HTML page
    if [[ "$link_ext" == "html" || "$link_ext" == ".htm" ]]; then
        if [[ -f "./${key}.pdf" ]] ; then continue ; fi
        echo "download $key"
        wget --load-cookies <(echo 'wiki.edg.com	FALSE	/	FALSE	0	TWIKISID	ceff3479724589d3cb52b0d1c7eb70b8') "$long_link" -O "./${key}.${link_ext}" || continue
        google-chrome --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="./${key}.pdf" "./${key}.html"
        rm "./${key}.html" # Clean up HTML file
    elif [[ "$link_ext" == "pdf" ]] ; then
        # Direct download PDF
        if [[ -f "./${key}.pdf" ]] ; then continue ; fi
        echo "download $key"
        wget --load-cookies <(echo 'wiki.edg.com	FALSE	/	FALSE	0	TWIKISID	ceff3479724589d3cb52b0d1c7eb70b8') "$long_link" "$long_link" -O "./${key}.pdf" || continue
    fi
done
