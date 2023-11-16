terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "apache" {
  name = "httpd:2.4"
}

# Create a container
resource "docker_container" "apache" {
  image = docker_image.apache.image_id
  name  = "apache"
  ports {
    external = 80
    internal = 80
  }

  volumes {
    container_path = "/usr/local/apache2/htdocs"
    host_path      = "/home/vagrant/siteExample/"
  }
}
