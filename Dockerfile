
# ========== dockerfile by kiran  ================

FROM  ubuntu:latest   # we use custom images in real envirionments
LABEL  name="dev_environment"  # tag is comes under  LABEL

RUN makedir /app1
RUN groupadd appuser && useradd -r -g  appuser appuser
WORKDIR /app 
USER /appuser  # generally in orgnaization we do not use USER  , bcz if we give it,user gets root dir permissions 

ENV AWS_ACCESS_KEY_ID= XLLLL\
    AWS_SECRETES_KEY_ID=AQ\
    AWS_DEFAULT_REGION=ap-south-1a


COPY  file  /var/www/html   # default location for nginx 
COPY  file2 /var/www/html
ADD  file3 /var/www/html   # 
ADD  <URL>  /var/www/html/  # it download and copy it to /var/www/html location



ARG T_VERSION='1.6.6'\
    P_VERSION='1.8.0'

RUN  apt update && apt install -y  jq net-tools  curl wget unzip\
     && apt install -y nginx iputils-ping
    
RUN wget <terraform_url ${T_VERSION}>\
    && wget <packer url ${P_VERSION}\
    && unzip <terraorm packer> && unzip <packer> \
    && chmod 777 terraform  && chmod 777 packer\
    && ./terraform version && ./packer version

CMD ["nginx","-g ","daemon off " ]  # this keeeps nginx is running and run contaienr in background 



# docker build -t  dockerfile.dev .  // dockerfile.dev is  dcodker file name
# docker build -t gashok120707/custom:v1 -f dockerfile.dev .   // to tag along with build
# docker build -t gashok120707/custom:v1 -f dockerfile.dev .   --no-cache   // to build image from starting  with out using storing cache
# docker run --rm -d --name  app1 -p 8000:80 gashok120707/custom:v1

# #  how to  pass build arguments?
by using ARG, WE  can pass build arguments during build time 
# # how you can over ride argumetns?
docker build -t gashok120707/custom:v1  --build-arg  T_VERSION='1.6.7' --build-arg P_VERSION='1.9.9.' -f dockerfile.dev . 

# to see in detial veiw of each stage while building image
docker build -t gashok120707/custom:v1  --build-arg  T_VERSION='1.6.7' --build-arg P_VERSION='1.9.9.' -f dockerfile.dev . 

# to view history of docker images 
docker history <image name>


# #  how to  pass environments variables?
by using ENV  we can pass environment variables during container run time
# - 
# -

# to see environment variables in container 
docker exec -it contaienr_name  env    // we can see envirionments variables

# how you pass env varialbes while running contienrs 
docker run --rm  -d --name app2 -p 8010:80 -e AWS_ACCESS_KEY_ID=xyz -e AWS_SECRETES_KEY_ID=abc <image_name>

# docker system prune
it deletes all old build  images data and  dangling images(), so that it cleans unnessecary  images and freee space

# docker life cycle
crate docker file- build it-  create image- run continaer


# diff b/n cmd and entry point
CMD ["/usr/bin/ping", "-c 4 ", "www.ggole.com"]
    # if we mention this in docker file and run container and then i want to test it from command line and  want to ping youtube
CMD ["/usr/bin/ping", "-c 4 ", "www.youtube.com"]  
  # evnethough docker file has google.com , we can change it over command line

ENTRYPOINT  ["/usr/bin/ping", "-c 4 ", "www.ggole.com"]  # here in docker file we have google.com and want to try to ping over command line to youtube, it does not support 

EXPOSE #  it is a documentation b/n developer and who build the image

COPY   # copy file from loacel dir to dir 
ADD   get files from s3 / any other over the internet




# ==================== docker file by abhi ======================================== 

# Containerize the go application that we have created
# This is the Dockerfile that we will use to build the image
# and run the container

# Start with a base image
FROM golang:1.21 as base

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory
COPY go.mod ./

# Download all the dependencies
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application
RUN go build -o main .

#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
FROM gcr.io/distroless/base

# Copy the binary from the previous stage
COPY --from=base /app/main .

# Copy the static files from the previous stage
COPY --from=base /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["./main"]


# FROM, ADD, ARG,CMD, COPY, ENTRYPOINT, ENV, EXPOSE,LABEL,
#ONBUILD,RUN,STOPSIGNAL,STRESS,USER,VOLUME,WORKDIR



FROM python:3.9
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
ENTRYPOINT ["python", "my_app.py"]  # Set ENTRYPOINT as the default command (like the main light switch)
CMD ["python", "my_app.py", "--default-settings"]   # Set CMD with default arguments (like a dimmer switch with default settings)

