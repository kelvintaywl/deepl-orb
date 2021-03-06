#! /usr/bin/env bash

# PARAM_DEEPL_API_KEY indicates the env var name
# to locate the Deepl API key.
DEEPL_API_KEY=$(eval echo "\$$PARAM_DEEPL_API_KEY")

if [ ! "$(command -v curl)" ]; then
    echo "curl is required but not found. Exiting"
    exit 1
fi

if [ ! "$(command -v jq)" ]; then
    echo "jq is required but not found. Exiting"
    exit 1
fi

if [ -z "${PARAM_TGT_LANG}" ]; then
    echo "target language is not set. Exiting"
    exit 1
fi

if [ ! -f "${PARAM_INPUT_FILE_PATH}" ]; then
    echo "input file path to a valid file is required. Exiting"
    exit 1
fi

file_ext="${PARAM_INPUT_FILE_PATH##*.}"
if [[ ! $file_ext =~ ^(docx|pptx|html|txt)$ ]]; then
    echo "input file is unsupported. Exiting"
    exit 1
fi

resp=$(curl -s -X POST \
https://api-free.deepl.com/v2/document \
-H "Content-Type: multipart/form-data" \
-F "auth_key=${DEEPL_API_KEY}" \
-F "tag_handling=xml" \
-F "source_lang=${PARAM_SRC_LANG}" \
-F "target_lang=${PARAM_TGT_LANG}" \
-F "formality=${PARAM_FORMALITY}" \
-F "file=@${PARAM_INPUT_FILE_PATH}" | jq .)

doc_id=$(echo "${resp}" | jq -r ".document_id")
doc_key=$(echo "${resp}" | jq -r ".document_key")

done=0
tries=5
while [ "${done}" -eq 0 ] && [ $tries -gt 0 ]
do
    status_resp=$(curl -s -X POST \
    "https://api-free.deepl.com/v2/document/${doc_id}" \
    -d "auth_key=${DEEPL_API_KEY}" \
    -d "document_key=${doc_key}" | jq .)

    ((tries=tries-1))
    status=$(echo "${status_resp}" | jq -r ".status")

    if [ "${status}" = "done" ]; then
        ((done=1))
        break
    fi
    
    if [ "${status}" = "error" ]; then
        echo "Failed to upload document to Deepl Document API."
        break
    fi

    if [ "${tries}" -eq 0 ]; then
        echo "Failed to fetch document from Deepl Document API after 5 tries."
        break
    fi

    secs=$(echo "${status_resp}" | jq -r ".seconds_remaining")
    printf "Sleeping for %d secs before polling again...\n" "${secs}"
    sleep "$((secs))"
done

if [ "${done}" -eq 0 ]; then
    exit 1
fi


bin_data=$(curl -s -X POST \
"https://api-free.deepl.com/v2/document/${doc_id}/result" \
-d "auth_key=${DEEPL_API_KEY}" \
-d "document_key=${doc_key}")

echo "${bin_data}" > "${PARAM_OUTPUT_FILE_PATH}"
