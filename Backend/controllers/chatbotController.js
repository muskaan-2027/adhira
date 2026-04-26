const { analyze, suggestActions } = require("../utils/sentiment");
const https = require("https");

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
const DEFAULT_GROQ_MODEL = process.env.GROQ_MODEL || "llama-3.1-8b-instant";
// Key name: chatbot-Adhira


const SYSTEM_PROMPT = `You are Adhira, a calm and supportive women safety assistant.
Keep replies short and actionable (max 90 words).
If there are signs of immediate danger, prioritize immediate safety steps and tell the user to use SOS/emergency services.
Never provide legal or medical diagnosis.`;

const FALLBACK_REPLIES = {
    normal: "I am here for you.",
    medium: "You are not alone. Consider reaching out to a trusted person.",
    high: "Please press SOS immediately and contact a trusted person."
};

async function generateGroqReply(message, level) {
    const apiKey = process.env.GROQ_API_KEY;

if (!apiKey) {
    console.error("Missing GROQ_API_KEY in environment variables");
    return null;
}

    const riskContext = {
        normal: "Risk level detected: normal.",
        medium: "Risk level detected: medium. Provide emotional support and practical next steps.",
        high: "Risk level detected: high. Prioritize immediate safety and emergency escalation."
    };

    try {
        const requestBody = JSON.stringify({
            model: DEFAULT_GROQ_MODEL,
            temperature: 0.3,
            messages: [
                { role: "system", content: SYSTEM_PROMPT },
                {
                    role: "user",
                    content: `${riskContext[level] || riskContext.normal}\nUser message: ${message}`
                }
            ]
        });

        const response = await postJson(GROQ_API_URL, {
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${apiKey}`
            },
            body: requestBody
        });

        if (!response.ok) {
            console.error(`Groq API failed (${response.status}): ${response.rawBody}`);
            return null;
        }

        const payload = response.json;
        return payload?.choices?.[0]?.message?.content?.trim() || null;
    } catch (err) {
        console.error("Groq request error:", err.message);
        return null;
    }
}

function postJson(url, options) {
    return new Promise((resolve, reject) => {
        const { headers, body } = options;
        const request = https.request(
            url,
            {
                method: "POST",
                headers: {
                    ...headers,
                    "Content-Length": Buffer.byteLength(body)
                }
            },
            (response) => {
                let rawBody = "";
                response.setEncoding("utf8");
                response.on("data", (chunk) => {
                    rawBody += chunk;
                });
                response.on("end", () => {
                    let parsed = null;
                    try {
                        parsed = rawBody ? JSON.parse(rawBody) : null;
                    } catch (error) {
                        parsed = null;
                    }
                    resolve({
                        ok: response.statusCode >= 200 && response.statusCode < 300,
                        status: response.statusCode || 500,
                        rawBody,
                        json: parsed
                    });
                });
            }
        );

        request.on("error", reject);
        request.write(body);
        request.end();
    });
}

exports.chatbot = async (req, res) => {
    const message = req.body?.message?.toString().trim();
    if (!message) {
        return res.status(400).json({ message: "Message is required" });
    }

    const level = analyze(message);
    const suggestedActions = suggestActions(level);
    const fallbackReply = FALLBACK_REPLIES[level] || FALLBACK_REPLIES.normal;
    const aiReply = await generateGroqReply(message, level);

    res.json({
        reply: aiReply || fallbackReply,
        level,
        suggestedActions,
        provider: aiReply ? "groq" : "local-fallback"
    });
};
