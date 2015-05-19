#!/usr/bin/env bats

@test "Confirm installed ES version" {
  run docker run cgswong/elasticsearch:1.5.2 /opt/elasticsearch/bin/elasticsearch -v
  [[ $output =~ "Version: 1.5.2" ]]
}

@test "Confirm JDK version" {
  run docker run cgswong/elasticsearch:1.5.2 /usr/local/java/jdk/bin/java -version
  [[ $lines[1] =~ "1.8.0_45-b45" ]]
}

@test "Confirm ES is available" {
  run docker run -d --name elasticsearch --publish 9200:9200 cgswong/elasticsearch:1.5.2
  sleep 10
  curl --retry 10 --retry-delay 5 --location --verbose http://localhost:9200
  [ $status -eq 0 ]
}
