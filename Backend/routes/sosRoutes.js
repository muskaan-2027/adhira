const router = require("express").Router();
const SOS = require("../models/SOS");
const auth = require("../middleware/authMiddleware");

router.post("/", auth, async (req, res) => {
    try {
        const { lat, lng, notes = "" } = req.body;

        if (typeof lat !== "number" || typeof lng !== "number") {
            return res.status(400).json({ message: "lat and lng are required numeric values" });
        }

        const sos = await SOS.create({
            userId: req.user,
            location: { lat, lng },
            notes
        });

        return res.status(201).json({ message: "SOS sent", sos });
    } catch (err) {
        return res.status(500).json({ message: "Failed to send SOS" });
    }
});

router.get("/history", auth, async (req, res) => {
    try {
        const history = await SOS.find({ userId: req.user }).sort({ createdAt: -1 });
        return res.json({ history });
    } catch (err) {
        return res.status(500).json({ message: "Failed to fetch SOS history" });
    }
});

module.exports = router;
