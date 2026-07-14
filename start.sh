#!/bin/bash

echo "🚀 Starting Ollama server..."
ollama serve &

echo "⏳ Waiting for server to initialize..."
sleep 10

echo "📦 Pulling Mistral model..."
ollama pull mistral

echo "✅ Ollama is ready on port 11434!"
wait