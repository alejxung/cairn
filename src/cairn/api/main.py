# Creates the FastAPI application and exposes a health endpoint, so a person, a test or a
# deployment platform can ask "is the service up?" without touching any lab data. Other
# routes will be added to this app as the backend grows.

from fastapi import FastAPI
from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str


app = FastAPI(title="Cairn", version="0.1.0")


@app.get("/health")
def health() -> HealthResponse:
    """Report that the process is running. Public, cheap, and touches no data."""
    return HealthResponse(status="ok")
