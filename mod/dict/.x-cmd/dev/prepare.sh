
build(){
    docker build -t dict -f text.Dockerfile .
}

work(){
    docker run -w /x -v "$(pwd)":/x -it dict zsh -c ". v0"
}

cli(){
    docker run -w /x -v "$(pwd)":/x -it dict ${1:-bash}
}

