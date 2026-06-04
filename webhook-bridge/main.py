"""
Webhook Bridge for Hermes MEP Drawing Review
Receives drawing URLs from Make.com, downloads them, and prepares for review.
"""
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, HttpUrl
import requests
import os
from pathlib import Path
import uuid

app = FastAPI(title="Hermes MEP Webhook Bridge")

WORKSPACE = Path(os.environ.get("WORKSPACE", "/workspace"))
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*")

class DrawingPayload(BaseModel):
    dropbox_url: HttpUrl
    project_name: str = ""
    reviewer: str = ""
    notes: str = ""

@app.get("/health")
def health():
    return {"status": "ok", "workspace": str(WORKSPACE)}

@app.post("/review")
async def review_drawing(payload: DrawingPayload, request: Request):
    """Receive drawing URL from Make.com, download to workspace."""
    try:
        # Generate unique filename
        ext = Path(str(payload.dropbox_url)).suffix or ".pdf"
        filename = f"{uuid.uuid4().hex[:8]}_{payload.project_name}{ext}"
        filepath = WORKSPACE / filename

        # Download from Dropbox (follow redirects)
        headers = {"User-Agent": "Hermes-MEP-Webhook/1.0"}
        r = requests.get(str(payload.dropbox_url), headers=headers, timeout=60, allow_redirects=True)
        r.raise_for_status()

        # Save to workspace
        filepath.write_bytes(r.content)

        return {
            "status": "downloaded",
            "filename": filename,
            "size_bytes": len(r.content),
            "workspace_path": str(filepath),
            "project": payload.project_name,
            "notes": payload.notes
        }

    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Download failed: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {e}")
