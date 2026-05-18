---
name: transcript-extractor
description: Extracts key concepts from timestamped transcripts, validates and corrects mathematical/logical content, and embeds context-relevant media and links. Enforces rigorous formatting and zero-fluff constraints.
version: 1.0
trigger: /transcript-extractor
---

# Transcript Extractor Skill

## Goal
Process a timestamped transcript (which may contain embedded images, links, or references) into a highly structured, accurate, and concise markdown document. Extract only substantive content, critically verify its correctness, place media contextually, and rigorously adhere to mathematical and structural formatting rules.

## Input
A transcript (with timestamps) often containing scattered links, references, or embedded images (`![image](...)`).

## Workflow
1. **Extract Substantive Units**: Parse the transcript to isolate key concepts, definitions, derivations, and equations. Discard timestamps, filler speech, and redundant scaffolding.
2. **Verify & Correct**: Validate all equations, definitions, and logical steps before reformatting. Correct any transcription errors, ASR mishearings, or factual mistakes in-place.
3. **Explicit Assumptions**: Whenever standard mathematical or physical results are invoked, explicitly state the underlying assumptions (e.g., i.i.d., WSSUS, narrowband).
4. **Contextualize Media & References**: Move all images, links, and references so they sit immediately adjacent to the highly relevant key points they support. Do not consolidate them into a bibliography or reference section at the bottom.
5. **Format & Terminate**: Apply the rigid formatting rules below. End the response immediately after the final unit.

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
