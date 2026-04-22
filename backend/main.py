"""
Trashy Backend — FastAPI server that receives images from the Flutter app,
stores them in PostgreSQL, and calls Trashy AI for trash detection.

Run with:
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from database import init_db, save_scan, get_all_scans
from trashy import analyze_image

app = FastAPI(title="Trashy API", version="1.0.0")


# ── Request / Response models ────────────────────────────────
class AnalyzeRequest(BaseModel):
    image_base64: str


class AnalyzeResponse(BaseModel):
    id: int
    has_trash: bool
    trash_category: str
    confidence: float


# ── Startup event ────────────────────────────────────────────
@app.on_event("startup")
def on_startup():
    """Initialize database table on server start."""
    print("🚀 Starting Trashy backend...")
    init_db()
    print("🚀 Trashy backend is ready!")


# ── Endpoints ────────────────────────────────────────────────
@app.get("/health")
def health_check():
    """Simple health check to verify the server is running."""
    return {"status": "ok"}


@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze(request: AnalyzeRequest):
    """
    Receive a base64 image, analyze it with Trashy AI,
    save the result to PostgreSQL, and return the result.
    """
    if not request.image_base64:
        raise HTTPException(status_code=400, detail="No image data provided")

    # Limit image size (roughly 10MB in base64)
    if len(request.image_base64) > 15_000_000:
        raise HTTPException(status_code=400, detail="Image too large (max ~10MB)")

    print(f"📸 Received image ({len(request.image_base64)} chars of base64)")

    # Step 1: Call Trashy AI to analyze the image
    print("🤖 Sending to Trashy AI for analysis...")
    result = await analyze_image(request.image_base64)

    has_trash = result["has_trash"]
    trash_category = result["trash_category"]
    confidence = result["confidence"]

    print(f"🤖 Trashy says: has_trash={has_trash}, category={trash_category}, confidence={confidence}")

    # Step 2: Save to PostgreSQL
    try:
        scan_id = save_scan(
            image_base64=request.image_base64,
            has_trash=has_trash,
            trash_category=trash_category,
            confidence=confidence,
        )
    except Exception as e:
        print(f"❌ Database error: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    # Step 3: Return result to Flutter app
    return AnalyzeResponse(
        id=scan_id,
        has_trash=has_trash,
        trash_category=trash_category,
        confidence=confidence,
    )


@app.get("/scans")
def list_scans():
    """List all past scan results (useful for debugging in browser)."""
    try:
        scans = get_all_scans()
        return {"scans": [dict(s) for s in scans]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
