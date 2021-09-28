#! /usr/bin/env bash

if [ ! $(command -v curl) ]; then
    echo "curl is required but not found. Exiting"
    exit 1
fi

if [ ! $(command -v jq) ]; then
    echo "jq is required but not found. Exiting"
    exit 1
fi

if [ -z "${TGT_LANG}" ]; then
    echo "target language is not set. Exiting"
    exit 1
fi

# https://www.deepl.com/docs-api/translating-text/request/
for F in $@; do
    resp=$(curl -s -X POST \
    https://api-free.deepl.com/v2/translate \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "auth_key=${DEEPL_API_KEY}" \
    -d "source_lang=${SRC_LANG}" \
    -d "target_lang=${TGT_LANG}" \
    -d "tag_handling=${TAG_HANDLING}" \
    -d "preserve_formatting=0" \
    -d "split_sentences=1" \
    -d "formality=${FORMALITY}" \
    -d "text=$(cat $F)" | jq -r ".translations[0].text")
    # truncate
    echo $resp > $F
done 
