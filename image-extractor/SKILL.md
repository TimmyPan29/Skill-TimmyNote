---
name: image-extractor
description: Extracts text, data, and key information from any image type — screenshots, handwritten notes, scanned documents, photographs, diagrams, charts — then fact-checks claims via web search and verifies mathematical/logical content via internal theory verification, correcting errors in place.
trigger: /image-extractor
version: 2.1.0
---

# Image Extractor

Extracts text, structured data, and key information from any image type, then critically verifies its correctness before output.

## Input Types Supported

- **Screenshots** — UI text, code, dialogs, applications
- **Handwritten notes** — handwriting recognition with context preservation
- **Scanned documents** — PDFs, document photos, receipts
- **Photographs** — text in photos, labels, signage
- **Diagrams & charts** — visual structure, text labels, data relationships
- **General images** — any content with readable text or extractable information

## Workflow

### Phase A — Extract
1. Identify source type and read all content. Mark unclear or uncertain text with `[?]` and indicate handwriting/OCR confidence.
2. Disambiguate OCR-prone symbols using context (e.g., `0`/`O`, `l`/`1`/`I`, `rn`/`m`, `−`/`-`, `×`/`x`, sub/superscripts, math operators).

### Phase B — Verify & Correct (事實查核 + 理論檢驗)
3. **Theory verification (內部檢驗)**: Validate all equations, definitions, derivations, and logical steps using your own reasoning. Recompute derivations; check dimensional consistency, units, and edge cases. Correct any transcription, OCR, or factual error **in place**.
4. **Fact-check via web search (網路搜尋查核)**: For factual claims, named results, dates, statistics, citations, formulas, or anything not verifiable by pure reasoning, perform a web search to confirm. If a source contradicts the extracted content, correct it in place and note the correction inline as `[corrected: <reason>]`.
5. **Explicit assumptions**: When invoking standard mathematical or physical results, state the underlying assumptions explicitly (e.g., i.i.d., linearity, narrowband).
6. **Uncertainty marking**: If a claim cannot be verified by either reasoning or search, keep it but flag it as `[unverified]` rather than silently asserting it.

### Phase C — Output
7. Format the verified content per the rules below.

## Output Format

### Text Extraction
- Preserves original formatting (line breaks, spacing)
- Unclear text marked `[?]`; corrections marked `[corrected: …]`; unverifiable claims marked `[unverified]`

### Structured Data
- Tables → markdown format
- Forms → key-value pairs
- Lists → hierarchical markdown
- Diagrams → ASCII representation or description

### Metadata
- Source type (screenshot, handwriting, photo, etc.)
- Extraction confidence (high/medium/low)
- Verification summary: which claims were checked, by reasoning vs. web search, and what was corrected

## Formatting
- Inline math uses `$...$`; block math uses `$$...$$` on its own line. Never use `\(...\)` or `\[...\]`.
- Wrap every mathematical variable, operator, and symbol in math delimiters.
- Vectors bold lowercase ($\mathbf{x}$), matrices bold uppercase ($\mathbf{A}$), estimates with hat ($\hat{x}$), sets calligraphic ($\mathcal{X}$).
- Headings use only `#`, `##`, `###`. Code fenced with a language tag.

## Content Rules
- Always verify before formatting; never output an unverified factual or mathematical claim without a `[unverified]` flag.
- Prefer web search for external facts; prefer internal reasoning for math/logic; use both when they overlap.
- Output language must match the dominant language of the source image.

## Usage

```
/image-extractor
```

Provide the image, then specify what to extract and the preferred output format. Verification (theory + web fact-check) runs by default; say "skip verification" to disable it.
