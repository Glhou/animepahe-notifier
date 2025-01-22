# Use the official Python image from the Docker Hub
FROM  public.ecr.aws/lambda/python:3.8

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Copy the rest of the application code into the container
COPY lambda.py .

# Command to run the application
CMD [ "lambda.handler" ]