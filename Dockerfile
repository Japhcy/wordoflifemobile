FROM ollama/ollama:latest

RUN ollama serve & \
    sleep 5 && \
    ollama pull mistral

EXPOSE 11434

CMD ["ollama", "serve"]