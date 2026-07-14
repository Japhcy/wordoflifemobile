# Dockerfile
FROM ollama/ollama:latest

# Pull Mistral during build
RUN ollama pull mistral

# Expose the port
EXPOSE 11434

# Start Ollama server
CMD ["ollama", "serve"]