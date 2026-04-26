const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
    {
        name: { type: String, trim: true },
        email: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
        password: { type: String },
        googleId: { type: String, unique: true, sparse: true },
        isAnonymous: { type: Boolean, default: false },
        role: {
            type: String,
            enum: ["user", "volunteer"],
            default: null
        },
        onboardingCompleted: { type: Boolean, default: false },
        voterIdVerified: { type: Boolean, default: false },
        volunteerAvailability: {
            type: String,
            enum: ["active", "inactive"],
            default: "inactive"
        }
    },
    { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
