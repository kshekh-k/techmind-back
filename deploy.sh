# Create docker image
docker build \
  --build-arg NODE_ENV=production \
  # --build-arg STRAPI_URL=https://api.example.com \ # Uncomment to set the Strapi Server URL
  -t techmind:latest \ # Replace with your image name
  -f Dockerfile.prod .


# Run the docker container
docker run -d \
  --name techmind \ # Replace with your container name
  -p 1437:1337 \ # Expose port 1437 on the host to port 1337 in the container
  techmind:latest