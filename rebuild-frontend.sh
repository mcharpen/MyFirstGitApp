#!/bin/bash
# Rebuild and push frontend Docker image after code changes

set -e

echo "Building frontend Docker image..."
cd frontend
docker build -t mcharpen5/myfirstapp-frontend:latest .

echo "Pushing to Docker Hub..."
docker push mcharpen5/myfirstapp-frontend:latest

echo "Restarting frontend deployment in Kubernetes..."
kubectl rollout restart deploy/frontend -n myfirstgitapp

echo "Done! Waiting for rollout to complete..."
kubectl rollout status deploy/frontend -n myfirstgitapp

echo "Frontend updated successfully!"
