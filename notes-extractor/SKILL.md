---
name: notes-extractor
description: Extract substantive content (definitions, equations, derivations, examples) from a transcript paired with handwritten-note image(s), cross-check the two sources, correct in-source errors, and emit clean intermediate Markdown ready for the data-organizer skill. Trigger whenever the user provides BOTH a transcript (text/SRT/paste) AND one or more handwritten-note images and asks to extract/transcribe/clean/digitize/process/convert — including loose phrasings like "turn these into notes", "fuse my notes with the recording", "process the lecture + my handwriting", or simply uploads the pair without an explicit verb. Use even when the user does not name the data-organizer skill — this skill is its upstream stage.
version: 1.0
---

# Notes Extractor Skill

## Goal
Convert a paired raw record — transcript text + handwritten image(s) covering the same content — into clean intermediate Markdown. Every substantive unit (definition, equation, derivation, worked example) is preserved. The two sources cross-validate; genuine conflicts are flagged, never silently resolved.

## Inputs
- **Transcript**: plain text, SRT, or pasted text. May be ASR output (typo-prone, no math).
- **Handwritten image(s)**: photo or scan of notes; may contain text, equations, figures, arrows, marginalia.

If only one input type is present, state this to the user and ask whether to proceed in single-source mode or wait for the second source. Single-source mode disables cross-validation and the conflict-flag step; everything else is unchanged.

## Trigger
Activate when the user:
- Uploads handwritten image(s) and pastes/references a transcript.
- Asks to extract / transcribe / clean / digitize / process notes from multiple sources.
- References a lecture, talk, or seminar with accompanying handwritten notes.
- Uses loose phrasings ("digitize these", "fuse these", "convert my notes") while supplying the paired material.

## Workflow

1. **Inventory sources**: Identify the transcript and each handwritten image. State briefly what was received (e.g., "1 transcript ~800 lines, 3 handwriting images").
2. **Transcribe handwriting**: For each image, produce a verbatim transcription. Render equations in LaTeX with `$...$` / `$$...$$`. For figures, produce a one-line caption describing what is depicted. Do NOT discard ambiguous strokes — mark them `[?]` immediately after the uncertain token (e.g., $\sigma_{x}^{[?]}$).
3. **Segment the transcript**: Split into topic blocks at evident topic shifts ("Now let's look at...", "Next,", silence/scene markers in SRT). Each block becomes one `##` section.
4. **Align**: For each topic block, locate the corresponding region(s) of handwriting. Many-to-many alignment is allowed; the same image may serve multiple topic blocks.
5. **Extract substantive units** under each topic:
   - **Definitions** — formal statements of what something is.
   - **Equations** — display-form expressions; inline relations only if non-trivial.
   - **Derivations** — multi-step manipulations (preserve every step).
   - **Worked examples** — concrete instances with numbers.
   Drop verbal scaffolding ("so basically", "you know", "right?", repetitions).
6. **Cross-validate** each unit:
   - Both sources state the same fact and agree → emit once, no source tag.
   - Only handwriting has it (e.g., side-derivation not voiced) → emit, tag `[hw]`.
   - Only transcript has it (e.g., remark not written) → emit, tag `[tr]`.
   - Sources disagree on a substantive element (wrong subscript, swapped sign, different numerical value, definition wording that changes meaning) → emit a `>[!conflict]` callout (format below). Do NOT pick a winner.
7. **Correct in-source errors**: Within a single source, fix clear typos and ASR mishearings ("Galois" misheard as "galaxy", "eigenvalue" as "agonalue", "sigma squared" as "sigma squad"). Mishearings are NOT conflicts — they are decoded in place. Reserve `>[!conflict]` for substantive disagreement only.
8. **Preserve marginalia**: Stars, boxes, underlines, arrows, and personal remarks from the handwriting become `>[!remark]` callouts placed at the relevant point. Annotate the visual cue (e.g., `[hw, boxed]`, `[hw, double-underlined]`).
9. **Preserve embedded media** (figures, supplementary images, links) from either source. Place each item inline at the contextual point in the topic block to which it belongs — not in a consolidated References section.
   - **Handwriting figure / sketch on the page** → `![figure: <one-line caption>](handwriting-page-<N>)`.
   - **Supplementary image supplied alongside the inputs** (e.g., a slide screenshot, a separately uploaded diagram) → `![image: <one-line caption>](<filename or source ref>)`, placed near the unit it illustrates. If the user did not state where it belongs, infer from caption/content; if no inference is possible, place it at the end of the most plausible topic block and flag with a trailing `[?]`.
   - **URL or citation in the handwriting margin** → emit as inline link `[<descriptive title>](<url>)` adjacent to the unit it annotates, tagged `[hw]`.
   - **URL spoken in the transcript** (e.g., "see arxiv slash 2401 dot 12345") → reconstruct the URL when unambiguous and emit as inline link tagged `[tr]`; if ambiguous, emit verbatim text in backticks with `[?]`.
   - **Reference to an external object** that is not retrievable (e.g., "as on slide 5", "see the textbook chapter 3") → emit as a `>[!ref]` callout adjacent to the unit, with the verbatim reference.
   Never silently drop a figure, image, or link.
