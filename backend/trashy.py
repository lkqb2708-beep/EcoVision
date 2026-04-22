"""
Trashy AI — Trash detection via OpenRouter vision API.
Sends a base64 image to a vision model and gets back structured JSON.
"""
import json
import httpx

# OpenRouter API configuration
OPENROUTER_API_KEY = "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"
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

# Using Gemini Flash — cheap, fast, and supports vision
MODEL = "google/gemini-2.0-flash-001"

SYSTEM_PROMPT = """You are Trashy, a trash detection AI assistant.
Your job is to analyze images and determine if they contain trash, litter, or waste.

Rules:
1. Look carefully at the image for any trash, litter, garbage, waste, or recyclable items
2. Respond ONLY with valid JSON, no other text
3. If trash is found, identify the category (e.g., "plastic bottle", "paper waste", "food wrapper", "cigarette butt", "metal can", etc.)
4. If no trash is found, set trash_category to "none"
5. Provide a confidence score between 0.0 and 1.0

Response format (ONLY this JSON, nothing else):
{"has_trash": true, "trash_category": "plastic bottle", "confidence": 0.94}

or if no trash:
{"has_trash": false, "trash_category": "none", "confidence": 0.91}"""


async def analyze_image(image_base64: str) -> dict:
    """
    Send an image to OpenRouter's vision model for trash detection.
    
    Args:
        image_base64: Base64-encoded image string
        
    Returns:
        dict with has_trash, trash_category, confidence
    """
    # Build the message with the image
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{image_base64}"
                    },
                },
                {
                    "type": "text",
                    "text": "Analyze this image. Does it contain any trash or litter? Respond with JSON only.",
                },
            ],
        },
    ]

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:8000",
        "X-Title": "Trashy Camera App",
    }

    payload = {
        "model": MODEL,
        "messages": messages,
        "max_tokens": 200,
        "temperature": 0.1,  # Low temperature for consistent JSON output
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(OPENROUTER_URL, headers=headers, json=payload)

        if response.status_code != 200:
            print(f"❌ OpenRouter API error: {response.status_code} — {response.text}")
            return {
                "has_trash": False,
                "trash_category": "error",
                "confidence": 0.0,
                "error": f"API error: {response.status_code}",
            }

        # Parse the API response
        data = response.json()
        ai_text = data["choices"][0]["message"]["content"].strip()
        
        # Clean up the response — sometimes models wrap JSON in markdown
        if ai_text.startswith("```"):
            # Remove markdown code fences
            ai_text = ai_text.strip("`").strip()
            if ai_text.startswith("json"):
                ai_text = ai_text[4:].strip()

        result = json.loads(ai_text)

        # Ensure all required fields are present
        return {
            "has_trash": bool(result.get("has_trash", False)),
            "trash_category": str(result.get("trash_category", "unknown")),
            "confidence": float(result.get("confidence", 0.0)),
        }

    except json.JSONDecodeError as e:
        print(f"❌ Failed to parse AI response as JSON: {e}")
        print(f"   Raw response: {ai_text}")
        return {
            "has_trash": False,
            "trash_category": "parse_error",
            "confidence": 0.0,
            "error": f"Could not parse AI response: {ai_text}",
        }
    except httpx.TimeoutException:
        print("❌ OpenRouter API timed out")
        return {
            "has_trash": False,
            "trash_category": "timeout",
            "confidence": 0.0,
            "error": "AI request timed out",
        }
    except Exception as e:
        print(f"❌ Trashy analysis error: {e}")
        return {
            "has_trash": False,
            "trash_category": "error",
            "confidence": 0.0,
            "error": str(e),
        }
