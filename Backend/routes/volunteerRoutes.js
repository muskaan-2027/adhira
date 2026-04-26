const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const { listVolunteers, updateAvailability } = require("../controllers/volunteerController");

router.get("/", auth, listVolunteers);
router.patch("/availability", auth, updateAvailability);

module.exports = router;
