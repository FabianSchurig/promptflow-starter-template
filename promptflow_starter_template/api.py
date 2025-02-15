from fastapi.responses import JSONResponse
from promptflow.core._serving.app import create_app
from fastapi import Request
from fastapi.security import HTTPBearer
from dotenv import load_dotenv, find_dotenv
from fastapi.middleware.cors import CORSMiddleware
import os
import jwt
from fastapi import Depends, HTTPException, status

load_dotenv(find_dotenv())

security = HTTPBearer()

flow_file_path = os.path.dirname(__file__)
app = create_app(engine="fastapi", flow_file_path=flow_file_path)


def verify_jwt(token: str = Depends(security)):
    try:
        payload = jwt.decode(token.credentials,
                             os.getenv("JWT_SECRET"),
                             algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )


if os.getenv("JWT_VERIFICATION_ENABLED", "false").lower() == "true":

    @app.middleware("http")
    async def jwt_middleware(request: Request, call_next):
        token = request.headers.get("Authorization")
        if token:
            verify_jwt(token)
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authorization header missing",
            )
        response = await call_next(request)
        return response


if os.getenv("ENVIRONMENT", "PRODUCTION").lower() == "development":
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["http://localhost", "http://127.0.0.1"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
