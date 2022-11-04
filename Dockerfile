# syntax=docker/dockerfile:1
# Using the Ubuntu image (our OS)
FROM ubuntu:latest

WORKDIR /app
# Update package manager (apt-get) 
# and install (with the yes flag `-y`)
# Python and Pip
RUN apt-get update && apt-get install -y \
python3 \
python3-pip \ 
python-is-python3

# Copy our script into the container
COPY script.py /app/script.py

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
