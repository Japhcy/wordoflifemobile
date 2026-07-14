FROM ollama/ollama:latest

# Copy and set up the script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ✅ Run the script directly
CMD ["sh", "/start.sh"]