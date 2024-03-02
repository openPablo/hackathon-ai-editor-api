from typing import Any
from enum import Enum
from pydantic import BaseModel, Field


class ItemMetadata(BaseModel):
    title: str | None = Field(description="Title of the movie", default=None)
    genre: list[str] | None = Field(
        description="Between 1 and 3 genres that best fit the movie", default=None
    )
    year: int | None = Field(description="Production year of the movie", default=None)
    director: str | None = Field(description="Director of the movie", default=None)
    starring: list[str] | None = Field(
        description="Main actors starring in the movie", default=None
    )
    synopsis: str | None = Field(
        description="A long synopsis of one paragraph in English", default=None
    )
    synopsis_short: str | None = Field(
        description="A short synopsis of one sentence in English", default=None
    )
    synopsis_nl: str | None = Field(
        description="A long synopsis of one paragraph in Dutch", default=None
    )
    synopsis_ghetto: str | None = Field(
        description="A long synopsis of one paragraph in English, using very crass AAVE street language in the voice of Ali G",
        default=None,
    )


class ValueStatus(Enum):
    UNCHANGED = "unchanged"
    COMPLETED = "completed"
    UPDATED = "updated"


class CompletedItemMetadataValue(BaseModel):
    value: Any
    original_value: Any
    status: ValueStatus


class ItemMetadataCompleted(BaseModel):
    title: CompletedItemMetadataValue
    genre: CompletedItemMetadataValue
    year: CompletedItemMetadataValue
    director: CompletedItemMetadataValue
    starring: CompletedItemMetadataValue
    synopsis: CompletedItemMetadataValue
    synopsis_short: CompletedItemMetadataValue
    synopsis_nl: CompletedItemMetadataValue
    synopsis_ghetto: CompletedItemMetadataValue
