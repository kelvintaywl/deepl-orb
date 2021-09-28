# Runs prior to every test
setup() {
    export SRC_LANG=en
    export DEEPL_API_KEY=xxx
    export FORMALITY=less
    export INPUT_FILE_PATH=in.txt
    export OUTPUT_FILE_PATH=out.txt
}

@test '1: Exit if TGT_LANG is not set' {
    echo "test" > in.txt
    run sh ./src/scripts/translate.sh
    [ "$status" -eq 1 ]
    [ "$output" = "target language is not set. Exiting" ]
}
