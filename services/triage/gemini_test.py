from google import genai

# vertexai=True → use Vertex AI with your ADC login (no API key)
client = genai.Client(
    vertexai=True,
    project="anuj-triage-ai",
    location="global",
)

error = "Payment service timeout: could not reach database after 3 retries"

response = client.models.generate_content(
    model="gemini-3.5-flash-lite",
    contents=f"You are an SRE. In 2 sentences, what is the likely root cause of this error?\n\n{error}",
)

print(response.text)