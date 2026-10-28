# Cairn

Trackers record what happened. Cairn records why.

Cairn is a multi-agent assistant for research labs. It reads experiment runs from the
lab's existing tracker (MLflow or Weights & Biases), links them to the decisions the lab
made and the reasons behind them, and answers questions like "why did we change the
normalization step?" with references to the notes and runs involved.

## Status
Early development. The local foundation works: PostgreSQL with pgvector and a local MLflow
server start with Docker Compose, the database has separate owner, app and read-only agent
roles, and the API serves a health endpoint. The features below are not built yet.

## Getting started
Requires Docker and [uv](https://docs.astral.sh/uv/).

1. Copy `.env.example` to `.env` and replace every placeholder with your own values.
   Use passwords without the characters `@ / : #`, because they appear inside the
   database URLs. Make sure no password variable is already exported in your shell, since
   Docker Compose prefers shell variables over `.env`.
2. Install the Python environment: `uv sync`
3. Start the services: `docker compose up -d`
4. Run the tests: `uv run pytest`
5. Start the API: `uv run uvicorn cairn.api.main:app --reload`, then open
   `http://127.0.0.1:8000/health`.

The database init script only runs when the data volume is empty. After changing role
passwords in `.env`, reset it with `docker compose down -v` (this deletes the local
database contents).

## Planned features
- Decision records linked to experiment runs
- Searchable shared lab notes
- Early warnings for training runs likely to fail
- Plain-language weekly summaries

## Tech
Python, FastAPI, PostgreSQL + pgvector, LangGraph, MLflow