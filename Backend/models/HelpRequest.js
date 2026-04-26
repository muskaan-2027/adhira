const mongoose = require("mongoose");

const helpRequestSchema = new mongoose.Schema(
    {
        requesterId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
        volunteerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
        sosId: { type: mongoose.Schema.Types.ObjectId, ref: "SOS", default: null },
        message: { type: String, required: true, trim: true },
        assistanceNote: { type: String, default: "", trim: true },
        status: {
            type: String,
            enum: ["pending", "accepted", "rejected", "completed"],
            default: "pending"
        }
    },
    { timestamps: true }
);

module.exports = mongoose.model("HelpRequest", helpRequestSchema);
