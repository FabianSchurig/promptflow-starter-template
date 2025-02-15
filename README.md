## promptflow-starter-template

This project, `promptflow-starter-template`, uses a modern tech stack to develop applications with Large Language Models (LLMs) and the Promptflow framework. The key technologies are:

- **Promptflow**: Microsoft Promptflow LLM Framework.
- **FastAPI**: High-performance API framework.
- **Poetry**: Dependency management and packaging.
- **Docker**: Containerization platform.
- **Visual Studio Code**: Code editor with development container support.
- **PyPi**: Your promptflow can be packaged and pushed to PyPi or your own Python registry (JFrog Artifactory).

### Purpose

The `promptflow-starter-template` simplifies setting up and managing LLM tools, making integration easier. It packages promptflow with Poetry and runs it with FastAPI in a Docker container.

### Usage

To use the `promptflow-starter-template`, follow these steps:

#### Prerequisites

- An Azure subscription - Create one for free [here](https://azure.microsoft.com/free/cognitive-services?azure-portal=true).
- An Azure OpenAI Service resource with either gpt-4o or the gpt-4o-mini models deployed. We recommend using standard or global standard model deployment types for initial exploration. For more information about model deployment, see the [resource deployment guide](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource).

#### Steps

1. **Setup the .devcontainer/devcontainer.env**:
    Create a `.devcontainer/devcontainer.env` file with the following content:
    ```env
    OPENAI_API_KEY=your_openai_api_key
    OPENAI_API_BASE=your_openai_api_base_url
    ```
    Replace `your_openai_api_key` with your actual OpenAI API key and `your_openai_api_base_url` with your Azure OpenAI API base URL.

2. **Verify that the connection.yaml matches your deployment**:
    Create a `connection.yaml` file with the following content:
    ```yaml
    $schema: https://azuremlschemas.azureedge.net/promptflow/latest/AzureOpenAIConnection.schema.json
    name: open_ai_connection
    type: azure_open_ai
    module: promptflow.connections
    api_key: "${env.OPENAI_API_KEY}"
    api_base: "<user-input>"
    api_version: "2024-10-01-preview"
    api_type: "azure"
    ```
    Replace `<user-input>` with your Azure OpenAI API base URL.

3. **Build and run the development container**:
    Open the project in Visual Studio Code and use the Remote - Containers extension to build and run the development container. This will automatically install the dependencies and set up the environment. It will also add the connection automatically.

4. **Rename the project directory and update `pyproject.toml`**:
    Rename the `promptflow_starter_template` directory to your desired package name. Then, open the `pyproject.toml` file and update the `name`, `authors`, `description`, `version` field under `[tool.poetry]` to match your new package information.

You are now ready to start developing with the `promptflow-starter-template`.

#### Run the FastAPI endpoint

To run the FastAPI endpoint, use the following command:

```sh
uvicorn promptflow_starter_template.api:app --host 0.0.0.0 --port 5000 --workers 4
```
Note: Replace `promptflow_starter_template` with the package name from step 4.

#### Deployment steps

- **Set up PyPi and GitHub Actions**:
    To publish your package to PyPi and automate the process with GitHub Actions, follow these steps:
    Ensure you add your PyPi token to the GitHub repository secrets as `PYPI_API_TOKEN`.

You have now set up your project for publishing to PyPi and automated the process with GitHub Actions.

- **Build and push Docker images**:
    To build and push Docker images for your project, you can use the following commands:

    There are two Dockerfiles in this project: `Dockerfile` and `Dockerfile.fastapi`. The `Dockerfile` is used for python packagin, while the `Dockerfile.fastapi` is specifically for the FastAPI production ready application. Thus, only the FastAPI Docker image needs to be pushed to the GitHub Container Registry to use it later.

- **Add PYPI_API_TOKEN to .devcontainers/devcontainer.env**

- **Build the Python package**:
    ```sh
    docker build --build-arg PYPI_API_TOKEN=$PYPI_API_TOKEN -t ghcr.io/fabianschurig/promptflow-starter-template/build:latest .
    ```

- **Build the Docker image using the package from previous step**:
    ```sh
    docker build -t ghcr.io/fabianschurig/promptflow-starter-template/fastapi:latest -f Dockerfile.fastapi --build-arg PACKAGE_INSTALL_NAME=promptflow-starter-template --build-arg PACKAGE_IMPORT_NAME=promptflow_starter_template .
    ```
- **Run the docker container**:
    ```sh
    docker run -e OPENAI_API_KEY=$OPENAI_API_KEY -e OPENAI_API_BASE=$OPENAI_API_BASE -p 5000:5000 ghcr.io/fabianschurig/promptflow-starter-template/fastapi:latest
    ```

- **Push the Docker image to GitHub Container Registry**:
    ```sh
    docker push ghcr.io/fabianschurig/promptflow-starter-template/fastapi:latest
    ```

- **Use the Docker compose**
    Set environment variables to `.env` if they are not set yet in the `.devcontainer/devcontainer.env`. Those are used when doing `docker compose up`:
    ```sh
    HOST=0.0.0.0
    PORT=5000
    WORKERS=4
    OPENAI_API_VERSION=2024-10-01-preview
    PACKAGE_INSTALL_NAME=promptflow-starter-template
    PACKAGE_IMPORT_NAME=promptflow_starter_template
    ```
