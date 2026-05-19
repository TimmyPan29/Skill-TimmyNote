---
name: image-extractor
description: Extracts text, data, and key information from any image type — screenshots, handwritten notes, scanned documents, photographs, diagrams, charts — with OCR and content structuring
trigger: /image-extractor
---

# Image Extractor

Extracts text, structured data, and key information from any image type with flexible input handling and intelligent formatting.

## Input Types Supported

- **Screenshots** — UI text, code, dialogs, applications
- **Handwritten notes** — handwriting recognition with context preservation
- **Scanned documents** — PDFs, document photos, receipts
- **Photographs** — text in photos, labels, signage
- **Diagrams & charts** — visual structure, text labels, data relationships
- **General images** — any content with readable text or extractable information

## Output Format

### Text Extraction
- Preserves original formatting (line breaks, spacing)
- Marks unclear or uncertain text with `[?]`
- Indicates handwriting confidence levels

### Structured Data
- Tables → markdown format
- Forms → key-value pairs
- Lists → hierarchical markdown
- Diagrams → ASCII representation or description

### Metadata
- Source type (screenshot, handwriting, photo, etc.)
- Extraction confidence (high/medium/low)
- Recommended next steps (cleanup, validation, formatting)

## Usage

```
/image-extractor
```

Provide the image file or screenshot, then specify:
- What you want extracted (all content, specific sections, data only)
- Preferred output format
- Any special handling needs (e.g., preserve handwriting style, extract structured data)

## Features

- **Flexible input** — accepts any image format or quality
- **Context-aware extraction** — understands document type and adjusts approach
- **OCR + manual parsing** — combines automated and human-informed techniques
- **Format options** — plain text, markdown, JSON, CSV, or custom
- **Quality indicators** — confidence levels and uncertain sections marked clearly
