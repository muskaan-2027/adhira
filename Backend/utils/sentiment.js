const HIGH_RISK_KEYWORDS = [
    "danger",
    "unsafe",
    "abuse",
    "stalk",
    "threat",
    "attack",
    "help me",
    "emergency"
];

const MEDIUM_RISK_KEYWORDS = [
    "sad",
    "alone",
    "scared",
    "worried",
    "anxious",
    "harassed"
];

exports.analyze = (text = "") => {
    const normalized = text.toLowerCase();

    if (HIGH_RISK_KEYWORDS.some((keyword) => normalized.includes(keyword))) {
        return "high";
    }

    if (MEDIUM_RISK_KEYWORDS.some((keyword) => normalized.includes(keyword))) {
        return "medium";
    }

    return "normal";
};

exports.suggestActions = (level) => {
    if (level === "high" || level === "medium") {
        return ["chatbot", "volunteer_help"];
    }

    return [];
};
