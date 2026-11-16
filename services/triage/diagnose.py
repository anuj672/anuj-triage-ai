from typing import Literal
from pydantic import BaseModel, Field
from google import genai
from google.genai import types


# 1. The shape we want back: a contract between our code and the model
class Diagnosis(BaseModel):
    summary: str = Field(description="One-line summary of the incident")
    root_cause: str = Field(description="Most likely root cause")
    severity: Literal["P1", "P2", "P3", "P4"] = Field(description="P1 = outage, P4 = minor")
    suggested_fix: str = Field(description="Concrete next step for the on-call engineer")
    confidence: float = Field(description="0.0 to 1.0, how sure you are")


client = genai.Client(vertexai=True, project="anuj-triage-ai", location="global")

SYSTEM_PROMPT = (
    "You are a senior SRE triaging production errors from Google Cloud Run. "
    "Be specific and practical. If the log is ambiguous, say so and lower your confidence."
)


def diagnose(error_text: str) -> Diagnosis:
    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=f"Triage this error log:\n\n{error_text}",
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_PROMPT,     # the model's "job description"
            response_mime_type="application/json",
            response_schema=Diagnosis,            # 2. force this exact shape
            temperature=0.2,                      # 3. low = consistent, less creative
            max_output_tokens=1024,               # 4. cost guardrail
        ),
    )
    return response.parsed                        # already a Diagnosis object


if __name__ == "__main__":
    result = diagnose("Payment service timeout: could not reach database after 3 retries")
    print(result.model_dump_json(indent=2))