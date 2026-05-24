"""
Trashy AI — Trash detection via Google Gemini Vision API.
Sends a base64 image to Gemini and gets back structured JSON.
"""
import json
import base64
import os
import re
import httpx

# ── API Key ────────────────────────────────────────────────────
# Set OPENROUTER_API_KEY as an environment variable, or paste it below.
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "YOUR_OPENROUTER_API_KEY_HERE")

# Using Gemini 2.0 Flash via OpenRouter — fast, cheap, and supports vision
MODEL_NAME = "google/gemini-2.0-flash-001"

SYSTEM_PROMPT = """You are Trashy, an AI assistant that helps people classify household waste following Ho Chi Minh City's 2025-2026 waste-sorting regulations.

CRITICAL: Be extremely observant. If you see ANY object that is typically discarded as waste—even a single piece of litter, a bottle, a wrapper, or food remains—you MUST set "has_trash": true. Only set "has_trash": false if the image shows a clean environment with no visible waste at all.

Your task has TWO steps:

STEP 1 — TRASH DETECTION:
Identify if any waste, trash, or discarded items are present. Set "has_trash": true if anything is found.

STEP 2 — WASTE CLASSIFICATION (only if trash is detected):
Classify the trash into one of the four official HCMC waste groups:

1. "tai_che" (Rác tái chế — Recyclable waste)
   Examples: old paper, plastic bottles, metal cans, glass bottles, cardboard boxes, scrap metal.
   Note: Collect separately to sell or give to waste collectors (ve chai).

2. "huu_co" (Rác hữu cơ — Organic / food waste)
   Examples: leftover vegetables, spoiled rice, tea grounds, fruit peels, garden waste.
   Note: Typically collected in GREEN bins.

3. "vo_co" (Rác vô cơ — Non-recyclable / residual waste)
   Examples: dirty plastic bags, styrofoam, milk cartons, diapers, sanitary pads, broken ceramics.
   Note: Typically collected in ORANGE bins.

4. "nguy_hai" (Rác nguy hại — Hazardous waste)
   Examples: batteries, light bulbs, pesticide bottles, chemical containers.
   Note: Must be kept SEPARATE — never mix with household waste.

Rules:
- Respond ONLY with valid JSON, no other text.
- If no trash is detected, set "has_trash" to false and all other classification fields accordingly.
- "trash_type" must be one of: "tai_che", "huu_co", "vo_co", "nguy_hai", or "none".
- "trash_category" is a short human-readable label for the specific item seen (e.g., "chai nhựa", "vỏ trái cây", "pin").
- "confidence" is a float between 0.0 and 1.0.
- "bin_color" is the recommended bin color: "any" (tai_che), "xanh" (huu_co), "cam" (vo_co), "rieng biet" (nguy_hai), or "none".
- "instruction" is a short Vietnamese-language disposal tip for the user.

Response format (ONLY this JSON, nothing else):
{
  "has_trash": true,
  "trash_type": "tai_che",
  "trash_category": "chai nhựa",
  "confidence": 0.95,
  "bin_color": "any",
  "instruction": "Chai nhựa là rác tái chế. Hãy thu gom riêng để bán hoặc cho ve chai."
}

or if no trash:
{
  "has_trash": false,
  "trash_type": "none",
  "trash_category": "none",
  "confidence": 0.92,
  "bin_color": "none",
  "instruction": "Không phát hiện rác trong hình ảnh này."
}"""


async def analyze_image(image_base64: str) -> dict:
    """
    Send an image to OpenRouter for trash detection.

    Args:
        image_base64: Base64-encoded image string

    Returns:
        dict with has_trash, trash_type, trash_category, confidence, bin_color, instruction
    """
    ai_text = ""
    try:
        payload = {
            "model": MODEL_NAME,
            "messages": [
                {
                    "role": "system",
                    "content": SYSTEM_PROMPT
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Analyze this image. Identify any waste or trash. Classify it according to HCMC 2025-2026 waste-sorting regulations. Respond with JSON only."
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_base64}"
                            }
                        }
                    ]
                }
            ],
            "response_format": {"type": "json_object"}
        }

        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "EcoVision Trashy",
            "Content-Type": "application/json"
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers=headers,
                json=payload
            )
            
            response.raise_for_status()
            data = response.json()
            
            if "choices" in data and len(data["choices"]) > 0:
                ai_text = data["choices"][0]["message"]["content"].strip()
            else:
                raise Exception(f"Unexpected response from OpenRouter: {data}")
        print(f"RAW AI RESPONSE: {ai_text}")

        # Clean up markdown fences if present
        ai_text = re.sub(r"^```(?:json)?\s*", "", ai_text, flags=re.IGNORECASE)
        ai_text = re.sub(r"\s*```$", "", ai_text)
        ai_text = ai_text.strip()

        result = json.loads(ai_text)

        return {
            "has_trash":      bool(result.get("has_trash", False)),
            "trash_type":     str(result.get("trash_type", "none")),
            "trash_category": str(result.get("trash_category", "unknown")),
            "confidence":     float(result.get("confidence", 0.0)),
            "bin_color":      str(result.get("bin_color", "none")),
            "instruction":    str(result.get("instruction", "")),
        }

    except json.JSONDecodeError as e:
        print(f"Failed to parse AI response as JSON: {e}")
        print(f"   Raw response: {ai_text}")
        return {
            "has_trash":      False,
            "trash_type":     "none",
            "trash_category": "parse_error",
            "confidence":     0.0,
            "bin_color":      "none",
            "instruction":    "",
            "error":          f"Could not parse AI response: {ai_text}",
        }
    except Exception as e:
        print(f"OpenRouter analysis error: {e}")
        return {
            "has_trash":      False,
            "trash_type":     "none",
            "trash_category": "error",
            "confidence":     0.0,
            "bin_color":      "none",
            "instruction":    "",
            "error":          str(e),
        }
