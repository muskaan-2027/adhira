const User = require("../models/User");

exports.listVolunteers = async (req, res) => {
    try {
        const { onlyActive = "false" } = req.query;
        const filter = { role: "volunteer" };

        if (String(onlyActive).toLowerCase() === "true") {
            filter.volunteerAvailability = "active";
        }

        const volunteers = await User.find(filter)
            .select("name email volunteerAvailability voterIdVerified")
            .sort({ updatedAt: -1 });

        return res.json({ volunteers });
    } catch (err) {
        return res.status(500).json({ message: "Failed to fetch volunteer profiles" });
    }
};

exports.updateAvailability = async (req, res) => {
    try {
        const { availability } = req.body;

        if (!["active", "inactive"].includes(availability)) {
            return res.status(400).json({ message: "availability must be 'active' or 'inactive'" });
        }

        const user = await User.findById(req.user);
        if (!user || user.role !== "volunteer") {
            return res.status(403).json({ message: "Only volunteers can update availability" });
        }

        user.volunteerAvailability = availability;
        await user.save();

        return res.json({ availability: user.volunteerAvailability });
    } catch (err) {
        return res.status(500).json({ message: "Failed to update availability" });
    }
};
