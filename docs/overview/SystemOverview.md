# Intentions

Intentions is a backend system for maintaining personal and professional relationships in a thoughtful, low-friction way.

It helps answer:

- Who should I stay in touch with?
- What should I bring up when I reach out?
- How often should I reconnect?

It is a structured memory + reminder system designed to reduce the cognitive overhead of staying connected.

---

## System Overview

The system consists of:

- Account authentication (Supabase or similar)
- Contact sync and storage
- Interaction logging (notes, calls, meetings, transcripts)
- AI-assisted message generation
- Reminder scheduling
- Lightweight outreach triage
- Relationship metrics (awareness layer)

Core idea:

Capture interactions quickly → compute simple relationship state → surface timely nudges.

---

## Architecture

High-level data model:

![Database Schema](img/initial_schema_02222026.png)

---

## Data Model

Core entities:

- **Users** — authenticated accounts
- **Contacts** — people you maintain relationships with
- **Interactions** — logged touchpoints (calls, texts, notes, etc.)
- **Reminders** — scheduled nudges to reconnect
- **Relationship Metrics** — computed summary data

---

## Relationship Metrics

Derived (not source-of-truth) table storing:

- `last_contacted_at`
- `interaction_count`
- `strength_score`

This can be recalculated from interactions at any time.

---


## Future Extensions

- Contact tagging (family, friends, mentors)
- Birthday awareness
- Sentiment tracking
- AI-driven reflection prompts
- Community-level analytics

--- 