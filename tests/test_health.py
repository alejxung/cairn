# Checks that the health endpoint answers with success and the expected body. It calls the
# FastAPI app in-process through FastAPI's test client, so no server, port, database or
# .env file is needed to run it.

from fastapi.testclient import TestClient

from cairn.api.main import app

# One client for the whole module is enough: the endpoint holds no state between calls.
client = TestClient(app)


def test_health_returns_200():
    response = client.get("/health")

    assert response.status_code == 200


def test_health_body_is_exactly_status_ok():
    response = client.get("/health")

    assert response.json() == {"status": "ok"}
