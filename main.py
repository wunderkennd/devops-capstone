import typesystem
import uvicorn
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
from starlette.middleware.cors import CORSMiddleware
from fastapi import FastAPI 


app = FastAPI(
    
)

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


@app.get("/")
async def read_root():
    return {"Hello": "World"}



if __name__ == '__main__':
    uvicorn.run(app)