const express = require('express');
const router = express.Router();
const multer = require('multer');
const { storage } = require('./cloudinaryConfig');

const upload = multer({ storage });

router.post('/add-item', upload.single('image'), async (req, res) => {
  try {
    const imageUrl = req.file.path;
    
    res.status(200).json({ 
      message: "Image uploaded successfully!",
      url: imageUrl 
    });
  } catch (error) {
    res.status(500).json({ error: "Upload failed" });
  }
});

module.exports = router;