# Using the Docker NEST Builder


docker run -it --rm -v $(pwd):/opt/data nestsim/nest:builder build

## Build the docker

docker build -t nestsim/nest:builder .