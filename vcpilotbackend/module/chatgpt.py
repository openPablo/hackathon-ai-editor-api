import os
import json
from typing import Any
from openai import OpenAI

from vcpilotbackend.models import (
    ItemMetadata,
    ItemMetadataCompleted,
    CompletedItemMetadataValue,
    ValueStatus,
)


class OpenAIAPI:
    def __init__(self, api_key: str, model: str):
        self._client = OpenAI(api_key=api_key)
        self._model = model

    def get_completed_metadata_prompt(self, provided: ItemMetadata):
        provided_dict = provided.model_dump(mode="json")
        prompt = ["Of the following movie, we have the following details:"]
        for k, v in provided_dict.items():
            if not v:
                continue
            prompt.append(f"- {k}: {v}")
        prompt.append(
            "Please guess a fitting value for the following metadata, for one real movie that matches the values provided above as close as possible."
        )
        for field_name, field in ItemMetadata.__fields__.items():
            prompt.append(f"- {field_name}: {field.description}")
        prompt.append(
            "Format your response as JSON. Do not add any other information beside the JSON output itself. Do not wrap the output in a markdown code block."
        )
        prompt_str = "\n".join(prompt)
        return prompt_str

    def get_completed_metadata(self, provided: ItemMetadata):
        provided_dict = provided.model_dump(mode="json")
        prompt = self.get_completed_metadata_prompt(provided)
        print(prompt)
        response = self._client.chat.completions.create(
            model=self._model,
            messages=[
                {"role": "system", "content": "You are a movie journalist."},
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
            temperature=0,
        )

        response_pick = response.choices[0].message.content or "{}"
        response_pick = response_pick.strip()

        if response_pick.startswith(r"```"):
            response_pick = "\n".join(response_pick.split("\n")[1:-1])

        try:
            response_dict = json.loads(response_pick)
            return ItemMetadataCompleted(
                **{
                    k: self.get_completed_item_metadata_value(provided_dict[k], v)
                    for k, v in response_dict.items()
                }
            )
        except:
            print(response_pick)
            raise

    def get_completed_item_metadata_value(
        self, provided_value: Any, inferred_value: Any
    ):
        if not provided_value:
            source = ValueStatus.COMPLETED
        elif provided_value == inferred_value:
            source = ValueStatus.UNCHANGED
        else:
            source = ValueStatus.UPDATED
        return CompletedItemMetadataValue(
            value=inferred_value,
            original_value=provided_value,
            status=source,
        )