10. **Verify**: Run the `Verification Checklist` below.

## Conflict Format

Use this exact callout for every cross-source disagreement:

```
>[!conflict] <short label>
> - **Transcript**: <what the transcript says, with timestamp if available>
> - **Handwriting**: <what the handwriting says, image region>
> - **Type**: <equation | definition | numerical value | terminology | other>
```

Do not append a resolution. The user resolves downstream.

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

### Source tags
Append at the end of an emitted unit only when single-source:
- `[hw]` — handwriting only.
- `[tr]` — transcript only.
- (no tag) — corroborated by both.

## Output Blueprint

```
# [Inferred Topic Title — from transcript opening or handwriting heading]

## [Topic Block 1]

[Substantive content in verb-driven prose. Equations in `$$...$$`. Source tags as needed.]

See [Descriptive title](https://example.com/paper) [hw] for the original derivation.

>[!remark]
> [Preserved marginalia from handwriting.] [hw, boxed]

>[!conflict] <label>
> - **Transcript**: ...
> - **Handwriting**: ...
> - **Type**: ...

>[!ref]
> "See slide 5" [tr, 00:14:23]

![figure: <caption>](handwriting-page-1)
![image: <caption>](slide-05.png)

## [Topic Block 2]
[Same pattern.]
```

## Content Rules

- **Verb-driven phrasing**: prefer "defines $H(f)$ as the Fourier transform of $h(t)$" over "we have here the Fourier transform thing".
- **Zero preamble**: no "in this lecture we will see". State content directly.
- **No filler adverbs**: drop `basically`, `essentially`, `obviously`, `clearly` unless they appear inside a preserved `>[!remark]`.
- **English only** in output. Translate any non-English source utterance.
- **No interpretive commentary** beyond what the sources state. This skill is a faithful extractor, not an explainer.

## Anti-Patterns

- Silently resolving a transcript/handwriting conflict. Always emit `>[!conflict]`.
- Treating an ASR mishearing as a real disagreement with the handwriting. If handwriting plainly says $\sigma^2$ and transcript says "sigma squad", that is a mishearing — decode in place.
- Dropping a side-derivation that exists only in the handwriting because the lecturer never voiced it.
- Over-structuring the output (comparison tables, consolidated sub-sections). That is `module-organizer`'s job. Emit flat or two-level structure only.
- Consolidating links into a `**References:**` block. That is also `module-organizer`'s job. Keep links inline at the contextual point.
- Adding interpretive commentary the sources do not contain.
- Resolving an ambiguous stroke by guessing. Preserve `[?]`.

## Verification Checklist

Before delivering, confirm:
1. Every equation visible in the handwriting appears in the output (or is flagged ambiguous with `[?]`).
2. Every topic block in the transcript has a corresponding `##` section.
3. Every cross-source disagreement is captured in a `>[!conflict]` callout — none silently resolved.
4. Every starred / boxed / underlined item from the handwriting is preserved as `>[!remark]` with its visual cue annotated.
5. Every figure, supplementary image, and link from either source is preserved inline at its contextual point — none consolidated, none silently dropped.
6. All math uses `$...$` / `$$...$$`; no `\(...\)` or `\[...\]`.
7. Source tags `[hw]` / `[tr]` are present on single-source units; absent on corroborated ones.
8. Output is in English.
9. No filler adverbs outside preserved callouts.
10. No comparison tables, no consolidation — downstream skills handle that.

## Micro-Example

**Inputs:**
- Transcript snippet: "So the channel impulse response is h of tau, and its Fourier transform with respect to tau is the transfer function H of f. The original derivation is in Bello 1963 — arxiv has it, search Bello stationary channels. Note that under WSSUS the autocorrelation factorizes."
- Handwriting (page 1): shows `h(τ, t)`, an arrow to `H(f, t) = ∫ h(τ,t) e^{-j2πfτ} dτ`, a boxed note `WSSUS → R_h separable in (τ, Δt)`, and a margin scribble `Bello '63, IEEE Trans Comm`.
- Supplementary image supplied: `wssus-diagram.png` (a block diagram of the WSSUS factorization).

**Output fragment:**

```
## Channel transfer function

Define the time-varying channel impulse response $h(\tau, t)$. Its Fourier transform with respect to delay $\tau$ gives the time-varying transfer function:

$$
H(f, t) = \int h(\tau, t)\, e^{-j 2\pi f \tau}\, d\tau
$$

Original derivation: Bello, "Characterization of Randomly Time-Variant Linear Channels," IEEE Trans. Commun., 1963 [hw, tr].

>[!conflict] argument list of $h$
> - **Transcript**: $h(\tau)$ — single argument
> - **Handwriting**: $h(\tau, t)$ — two arguments
> - **Type**: definition

>[!remark]
> Under WSSUS, $R_h$ separates in $(\tau, \Delta t)$. [hw, boxed]

![image: WSSUS factorization block diagram](wssus-diagram.png)
```