# +++++++++++++++++++++++++++ different docker files ++++++++++++++++++++++++++++
FROM        nginx
RUN         rm -rf /usr/share/nginx/html/*
COPY        ./ /usr/share/nginx/html/
COPY        nginx-roboshop.conf /etc/nginx/conf.d/default.conf
COPY        nginx-main.conf   /etc/nginx/nginx.conf

FROM        amazoncorretto:17
RUN         yum install unzip -y
RUN         mkdir /app
WORKDIR     /app
COPY        target/shipping-1.0.jar /app/shipping.jar
COPY        run.sh .
ENTRYPOINT  ["bash", "run.sh"]
RUN         curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip ; unzip newrelic-java.zip
COPY        newrelic.yaml /app/newrelic/newrelic.yml

FROM          python:3.6
RUN           mkdir /app
WORKDIR       /app
COPY          payment.ini payment.py rabbitmq.py requirements.txt /app
RUN           pip3.6 install -r requirements.txt
COPY          run.sh .
ENTRYPOINT    ["bash", "run.sh"]
#  +++++++++++++++++++++++++++++ ++++++++++++++++++++++++++

FROM maven:3.9.0-eclipse-temurin-17 as build
WORKDIR /app
COPY . .
RUN mvn clean install

FROM eclipse-temurin:17.0.6_10-jdk
WORKDIR /app
COPY --from=build /app/target/demoapp.jar /app/
EXPOSE 8080
CMD ["java", "-jar","demoapp.jar"]



#  +++++++++++++++++++++   this is multi stage   ++++++++++++++++++++++++++
# 
FROM openjdk:11 as base 
WORKDIR /app
COPY . .        # it means all files in this dir(first dot) are copied to (second dot) that is /app
RUN chmod +x gradlew
RUN ./gradlew build 

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war .     # to get detilas from above dockerfile, that are in chache, so we use  --from=stage(base  in our case ) , it is alias
  #/app/build/libs/  in  this that war file is stored
RUN rm -rf ROOT && mv sampleWeb-0.0.1-SNAPSHOT.war ROOT.war   #we remove default root folder and add our webapp to root folder

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# this is multi stage 
FROM openjdk:11 as base 
WORKDIR /app
COPY . . 
RUN chmod +x gradlew
RUN ./gradlew build 

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv sampleWeb-0.0.1-SNAPSHOT.war ROOT.war
 
# ============================= chat gpt dockerfile ===============================

FROM openjdk:11  as base 	# Stage 1: Build the Java application
WORKDIR /app		         # Set the working directory
COPY pom.xml .		        # Copy the Maven project files and download dependencies
COPY src ./src
RUN mkdir -p /app/target && \
    javac -d /app/target src/*.java && \
    jar -cvf app.jar -C /app/target .

FROM openjdk:11-jre-slim		# Stage 2: Create a minimal runtime image
WORKDIR /app  				# Set the working directory
COPY --from=build /app/app.jar .	# Copy the JAR file from the build stage
CMD ["java", "-jar", "app.jar"]		# Define the command to run your Java application


# ===================================  chatgpt dockerfile for nginx================================

FROM openjdk:11  as base	 # Stage 1: Build the Java application
WORKDIR /app		       # Set the working directory
COPY pom.xml .		        # Copy the Maven project files and download dependencies
COPY src ./src
RUN mkdir -p /app/target && \
    javac -d /app/target src/*.java && \
    jar -cvf app.jar -C /app/target .

FROM openjdk:11-jre-slim AS runtime		# Stage 2: Create a minimal runtime image
WORKDIR /app					# Set the working directory
COPY --from=build /app/app.jar .		# Copy the JAR file from the build stage
FROM nginx:latest				# Stage 3: Build NGINX-based runtime image
RUN rm /etc/nginx/conf.d/default.conf		# Remove the default NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf		# Copy your NGINX configuration file (e.g., nginx.conf)
COPY --from=runtime /app/app.jar /usr/share/nginx/html/app.jar		# Copy the JAR file from the Java runtime stage to NGINX's HTML directory
EXPOSE 8080								# Expose the port your Java application will run on (adjust as needed)


# ++++++++++++++++++++++++++++ docker files for different languages +++++++++++++++++++++++++++++++++++


FROM openjdk:17-slim AS base		# Stage 1: Download slim base image (recommended for production)
WORKDIR /app		# Set working directory for base stage
EXPOSE 8080	# Expose port (adjust if needed)
ENV APP_NAME my-java-app	# Define environment variable (optional)

FROM base AS builder		# Stage 2: Compile and copy application (depends on base stage)
COPY pom.xml ./		# Copy Maven pom.xml (adjust based on your build tool)
RUN mvn compile		# Install dependencies using Maven (adjust based on your build tool)
FROM base AS app		# Stage 3: Copy final application (depends on builder stage)
COPY target/  ./		# Copy compiled classes and resources
USER appuser	# Set user (optional)	
ENTRYPOINT ["java", "-jar", "app.jar"]		# Entrypoint script (replace with your actual command)
LABEL description="A Docker image for my Java application"		# Label the image for easy identification
# STOPSIGNAL SIGTERM		# Optional: Define a stop signal (e.g., for graceful shutdown)
# STRESS ["stress", "--cpu", "1", "--vm", "2", "--vm-bytes", "256M"]		# Optional: Stress test during build (uncomment to enable)
# VOLUME /data		# Optional: Define a volume to persist data (uncomment to enable)
# WORKDIR /app		# Optional: Set a working directory for the running container (uncomment to enable)

# Explanation:

# Multi-stage Build:

# Stage 1 (base): Downloads the openjdk:17-slim image and sets the working directory. Exposes port 8080 (adjust if needed) and defines an environment variable (optional).
# Stage 2 (builder): Depends on the base stage and copies the pom.xml file. Uses RUN to install dependencies using Maven (adjust the command for your build tool).
# Stage 3 (app): Depends on the builder stage, ensuring compilation happens before copying the application. Copies the compiled classes and resources from the target directory.
# Other Options:

# COPY: Copies files from the host to the container image at specific stages.
# ARG: Defines build arguments that can be passed when building the image.
# CMD (default): Defines the default command to run when the container starts (overridden by ENTRYPOINT).
# ENTRYPOINT (preferred): Specifies the executable entry point for the container.
# ENV: Sets environment variables within the container.
# EXPOSE: Exposes a port for the container, making it accessible from the host.
# LABEL: Adds metadata labels to the image for better organization.
# (Optional) STOPSIGNAL: Defines the signal sent to the container process during termination (e.g., for graceful shutdown).
# (Optional) STRESS: (Uncomment to enable) Runs stress tests during the build process to stress test the application.
# (Optional) VOLUME: Defines a volume mount point for persisting data outside the container.
# (Optional) WORKDIR: Sets the working directory for the running container process.
# Using depends_on_stage:

# This example demonstrates the concept of depending on stages using multi-stage builds. Stage 2 (builder) depends on stage 1 (base) to ensure the base image is downloaded before building the application. Similarly, stage 3 (app) depends on stage 2 (builder) to guarantee successful compilation before copying the final application.

FROM python:3.9-slim AS base
WORKDIR /app
EXPOSE 8000
ENV APP_NAME my-python-app	# Define environment variable (optional)
FROM base AS builder		# Stage 2: Copy requirements and install dependencies (depends on base stage)
COPY requirements.txt ./
RUN pip install -r requirements.txt		# Install Python dependencies using pip
FROM builder AS app		# Stage 3: Copy application code (depends on builder stage)
COPY . .
USER appuser
ENTRYPOINT ["python", "app.py"]		# Entrypoint script (replace with your actual command)
LABEL description="A Docker image for my Python application"		# Label the image for easy identification
# STOPSIGNAL SIGTERM
# Optional: Stress test during build (uncomment to enable)
# STRESS ["stress", "--cpu", "1", "--vm", "2", "--vm-bytes", "256M"]
# VOLUME /data		# Optional: Define a volume to persist data (uncomment to enable)
# WORKDIR /app		# Optional: Set a working directory for the running container (uncomment to enable)


 
FROM node:18-slim AS base
WORKDIR /app 
EXPOSE 3000
ENV APP_NAME=my-node-app		# Define environment variable (optional)
FROM base AS builder		# Stage 2: Install dependencies (depends on base stage
COPY package.json ./		# Copy package.json
RUN npm install		# Install Node.js dependencies using npm
FROM builder AS app		# Stage 3: Copy application code (depends on builder stage)
COPY . .
USER nodeuser
ENTRYPOINT ["npm", "start"]		# Entrypoint script (replace with your actual command)
LABEL description="A Docker image for my Node.js application"		# Label the image for easy identification
# STOPSIGNAL SIGTERM
# STRESS ["stress", "--cpu", "1", "--vm", "2", "--vm-bytes", "256M"]
# VOLUME /data
# WORKDIR /app

==================== docker file by abhi ========================================

# Containerize the go application that we have created
# This is the Dockerfile that we will use to build the image
# and run the container

# Start with a base image
FROM golang:1.21 as base

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory
COPY go.mod ./

# Download all the dependencies
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application
RUN go build -o main .

#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
FROM gcr.io/distroless/base

# Copy the binary from the previous stage
COPY --from=base /app/main .

# Copy the static files from the previous stage
COPY --from=base /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["./main"]



