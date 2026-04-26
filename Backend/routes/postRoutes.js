const router = require("express").Router();
const Post = require("../models/Post");
const auth = require("../middleware/authMiddleware");
const { analyze, suggestActions } = require("../utils/sentiment");

router.post("/analyze", auth, async (req, res) => {
    try {
        const { content } = req.body;
        if (!content || !content.trim()) {
            return res.status(400).json({ message: "content is required" });
        }

        const distressLevel = analyze(content);
        const suggestedActions = suggestActions(distressLevel);
        return res.json({ distressLevel, suggestedActions });
    } catch (err) {
        return res.status(500).json({ message: "Failed to analyze post content" });
    }
});

router.post("/", auth, async (req, res) => {
    try {
        const { content, isAnonymous = false } = req.body;

        if (!content || !content.trim()) {
            return res.status(400).json({ message: "content is required" });
        }

        const distressLevel = analyze(content);
        const suggestedActions = suggestActions(distressLevel);

        const post = await Post.create({
            userId: req.user,
            content,
            isAnonymous,
            distressLevel
        });

        return res.status(201).json({
            post,
            distressLevel,
            suggestedActions
        });
    } catch (err) {
        return res.status(500).json({ message: "Failed to create post" });
    }
});

router.get("/", async (req, res) => {
    try {
        const posts = await Post.find().sort({ createdAt: -1 });
        return res.json({ posts });
    } catch (err) {
        return res.status(500).json({ message: "Failed to fetch posts" });
    }
});

module.exports = router;
