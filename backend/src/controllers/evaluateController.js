const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'meta-llama/llama-4-scout-17b-16e-instruct';

/**
 * POST /evaluate
 * Body: { character: string, imageBase64: string, exerciseType?: "letter"|"word"|"sentence" }
 * Returns: { score, feedback, detailed_feedback, encouragement, tips }
 */
export const evaluate = async (req, res, next) => {
    try {
        const { character, imageBase64, exerciseType = 'letter' } = req.body;

        if (!character || !imageBase64) {
            return res.status(400).json({
                success: false,
                error: 'character and imageBase64 are required',
            });
        }

        const apiKey = process.env.GROQ_API_KEY;
        if (!apiKey) {
            return res.status(500).json({
                success: false,
                error: 'GROQ_API_KEY is not configured on the server',
            });
        }

        const prompt = buildPrompt(character, exerciseType);

        const groqResponse = await fetch(GROQ_API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
                model: GROQ_MODEL,
                max_tokens: 400,
                messages: [
                    {
                        role: 'user',
                        content: [
                            {
                                type: 'image_url',
                                image_url: {
                                    url: `data:image/png;base64,${imageBase64}`,
                                },
                            },
                            { type: 'text', text: prompt },
                        ],
                    },
                ],
            }),
        });

        if (groqResponse.status === 429) {
            return res.status(429).json({
                success: false,
                error: 'AI service is temporarily busy. Please try again in a moment.',
            });
        }

        if (!groqResponse.ok) {
            const body = await groqResponse.text();
            console.error(`[evaluate] Groq error ${groqResponse.status}: ${body}`);
            return res.status(502).json({
                success: false,
                error: 'AI evaluation failed. Please try again.',
            });
        }

        const data = await groqResponse.json();
        const content = data?.choices?.[0]?.message?.content ?? '';

        const parsed = parseGroqResponse(content, character);
        return res.json({ success: true, data: parsed });
    } catch (err) {
        next(err);
    }
};

function buildPrompt(character, exerciseType) {
    if (exerciseType === 'letter') {
        return `You are a handwriting teacher for young children (ages 4-8).
The child is practicing the letter "${character}".

Step 1 — Identify: Look carefully at the drawing and determine which letter or shape was actually written.
Step 2 — Compare: Does it match the letter "${character}"?
Step 3 — Score:
  - If the drawing does NOT look like "${character}" → score MUST be 0-30. Tell the child kindly they wrote the wrong letter.
  - If the drawing IS "${character}" (even roughly) → score 50-100 based on how well formed it is.

Respond ONLY with this exact JSON object, no extra text:
{
  "identified_letter": "<the letter/shape you actually see, or 'unclear' if blank/unrecognisable>",
  "correct_letter": <true if identified_letter matches "${character}", else false>,
  "score": <0-100>,
  "feedback": "<one short sentence, max 15 words>",
  "detailed_feedback": "<2-3 sentences>",
  "encouragement": "<motivating phrase with emoji>",
  "tips": ["<tip 1>", "<tip 2>"]
}

Rules:
- Use simple words a 5-year-old can understand.
- Always be kind and positive.
- If wrong letter: feedback must clearly but gently name the correct letter "${character}".
- Include fun emojis in encouragement.`;
    }

    // word / sentence exercise
    return `You are a handwriting teacher for young children (ages 4-8).
The child was asked to write: "${character}".

Step 1 — Read: Look at the handwritten text on the canvas.
Step 2 — Compare: Does it match "${character}"?
Step 3 — Score:
  - If it does NOT match → score 0-30. Kindly tell the child the correct answer.
  - If it matches (even roughly written) → score 50-100 based on legibility.

Respond ONLY with this exact JSON object, no extra text:
{
  "identified_letter": "<the word/text you see, or 'unclear'>",
  "correct_letter": <true if it matches "${character}", else false>,
  "score": <0-100>,
  "feedback": "<one short sentence, max 15 words>",
  "detailed_feedback": "<2-3 sentences>",
  "encouragement": "<motivating phrase with emoji>",
  "tips": ["<tip 1>", "<tip 2>"]
}

Rules:
- Use simple words a 5-year-old understands.
- Always be kind and positive.
- If wrong: gently tell them the correct answer is "${character}".
- Include fun emojis in encouragement.`;
}

function parseGroqResponse(content, character) {
    try {
        let jsonStr = content;
        if (content.includes('{')) {
            jsonStr = content.substring(
                content.indexOf('{'),
                content.lastIndexOf('}') + 1,
            );
        }
        const parsed = JSON.parse(jsonStr);

        const correctLetter = parsed.correct_letter ?? false;
        let score = Number(parsed.score ?? 50);

        // Safety clamp: wrong letter but high score
        if (!correctLetter && score > 30) {
            console.warn(`[evaluate] Wrong letter flagged for "${character}" but score=${score} — clamping to 20`);
            score = 20;
        }

        return {
            score,
            feedback: parsed.feedback ?? 'Nice try!',
            detailed_feedback: parsed.detailed_feedback ?? '',
            encouragement: parsed.encouragement ?? 'Keep going! ⭐',
            tips: parsed.tips ?? [],
            correct_letter: correctLetter,
            identified_letter: parsed.identified_letter ?? 'unclear',
        };
    } catch (err) {
        console.error('[evaluate] Failed to parse Groq response:', err.message);
        return {
            score: 50,
            feedback: 'Nice try! Keep practicing!',
            detailed_feedback: 'You are learning well. Practice makes perfect!',
            encouragement: 'You are a writing superstar! ⭐',
            tips: ['Try to trace the guide letter slowly.'],
            correct_letter: false,
            identified_letter: 'unclear',
        };
    }
}
