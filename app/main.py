import typesystem
import uvicorn
from entity_models import *
from loguru import logger
from pydantic import BaseModel
from typing import Dict, List, Sequence, Tuple
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
from starlette.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException


from sqlalchemy import Column, Integer, String
from pydantic import BaseModel
class SimilarityRequest(BaseModel):
    style: str
    color: str = None


class SimilarityResponse(BaseModel):
    style: str
    color: str = None


class RecommendationRequest(BaseModel):
    """
    Request for a recommendation for a given customer given the context of the recommendation
    """

    channel: str
    sub_channel: str
    customer_id: str
    msg: str


class RecommendedSKU(BaseModel):
    """
    Response format for a single SKU
    """

    style: str
    color: str = None
    distance: List[float]
    sku_rank: int
    style_rank: int = None
    color_rank: int = None
    image_url: str = None


class ProductUrl(BaseModel):
    url: str

app = FastAPI(
    
)

@app.get("/")
async def root():
    html = f"<h3>Atlas Endpoint</h3>"
    return html

async def _get_image(image_url: str):
    if 's3' in image_url:
        # TODO: Download from S3
        logger.info('downloading image from s3')
    else:
        # TODO: Load image
        logger.info('downloading image from elsewhere')
    return Notimplemented

async def _extract_features(product_url: ProductUrl):
    """

    :param selected_product:
    :return:
    """

    return


async def _similarity_search(product_url: ProductUrl):
    """

    :param product_url:
    :return:
    """

    return


class UnicornException(Exception):
    def __init__(self, name: str):
        self.name = name


@app.exception_handler(UnicornException)
async def unicorn_exception_handler(request: Request, exc: UnicornException):
    return JSONResponse(
        status_code=418,
        content={"message": f"Oops! {exc.name} did something. There goes a rainbow..."},
    )


@app.put("{channel}/{sku}", status_code=HTTP_201_CREATED)
async def add_sku(channel: str, sku: str, q: str):
    """
    """
    if q == "create":
        return f"added sku {sku} to {channel}"
    else:
        raise UnicornException(name="Not Implemented")


@app.post(
    "{channel}/{sub_channel}/{customer_id}",
    response_model=RecommendedSKU,
    response_model_skip_defaults=True,
    status_code=200,
)
async def recommendation_handler(
    channel: str, sub_channel: str, customer_id: str, msg: str
):
    """


    """

    if customer_id == -1:
        raise HTTPException(status_code=404, detail="not a valid customer_id")
    elif customer_id == 0:
        raise HTTPException(status_code=404, detail="customer_id does not exist")
    else:
        return {channel, sub_channel, customer_id, msg}


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Product(typesystem.Schema):
    product_id = typesystem.String(max_length=255)
    upc = typesystem.String(max_length=255)
    romance_copy = typesystem.String(trim=True)

class Customer(typesystem.Schema):
    customer_id = typesystem.String(max_length=255)


@app.get("/")
async def read_root():
    return {"Hello": "World"}



if __name__ == '__main__':
    uvicorn.run(app)