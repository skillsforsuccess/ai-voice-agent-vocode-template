# Use Python 3.10 slim as the base image
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    libportaudio2 \
    libportaudiocpp0 \
    portaudio19-dev \
    libasound-dev \
    libsndfile1-dev \
    ffmpeg \
    curl \
    git \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry with a specific version for consistency
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.3 python3 -
ENV PATH="/root/.local/bin:$PATH"

# Debug Python version and binary paths
RUN python --version
RUN python3 --version
RUN which python
RUN which python3
RUN python -c "import sys; print(sys.executable)"

# Set working directory
WORKDIR /code

# Copy dependency files
COPY ./pyproject.toml /code/pyproject.toml
COPY ./poetry.lock /code/poetry.lock

# Configure Poetry and install dependencies with verbose output
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi --verbose

# Copy application files
COPY main.py /code/main.py
COPY speller_agent.py /code/speller_agent.py
COPY memory_config.py /code/memory_config.py
COPY events_manager.py /code/events_manager.py
COPY config.py /code/config.py
COPY instructions.txt /code/instructions.txt
COPY ./utils /code/utils

# Create directories
RUN mkdir -p /code/call_transcripts /code/db

# Run the application with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
