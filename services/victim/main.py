import json
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def ok():
    return {"status": "healthy"}

@app.get("/fail")
def fail():
    print(json.dumps({
        "severity": "ERROR",
        "message": "Payment service timeout: could not reach database after 3 retries",
    }))
    return {"status": "error logged"}