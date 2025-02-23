FROM python:3.12-slim as builder

# Install Poetry via pip
RUN pip install poetry

FROM builder as build

ARG REPO_URL=""
ARG REPO_USERNAME=""
ARG REPO_PASSWORD=""
ARG PYPI_API_TOKEN=""
ARG PACKAGE_VERSION=""

# Copy project files
COPY . /app
WORKDIR /app

# Extract version from pyproject.toml and set it as PACKAGE_VERSION
RUN PACKAGE_VERSION=$(grep -oP '(?<=version = ")[^"]*' pyproject.toml)

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

FROM build as test

# Run tests
RUN poetry run pytest

FROM build as publish

# Publish the package (assuming you have configured the repository in pyproject.toml)
RUN if [ -z "$REPO_URL" ]; then \
    if ! curl --silent --fail https://pypi.org/project/promptflow-starter-template/$PACKAGE_VERSION/ > /dev/null; then \
        poetry publish; \
    else \
        echo "Package version $PACKAGE_VERSION already exists on PyPI. Skipping publish step."; \
    fi; \
    else \
    poetry publish --repository my-repo --username $REPO_USERNAME --password $REPO_PASSWORD; \
    fi
