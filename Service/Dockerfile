# Use the official Python image from the Docker Hub
FROM  public.ecr.aws/lambda/python:3.9

# Install necessary dependencies for Chrome and Chromedriver
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
    wget \
    unzip \
    curl \
    alsa-lib \
    atk \
    cups-libs \
    gtk3 \
    nss \
    libX11.x86_64 \
    libXcomposite.x86_64 \
    libXdamage.x86_64 \
    libXtst.x86_64 \
    fontconfig \
    freetype \
    xorg-x11-server-Xvfb \
    liberation-fonts \
    libvulkan \
    xdg-utils \
    vulkan

COPY ./chrome-installer.sh ./chrome-installer.sh
RUN chmod +x ./chrome-installer.sh
RUN ./chrome-installer.sh
RUN rm ./chrome-installer.sh

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Copy the rest of the application code into the container
COPY lambda.py .

# Command to run the application
CMD [ "lambda.handler" ]