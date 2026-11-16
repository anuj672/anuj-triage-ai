import base64
import json

from fastapi import FastAPI, Request

from diagnose import diagnose

app = FastAPI()


@app.post("/")
async def receive(request: Request):
    body = await request.json()

    # Pub/Sub sends the log entry base64-encoded inside message.data
    log_entry = json.loads(base64.b64decode(body["message"]["data"]))
    error = log_entry.get("textPayload", "")

    result = diagnose(error)
    print(result.model_dump_json())

    return {"ok": True}   # 200 = "got it", Pub/Sub won't resend