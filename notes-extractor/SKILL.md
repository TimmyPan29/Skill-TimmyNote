---
name: notes-extractor
description: Extract substantive content (definitions, equations, derivations, examples) from a transcript or text source, verify correctness, preserve embedded images, and emit clean intermediate Markdown ready for the data-organizer skill. Trigger whenever the user provides a transcript (text/SRT/paste) or lecture/talk material and asks to extract/clean/digitize/process/convert it — including loose phrasings like "turn this into notes", "process the lecture", or simply uploads the material without an explicit verb.
version: 1.0
trigger: /notes-extractor
---

# Notes Extractor Skill

## Goal
Convert a raw transcript or text source into clean intermediate Markdown. Extract every substantive unit (definition, equation, derivation, worked example), verify its correctness, and preserve any embedded images.

## Inputs
- **Transcript / text**: plain text, SRT, or pasted text. May be ASR output (typo-prone, no math).
- **Embedded images**: any figure, diagram, or screenshot supplied with the source.

## Trigger
Activate when the user:
- Pastes or references a transcript, lecture, talk, or seminar.
- Asks to extract / clean / digitize / process / convert notes from a text source.
- Uses loose phrasings ("digitize this", "convert my notes", "turn this into notes") while supplying the material.

## Workflow

1. **Segment the source**: Split into topic blocks at evident topic shifts ("Now let's look at...", "Next,", silence/scene markers in SRT). Each block becomes one `##` section.
2. **Extract substantive units** under each topic:
   - **Definitions** — formal statements of what something is.
   - **Equations** — display-form expressions; inline relations only if non-trivial.
   - **Derivations** — multi-step manipulations (preserve every step).
   - **Worked examples** — concrete instances with numbers.
   Drop verbal scaffolding ("so basically", "you know", "right?", repetitions).
3. **Verify correctness**: Fix clear typos and ASR mishearings ("Galois" misheard as "galaxy", "eigenvalue" as "agonalue", "sigma squared" as "sigma squad"). Decode in place. Correct factual or logical errors; note any substantive correction inside a `>[!remark]`.
4. **Preserve embedded images**: Place each figure or image inline at the contextual point in the topic block where it belongs — not in a consolidated section.
   - Image supplied with the source → `![image: <one-line caption>](<filename or source ref>)`, placed near the unit it illustrates. If placement is unclear, put it at the end of the most plausible topic block and flag with a trailing `[?]`.
   - **URL spoken in the source** (e.g., "see arxiv slash 2401 dot 12345") → reconstruct the URL when unambiguous and emit as an inline link; if ambiguous, emit verbatim text in backticks with `[?]`.
   - **Reference to an external object** that is not retrievable (e.g., "as on slide 5", "see the textbook chapter 3") → emit as a `>[!ref]` callout adjacent to the unit, with the verbatim reference.
   Never silently drop a figure, image, or link.
5. **Verify**: Run the `Verification Checklist` below.

## Formatting Standards

### Math
- Inline: `$...$`. Block: `$$...$$` on its own line with one blank line before and after.
- Wrap every variable, operator, and symbol in math delimiters in prose.
- Never use `\(...\)` or `\[...\]`.

### Notation
- Vectors: bold lowercase, $\mathbf{x}$.
- Matrices: bold uppercase, $\mathbf{A}$.
- Estimates: $\hat{x}$.
- Sets: calligraphic, $\mathcal{X}$.

## Output Blueprint

```
# [Inferred Topic Title — from the source opening]

## [Topic Block 1]

[Substantive content in verb-driven prose. Equations in `$$...$$`.]

>[!remark]
> [Substantive correction made during verification, if any.]

>[!ref]
> "See slide 5" [00:14:23]

![image: <caption>](slide-05.png)

## [Topic Block 2]
[Same pattern.]
```

## Content Rules

- **Verb-driven phrasing**: prefer "defines $H(f)$ as the Fourier transform of $h(t)$" over "we have here the Fourier transform thing".
- **Zero preamble**: no "in this lecture we will see". State content directly.
- **No filler adverbs**: drop `basically`, `essentially`, `obviously`, `clearly` unless they appear inside a preserved `>[!remark]`.
- **No emoji**: strip every emoji from the output.
- **English only** in output. Translate any non-English source utterance.
- **No interpretive commentary** beyond what the source states. This skill is a faithful extractor, not an explainer.

## Anti-Patterns

- Over-structuring the output (comparison tables, consolidated sub-sections). That is `module-organizer`'s job. Emit flat or two-level structure only.
- Consolidating links into a `**References:**` block. That is also `module-organizer`'s job. Keep links inline at the contextual point.
- Adding interpretive commentary the source does not contain.
- Silently dropping a figure, image, or link.

## Verification Checklist

Before delivering, confirm:
1. Every topic block in the source has a corresponding `##` section.
2. Every substantive unit (definition, equation, derivation, example) is extracted.
3. Typos, ASR mishearings, and factual errors are corrected; substantive corrections noted in a `>[!remark]`.
4. Every figure, image, and link from the source is preserved inline at its contextual point — none consolidated, none silently dropped.
5. All math uses `$...$` / `$$...$$`; no `\(...\)` or `\[...\]`.
6. Output is in English.
7. No filler adverbs, no emoji.
8. No comparison tables, no consolidation — downstream skills handle that.

## Micro-Example

**Input:**
Transcript snippet: "So the channel impulse response is h of tau, and its Fourier transform with respect to tau is the transfer function H of f. The original derivation is in Bello 1963 — arxiv has it, search Bello stationary channels. Note that under WSSUS the autocorrelation factorizes." Supplied image: `wssus-diagram.png` (a block diagram of the WSSUS factorization).

**Output fragment:**

```
## Channel transfer function

Define the time-varying channel impulse response $h(\tau, t)$. Its Fourier transform with respect to delay $\tau$ gives the time-varying transfer function:

$$
H(f, t) = \int h(\tau, t)\, e^{-j 2\pi f \tau}\, d\tau
$$

Original derivation: Bello, "Characterization of Randomly Time-Variant Linear Channels," IEEE Trans. Commun., 1963.

Under WSSUS, $R_h$ separates in $(\tau, \Delta t)$.

![image: WSSUS factorization block diagram](wssus-diagram.png)
```
