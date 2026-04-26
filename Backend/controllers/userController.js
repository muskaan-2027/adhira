const User = require("../models/User");

const sanitizeUser = (userDoc) => {
    const user = userDoc.toObject ? userDoc.toObject() : userDoc;
    delete user.password;
    return user;
};

const computeOnboardingCompletion = (user) => {
    return Boolean(user.name && user.role);
};

exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.json({ user: sanitizeUser(user) });
    } catch (err) {
        return res.status(500).json({ message: "Failed to fetch profile" });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { name, voterIdVerified, isAnonymous } = req.body;
        const user = await User.findById(req.user);

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        if (typeof name === "string") {
            user.name = name.trim();
        }
        if (typeof voterIdVerified === "boolean") {
            user.voterIdVerified = voterIdVerified;
        }
        if (typeof isAnonymous === "boolean") {
            user.isAnonymous = isAnonymous;
        }

        user.onboardingCompleted = computeOnboardingCompletion(user);
        await user.save();

        return res.json({ user: sanitizeUser(user) });
    } catch (err) {
        return res.status(500).json({ message: "Failed to update profile" });
    }
};

exports.updateRole = async (req, res) => {
    try {
        const { role } = req.body;

        if (!["user", "volunteer"].includes(role)) {
            return res.status(400).json({ message: "role must be either 'user' or 'volunteer'" });
        }

        const user = await User.findById(req.user);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        user.role = role;
        user.onboardingCompleted = computeOnboardingCompletion(user);
        await user.save();

        return res.json({ user: sanitizeUser(user) });
    } catch (err) {
        return res.status(500).json({ message: "Failed to update role" });
    }
};
