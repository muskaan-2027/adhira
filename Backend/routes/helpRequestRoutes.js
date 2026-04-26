const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const {
    createHelpRequest,
    listHelpRequests,
    updateHelpRequestStatus
} = require("../controllers/helpRequestController");

router.post("/", auth, createHelpRequest);
router.get("/", auth, listHelpRequests);
router.patch("/:id/status", auth, updateHelpRequestStatus);

module.exports = router;
