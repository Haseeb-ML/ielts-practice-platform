# IELTS Writing Evaluation API

## Setup

```powershell
cd backend
npm install
Copy-Item .env.example .env
```

Add `GEMINI_API_KEY` to `.env`, then run:

```powershell
npm start
```

The API listens on `http://localhost:8787`.

## Offline test

Set `MOCK_MODE=true` in `.env`. The endpoint will return a small mock response without internet or Gemini.

## Endpoint

`POST /api/evaluate-writing`

Required JSON fields: `testId`, `task1Question`, `task2Question`, and at least one of `task1Answer` or `task2Answer`.

The API key stays on the backend. Never put it in Flutter or commit `.env`.
