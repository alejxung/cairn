# Cairn

Trackers record what happened. Cairn records why.

Cairn is a multi-agent assistant for research labs. It reads experiment runs from the
lab's existing tracker (MLflow or Weights & Biases), links them to the decisions the lab
made and the reasons behind them, and answers questions like "why did we change the
normalization step?" with references to the notes and runs involved.

## Status
Early development.

## Planned features
- Decision records linked to experiment runs
- Searchable shared lab notes
- Early warnings for training runs likely to fail
- Plain-language weekly summaries

## Tech
Python, FastAPI, PostgreSQL + pgvector, LangGraph, MLflow