FROM python:3.12-slim as builder

# Install Poetry via pip
RUN pip install poetry

FROM builder as build

ARG REPO_URL=""
ARG REPO_USERNAME=""
ARG REPO_PASSWORD=""
ARG PYPI_API_TOKEN=""

# Copy project files
COPY . /app
WORKDIR /app

# Install dependencies and build the package
RUN poetry install --no-root \
    && poetry build

# Configure Poetry to use the appropriate repository
RUN if [ -z "$REPO_URL" ]; then \
    poetry config pypi-token.pypi $PYPI_API_TOKEN; \
    else \
    poetry config repositories.my-repo $REPO_URL \
    && poetry config http-basic.my-repo $REPO_USERNAME $REPO_PASSWORD; \
    fi

# Publish the package (assuming you have configured the repository in pyproject.toml)
RUN if [ -z "$REPO_URL" ]; then \
    poetry publish; \
    else \
    poetry publish --repository my-repo --username $REPO_USERNAME --password $REPO_PASSWORD; \
    fi

