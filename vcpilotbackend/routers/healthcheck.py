from fastapi import APIRouter

router = APIRouter()


@router.get(
    path="/",
)
async def healthcheck():
    return True
