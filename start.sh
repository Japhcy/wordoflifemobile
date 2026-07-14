#!/bin/bash
# start.sh

echo "Starting Ollama server..."
ollama serve &

echo "Waiting for server to start..."
sleep 5

echo "Pulling Mistral model..."
ollama pull mistral

echo "Mistral is ready!"
wait