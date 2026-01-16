#!/bin/bash

docker run --rm --init -v $PWD/presentation/:/home/marp/app/ -e LANG=$LANG -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli:v4.2.3 -I . --pdf --allow-local-files

# Marp picks all the md files and converts them to pdfs
# which is not necessary for the README.md
if [[ -e './presentation/README.pdf' ]]
then
    rm ./presentation/README.pdf
fi
