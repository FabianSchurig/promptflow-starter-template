FROM python:3.12-slim AS builder

# Install Poetry via pip
RUN pip install poetry

# Install curl
RUN apt-get update && apt-get install -y curl

FROM builder AS build

# Copy project files
COPY . /app
WORKDIR /app

# Extract version from pyproject.toml and set it as PACKAGE_VERSION
RUN PACKAGE_VERSION=$(grep -oP '(?<=version = ")[^"]*' pyproject.toml)

# Install dependencies and build the package
RUN poetry install --no-root \
    && poetry build

# Configure Poetry to use the appropriate repository
RUN --mount=type=secret,id=pypi_api_token \
    --mount=type=secret,id=repo_password \
    if [ -z "$REPO_URL" ]; then \
    poetry config pypi-token.pypi $(cat /run/secrets/pypi_api_token); \
    else \
    poetry config repositories.my-repo $REPO_URL \
    && poetry config http-basic.my-repo $REPO_USERNAME $(cat /run/secrets/repo_password); \
    fi

FROM build AS test

# Run tests
RUN poetry run pytest

FROM build AS publish

# Publish the package (assuming you have configured the repository in pyproject.toml)
RUN --mount=type=secret,id=pypi_api_token \
    --mount=type=secret,id=repo_password \
    if [ -z "$REPO_URL" ]; then \
    if ! curl --silent --fail https://pypi.org/project/promptflow-starter-template/$PACKAGE_VERSION/ > /dev/null; then \
        poetry publish; \
    else \
        echo "Package version $PACKAGE_VERSION already exists on PyPI. Skipping publish step."; \
    fi; \
    else \
    poetry publish --repository my-repo --username $REPO_USERNAME --password $(cat /run/secrets/repo_password); \
    fi
