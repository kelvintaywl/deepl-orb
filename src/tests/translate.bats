# Runs prior to every test
setup() {
    export SRC_LANG=en
    export DEEPL_API_KEY=xxx
    export FORMALITY=less
}

@test '1: Exit if TGT_LANG is not set' {
    echo "test" > in.txt
    sh ./src/scripts/translate.sh in.txt out.txt
}
