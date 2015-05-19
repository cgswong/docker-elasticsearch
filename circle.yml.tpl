general:
  branches:
    ignore:
      - feat\/.*/
      - fix\/.*/
machine:
  services:
    - docker

dependencies:
  cache_directories:
    - "~/docker"
  override:
    - docker info
    - if [ -e ~/docker/image.tar ]; then docker load --input ~/docker/image.tar; fi
    - docker build -t elasticsearch:%%VERSION%% .
    - mkdir -p ~/docker; docker save elasticsearch:%%VERSION%% > ~/docker/image.tar

test:
  override:
    - docker run -d --publish 9200:9200 --publish 9300:9300 elasticsearch:%%VERSION%%; sleep 10
    - curl --retry 10 --retry-delay 5 --location --verbose http://localhost:9200
    - ./build.sh test:
      files:
        - versions/**/options

deployment:
  hub:
    branch: master
    commands:
      - docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASSWORD
      - docker push cgswong/elasticsearch:%%VERSION%%
