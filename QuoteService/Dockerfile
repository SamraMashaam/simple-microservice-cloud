# Use Python 3.11 slim image for smaller size
FROM python:3.11-slim


# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
# Copy application code
COPY main.py quotes.txt ./

# Expose port
EXPOSE 5000
# Run as non-root user for security
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Start application
CMD ["python", "main.py"]
