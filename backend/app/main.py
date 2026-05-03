from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router, shutdown_services
from app.core.config import settings


@asynccontextmanager
async def lifespan(_: FastAPI):
    try:
        yield
    finally:
        shutdown_services()


app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend service for NeuroSign sign recognition, text-to-sign conversion, and diagnostics.",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow cross-origin requests for Flutter Mobile/Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register endpoints
app.include_router(router, prefix=settings.API_V1_STR)

@app.get("/")
def read_root():
    return {"status": "ok", "message": "NeuroSign API is running."}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
