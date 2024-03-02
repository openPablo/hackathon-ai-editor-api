import os

from fastapi import APIRouter

from vcpilotbackend.module.chatgpt import OpenAIAPI
from vcpilotbackend.models import ItemMetadata

router = APIRouter()

open_ai_api = OpenAIAPI(
    api_key=os.environ["OPENAI_API_KEY"],
    model="gpt-3.5-turbo",
)


@router.post(
    path="/vcpilotbackend/completer",
)
async def completer(request: ItemMetadata):
    return open_ai_api.get_completed_metadata(request)
