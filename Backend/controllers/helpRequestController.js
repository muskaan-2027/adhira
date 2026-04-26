const HelpRequest = require("../models/HelpRequest");
const User = require("../models/User");

exports.createHelpRequest = async (req, res) => {
    try {
        const { message, sosId = null, volunteerId = null } = req.body;

        if (!message) {
            return res.status(400).json({ message: "message is required" });
        }

        const requester = await User.findById(req.user);
        if (!requester) {
            return res.status(404).json({ message: "User not found" });
        }

        if (requester.role !== "user") {
            return res.status(403).json({ message: "Only normal users can create help requests" });
        }

        let assignedVolunteerId = null;
        if (volunteerId) {
            const volunteer = await User.findById(volunteerId);
            if (!volunteer || volunteer.role !== "volunteer") {
                return res.status(400).json({ message: "Selected volunteer profile is invalid" });
            }
            assignedVolunteerId = volunteer._id;
        }

        const helpRequest = await HelpRequest.create({
            requesterId: requester._id,
            volunteerId: assignedVolunteerId,
            sosId,
            message
        });

        return res.status(201).json({ helpRequest });
    } catch (err) {
        return res.status(500).json({ message: "Failed to create help request" });
    }
};

exports.listHelpRequests = async (req, res) => {
    try {
        const user = await User.findById(req.user);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        let filter = { requesterId: user._id };
        if (user.role === "volunteer") {
            filter = {
                $or: [
                    { status: "pending", volunteerId: null },
                    { status: "pending", volunteerId: user._id },
                    { volunteerId: user._id, status: { $in: ["accepted", "rejected", "completed"] } }
                ]
            };
        }

        const requests = await HelpRequest.find(filter)
            .populate("requesterId", "name")
            .populate("volunteerId", "name")
            .sort({ createdAt: -1 });

        return res.json({ requests });
    } catch (err) {
        return res.status(500).json({ message: "Failed to fetch help requests" });
    }
};

exports.updateHelpRequestStatus = async (req, res) => {
    try {
        const { status, assistanceNote = "" } = req.body;
        const user = await User.findById(req.user);

        if (!user || user.role !== "volunteer") {
            return res.status(403).json({ message: "Only volunteers can update help request status" });
        }

        if (!["accepted", "rejected", "completed"].includes(status)) {
            return res.status(400).json({ message: "Invalid status update" });
        }

        const request = await HelpRequest.findById(req.params.id);
        if (!request) {
            return res.status(404).json({ message: "Help request not found" });
        }

        if (status === "accepted") {
            if (request.status !== "pending") {
                return res.status(400).json({ message: "Only pending requests can be accepted" });
            }
            if (request.volunteerId && request.volunteerId.toString() !== user._id.toString()) {
                return res.status(403).json({ message: "This request is assigned to another volunteer" });
            }
            request.status = "accepted";
            request.volunteerId = user._id;
        }

        if (status === "rejected") {
            if (request.status !== "pending") {
                return res.status(400).json({ message: "Only pending requests can be rejected" });
            }
            if (request.volunteerId && request.volunteerId.toString() !== user._id.toString()) {
                return res.status(403).json({ message: "This request is assigned to another volunteer" });
            }
            request.status = "rejected";
            request.volunteerId = user._id;
        }

        if (status === "completed") {
            const ownsRequest = request.volunteerId && request.volunteerId.toString() === user._id.toString();
            if (!ownsRequest || request.status !== "accepted") {
                return res.status(400).json({ message: "Only accepted requests assigned to you can be completed" });
            }
            request.status = "completed";
            if (typeof assistanceNote === "string") {
                request.assistanceNote = assistanceNote.trim();
            }
        }

        await request.save();
        return res.json({ helpRequest: request });
    } catch (err) {
        return res.status(500).json({ message: "Failed to update help request" });
    }
};
