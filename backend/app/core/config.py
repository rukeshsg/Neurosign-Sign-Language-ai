from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


BACKEND_DIR = Path(__file__).resolve().parents[2]
PROJECT_DIR = BACKEND_DIR.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(BACKEND_DIR / ".env"),
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "NeuroSign API"

    CONFIDENCE_THRESHOLD: float = 0.70
    DYNAMIC_CONFIDENCE_THRESHOLD: float = 0.80
    SMOOTHING_WINDOW_SIZE: int = 10
    WLASL_SEQUENCE_LENGTH: int = 8

    ASL_MODEL_PATH: Path = Field(default=Path("models/asl_static.joblib"))
    WLASL_MODEL_PATH: Path = Field(default=Path("models/wlasl_dynamic.joblib"))
    ASL_DATASET_PATH: Path = Field(
        default=Path("datasets/ASL_Alphabet_dataset/asl_alphabet_train/asl_alphabet_train")
    )
    ASL_TEST_DATASET_PATH: Path = Field(
        default=Path("datasets/ASL_Alphabet_dataset/asl_alphabet_test/asl_alphabet_test")
    )
    WLASL_DATASET_PATH: Path = Field(default=Path("datasets/WLASL_dataset/SL"))

    @field_validator(
        "ASL_MODEL_PATH",
        "WLASL_MODEL_PATH",
        "ASL_DATASET_PATH",
        "ASL_TEST_DATASET_PATH",
        "WLASL_DATASET_PATH",
        mode="before",
    )
    @classmethod
    def _coerce_to_path(cls, value: Path | str) -> Path:
        return Path(value)

    @field_validator(
        "ASL_MODEL_PATH",
        "WLASL_MODEL_PATH",
        "ASL_DATASET_PATH",
        "ASL_TEST_DATASET_PATH",
        "WLASL_DATASET_PATH",
    )
    @classmethod
    def _resolve_relative_path(cls, value: Path, info) -> Path:
        if value.is_absolute():
            return value

        if info.field_name.endswith("MODEL_PATH"):
            return (BACKEND_DIR / value).resolve()

        return (PROJECT_DIR / value).resolve()


settings = Settings()
