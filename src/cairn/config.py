# Loads every runtime setting the Python code needs (database URLs, tracker URI) from
# environment variables, so no other module reads os.environ directly. Local development
# reads them from .env; deployments set real environment variables. Only values that
# Python itself uses belong here: the Postgres superuser and role passwords are read by
# Docker Compose and the database init script, not by this code.

from functools import lru_cache
from pathlib import Path

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

ENV_FILE = Path(__file__).resolve().parents[2] / ".env"


class Settings(BaseSettings):
    """Runtime settings. A missing variable stops startup with a validation error.

    Database URLs are SecretStr because they embed passwords; call
    .get_secret_value() only where the connection is actually created.
    """

    model_config = SettingsConfigDict(env_file=ENV_FILE, extra="ignore")

    app_database_url: SecretStr
    agent_database_url: SecretStr
    mlflow_tracking_uri: str


@lru_cache
def get_settings() -> Settings:
    """Return the settings, reading the environment and .env only once.

    Other modules call this instead of building Settings themselves, so tests can
    clear the cache or override the dependency.
    """
    return Settings()
