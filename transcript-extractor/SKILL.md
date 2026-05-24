---
name: transcript-extractor
description: Extracts key concepts from timestamped transcripts, validates and corrects mathematical/logical content, and embeds context-relevant media and links. Enforces rigorous formatting and zero-fluff constraints.
version: 1.1
trigger: /transcript-extractor
---

# Transcript Extractor Skill

## Goal
Process a timestamped transcript (which may contain embedded images, links, or references) into a highly structured, accurate, and concise markdown document. Extract only substantive content, critically verify its correctness, place media contextually, and rigorously adhere to mathematical and structural formatting rules.

## Input
A transcript (with timestamps) often containing scattered links, references, or embedded images (`![image](...)`).

## Workflow

### Phase A — Cache & Clear (前置：先記後刪)

1. **Cache Target Range**: Identify the user-specified line range (e.g., `L10–L20`) and read its full content into working memory. If no range is specified, scan the entire document and cache every contiguous region containing raw transcript indicators (bare timestamps such as `29:17`, lone `**` markers, spoken-language filler). The cached content becomes the **sole source of truth** for all downstream steps. (先讀取並記住用戶指定範圍的全部內容；若無指定則自動定位全文中含時間戳或口語殘留的區段並一併快取。此快取為後續萃取與重建的唯一來源。)
2. **Delete Original Range**: After caching, remove the entire cached region from the document so the target lines are empty. Deletion precedes reconstruction; this guarantees zero residue regardless of how the rewrite proceeds. (快取完成後立即刪除原範圍，確保不會殘留任何時間戳或口語片段。)

### Phase B — Reconstruct from Cache (從記憶重建)

3. **Extract Substantive Units**: From the cached content, isolate key concepts, definitions, derivations, and equations. Discard timestamps, filler speech, and redundant scaffolding.
4. **Verify & Correct**: Validate all equations, definitions, and logical steps before reformatting. Correct any transcription errors, ASR mishearings, or factual mistakes in-place.
5. **Explicit Assumptions**: Whenever standard mathematical or physical results are invoked, explicitly state the underlying assumptions (e.g., i.i.d., WSSUS, narrowband).
6. **Contextualize Media & References**: Place all images, links, and references immediately adjacent to the key points they support. Do not consolidate them into a bibliography or reference section at the bottom.
7. **Write & Format**: Insert the organized output into the now-empty range. Apply the formatting rules below. End the response immediately after the final unit.

### Phase C — Boundary Sweep (邊界檢查)

8. **Boundary Verification**: After writing, re-scan the ±20-line boundary around the inserted region. If any bare timestamp, lone `**` marker, or spoken-language fragment survives outside the originally cached range (e.g., the user-specified range was off by a few lines), cache it, delete it, and fold its substantive content into the rewritten section. No raw transcript data may remain. (寫入後檢查前後 20 行；若發現遺漏的時間戳或口語殘留，重複 Phase A→B 將其納入整合。)

## Formatting
- **Math Delimiters**: Inline math must use `$...$`. Block math must use `$$...$$` on its own line. **Never** use `\(...\)` or `\[...\]`.
- **Variable Wrapping**: Wrap *every* mathematical variable, operator, and symbol in math delimiters.
- **Standard Notation**:
  - Vectors: bold lowercase (e.g., $\mathbf{x}$)
  - Matrices: bold uppercase (e.g., $\mathbf{A}$)
  - Estimates: hat (e.g., $\hat{x}$)
  - Sets: calligraphic (e.g., $\mathcal{X}$)
- **Headings**: Use only `#`, `##`, or `###` for hierarchy.
- **Code Blocks**: Code must be fenced with the appropriate language tag.

## Content Rules
- Validate equations, definitions, and logic before reformatting; correct errors in place.
- State assumptions when invoking standard results (e.g., WSSUS, narrowband, i.i.d.).
- Do not summarize conclusions derivable from the presented content; state the facts directly.

## Prohibitions (STRICT)
- NO emojis, greetings, filler, rhetorical questions, motivational language, or call-to-action closings.
- NO tone-matching, emotional soothing, experience-oriented phrasing, or satisfaction/evaluation language.
- NO optional branches ("you could also…", "alternatively…").
- NO questions to the user, except when two plausible interpretations would yield contradictory outputs.

## Language
- The output language must strictly match the input language.

## Termination
- End immediately after the last unit of information. Do not append any closing remarks.