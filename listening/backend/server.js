import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import { GoogleGenAI } from '@google/genai';

const app = express();
const port = Number(process.env.PORT || 8787);
const mockMode = process.env.MOCK_MODE === 'true';

app.use(cors());
app.use(express.json({ limit: '1mb' }));

const evaluationSchema = {
  type: 'object',
  properties: {
    overallBand: { type: 'number' },
    taskScore: { type: 'number' },
    coherenceScore: { type: 'number' },
    vocabularyScore: { type: 'number' },
    grammarScore: { type: 'number' },
    overallFeedback: { type: 'string' },
    grammarMistakes: { type: 'array', items: { type: 'object', properties: { original: { type: 'string' }, correction: { type: 'string' }, category: { type: 'string' }, explanation: { type: 'string' } }, required: ['original', 'correction', 'category', 'explanation'] } },
    vocabularyIssues: { type: 'array', items: { type: 'object', properties: { originalWord: { type: 'string' }, issue: { type: 'string' }, suggestion: { type: 'string' }, explanation: { type: 'string' } }, required: ['originalWord', 'issue', 'suggestion', 'explanation'] } },
    repeatedWords: { type: 'array', items: { type: 'object', properties: { word: { type: 'string' }, frequency: { type: 'integer' }, alternatives: { type: 'array', items: { type: 'string' } } }, required: ['word', 'frequency', 'alternatives'] } },
    coherenceStrengths: { type: 'array', items: { type: 'string' } },
    coherenceImprovements: { type: 'array', items: { type: 'string' } },
    coherenceFeedback: { type: 'string' },
    taskFeedback: { type: 'string' },
    taskLabel: { type: 'string' },
    overviewStatus: { type: 'string' },
    sentenceAnalysis: { type: 'array', items: { type: 'object', properties: { original: { type: 'string' }, improved: { type: 'string' }, type: { type: 'string' }, explanation: { type: 'string' } }, required: ['original', 'improved', 'type', 'explanation'] } },
    improvementPlan: { type: 'array', items: { type: 'object', properties: { priority: { type: 'integer' }, category: { type: 'string' }, problem: { type: 'string' }, recommendation: { type: 'string' }, practice: { type: 'string' }, level: { type: 'string' } }, required: ['priority', 'category', 'problem', 'recommendation', 'practice', 'level'] } },
    priorityAreas: { type: 'array', items: { type: 'object', properties: { priority: { type: 'integer' }, category: { type: 'string' }, problem: { type: 'string' }, recommendation: { type: 'string' }, practice: { type: 'string' }, level: { type: 'string' } }, required: ['priority', 'category', 'problem', 'recommendation', 'practice', 'level'] } }
  },
  required: ['overallBand', 'taskScore', 'coherenceScore', 'vocabularyScore', 'grammarScore', 'overallFeedback', 'grammarMistakes', 'vocabularyIssues', 'repeatedWords', 'coherenceStrengths', 'coherenceImprovements', 'coherenceFeedback', 'taskFeedback', 'taskLabel', 'overviewStatus', 'sentenceAnalysis', 'improvementPlan', 'priorityAreas']
};

app.get('/health', (_request, response) => response.json({ ok: true, live: Boolean(process.env.GEMINI_API_KEY) && !mockMode }));

app.post('/api/evaluate-writing', async (request, response) => {
  const { testId, task1Question, task2Question, task1Answer = '', task2Answer = '', wordCount = 0 } = request.body ?? {};
  if (!testId || !task1Question || !task2Question) return response.status(400).json({ error: 'testId, task1Question and task2Question are required.' });
  if (!task1Answer.trim() && !task2Answer.trim()) return response.status(400).json({ error: 'At least one writing answer is required.' });
  if (mockMode) return response.json({ evaluation: mockEvaluation(), source: 'mock' });
  if (!process.env.GEMINI_API_KEY) return response.status(503).json({ error: 'Gemini is not configured. Add GEMINI_API_KEY to backend/.env.' });

  const prompt = `You are a careful IELTS Writing examiner. Evaluate both tasks using IELTS public band descriptors. Return only valid JSON matching the provided schema. Use simple educational English, realistic feedback, and do not invent quoted errors. Ignore common function words when finding repeatedWords.\n\nTest: ${testId}\nTask 1 question: ${task1Question}\nTask 1 answer: ${task1Answer}\nTask 2 question: ${task2Question}\nTask 2 answer: ${task2Answer}\nTotal word count: ${wordCount}`;
  try {
    const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
    const result = await ai.models.generateContent({ model: process.env.GEMINI_MODEL || 'gemini-3.6-flash', contents: prompt, config: { responseMimeType: 'application/json', responseSchema: evaluationSchema, temperature: 0.2 } });
    return response.json({ evaluation: JSON.parse(result.text), source: 'gemini' });
  } catch (error) {
    console.error('Evaluation failed:', error.message);
    return response.status(502).json({ error: 'AI evaluation failed. The writing attempt is still saved locally.' });
  }
});

function mockEvaluation() {
  return { overallBand: 6, taskScore: 6, coherenceScore: 6, vocabularyScore: 5.5, grammarScore: 5.5, overallFeedback: 'Mock evaluation. Connect Gemini to receive feedback on the submitted writing.', grammarMistakes: [], vocabularyIssues: [], repeatedWords: [], coherenceStrengths: [], coherenceImprovements: [], coherenceFeedback: 'Mock evaluation.', taskFeedback: 'Mock evaluation.', taskLabel: 'Task Response', overviewStatus: 'Pending', sentenceAnalysis: [], improvementPlan: [], priorityAreas: [] };
}

app.listen(port, () => console.log(`Writing evaluation API listening on http://localhost:${port}`));
