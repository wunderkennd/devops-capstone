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