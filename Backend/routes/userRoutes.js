const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const { getMe, updateProfile, updateRole } = require("../controllers/userController");

router.get("/me", auth, getMe);
router.patch("/profile", auth, updateProfile);
router.patch("/role", auth, updateRole);

module.exports = router;
