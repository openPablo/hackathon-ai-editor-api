from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from vcpilotbackend.routers import completer, healthcheck


def create_app():
    app = FastAPI()
    app.include_router(completer.router)
    app.include_router(healthcheck.router)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    return app


app = create_app()
