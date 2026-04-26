const mongoose = require("mongoose");

const postSchema = new mongoose.Schema(
    {
        userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
        content: { type: String, required: true, trim: true },
        isAnonymous: { type: Boolean, default: false },
        distressLevel: {
            type: String,
            enum: ["normal", "medium", "high"],
            default: "normal"
        }
    },
    { timestamps: true }
);

module.exports = mongoose.model("Post", postSchema);
