require("express");
const { ObjectId } = require("mongodb");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const multer = require("multer");
const { storage } = require("./cloudinaryConfig");
const createJWT = require("./createJWT");

const upload = multer({ storage });

function getVerificationExpiry() {
    return new Date(Date.now() + 24 * 60 * 60 * 1000);
}

function getVerificationToken() {
    return crypto.randomBytes(32).toString("hex");
}

function getVerificationLink(token) {
    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
    return `${frontendUrl}/verify?token=${token}`;
}

function getMailer() {
    if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
        return null;
    }

    return nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: Number(process.env.SMTP_PORT || 587),
        secure: String(process.env.SMTP_SECURE).toLowerCase() === "true",
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
        },
    });
}

async function sendVerificationEmail(email, verificationLink) {
    const transporter = getMailer();

    if (!transporter) {
        console.log(`Verification link for ${email}: ${verificationLink}`);
        return;
    }

    await transporter.sendMail({
        from: process.env.EMAIL_FROM || "Outfittr <no-reply@example.com>",
        to: email,
        subject: "Verify your Outfittr account",
        text: `Verify your email by visiting: ${verificationLink}`,
    });
}

function getBearerToken(req) {
    const header = req.headers.authorization || "";
    if (!header.startsWith("Bearer ")) {
        return "";
    }

    return header.slice(7).trim();
}

function verifyAuth(req, res, next) {
    const token = getBearerToken(req);

    if (!token) {
        return res.status(401).json({ error: "Missing authorization token" });
    }

    if (createJWT.isExpired(token)) {
        return res.status(401).json({ error: "Token expired or invalid" });
    }

    try {
        const payload = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        req.user = { userId: String(payload.userId) };
        req.token = token;
        next();
    } catch (error) {
        console.log("verifyAuth error:", error);
        return res.status(401).json({ error: "Token expired or invalid" });
    }
}

async function findVerifiedUser(db, userId) {
    const user = await db.collection("Users").findOne({ _id: new ObjectId(userId) });

    if (!user) {
        return { error: "User not found", status: 404 };
    }

    if (user.verified !== true) {
        return { error: "Please verify your email before continuing", status: 403 };
    }

    return { user };
}

exports.setApp = function setApp(app, client) {
    app.post("/api/register", async (req, res) => {
        const { email, password } = req.body;
        const db = client.db("OutfittrDB");

        try {
            const existing = await db.collection("Users").findOne({ email });
            if (existing) {
                return res.status(200).json({ error: "Email already exists", accessToken: "" });
            }

            const verificationToken = getVerificationToken();
            const verificationExpires = getVerificationExpiry();
            const passwordHash = await bcrypt.hash(password, 10);

            await db.collection("Users").insertOne({
                email,
                password: passwordHash,
                verified: false,
                verificationToken,
                verificationExpires,
            });

            const verificationLink = getVerificationLink(verificationToken);
            await sendVerificationEmail(email, verificationLink);

            return res.status(200).json({
                error: "",
                message: "Check your email for a verification link.",
            });
        } catch (error) {
            console.log("register error:", error);
            return res.status(500).json({ error: error.toString(), accessToken: "" });
        }
    });

    app.get("/api/verify", async (req, res) => {
        const { token } = req.query;
        const db = client.db("OutfittrDB");

        try {
            if (!token) {
                return res.status(400).json({ error: "Missing verification token" });
            }

            const user = await db.collection("Users").findOne({
                verificationToken: token,
            });

            if (!user) {
                return res.status(400).json({ error: "Invalid verification token" });
            }

            if (!user.verificationExpires || new Date(user.verificationExpires) < new Date()) {
                return res.status(400).json({ error: "Verification token has expired" });
            }

            await db.collection("Users").updateOne(
                { _id: user._id },
                {
                    $set: { verified: true },
                    $unset: { verificationToken: "", verificationExpires: "" },
                }
            );

            return res.status(200).json({ message: "Email verified successfully" });
        } catch (error) {
            console.log("verify error:", error);
            return res.status(500).json({ error: "Unable to verify email" });
        }
    });

    app.post("/api/resend-verification", async (req, res) => {
        const { email } = req.body;
        const db = client.db("OutfittrDB");

        try {
            const user = await db.collection("Users").findOne({ email });

            if (user && user.verified !== true) {
                const verificationToken = getVerificationToken();
                const verificationExpires = getVerificationExpiry();

                await db.collection("Users").updateOne(
                    { _id: user._id },
                    {
                        $set: {
                            verificationToken,
                            verificationExpires,
                        },
                    }
                );

                const verificationLink = getVerificationLink(verificationToken);
                await sendVerificationEmail(email, verificationLink);
            }

            return res.status(200).json({
                message: "If that account exists and is not verified, a new verification email has been sent.",
            });
        } catch (error) {
            console.log("resend verification error:", error);
            return res.status(500).json({ error: "Unable to resend verification email" });
        }
    });

    app.post("/api/login", async (req, res) => {
        const { login, password } = req.body;
        const db = client.db("OutfittrDB");

        try {
            const user = await db.collection("Users").findOne({ email: login });

            if (!user) {
                return res.status(401).json({ error: "Email/Password incorrect" });
            }

            const passwordMatches = await bcrypt.compare(password, user.password);
            if (!passwordMatches) {
                return res.status(401).json({ error: "Email/Password incorrect" });
            }

            if (user.verified !== true) {
                return res.status(403).json({ error: "Please verify your email before logging in" });
            }

            return res.status(200).json(createJWT.createToken(user._id));
        } catch (error) {
            console.log("login error:", error);
            return res.status(500).json({ error: error.message });
        }
    });

    app.get("/api/me", verifyAuth, async (req, res) => {
        const db = client.db("OutfittrDB");

        try {
            const user = await db.collection("Users").findOne({ _id: new ObjectId(req.user.userId) });

            if (!user) {
                return res.status(404).json({ error: "User not found" });
            }

            return res.status(200).json({
                userId: String(user._id),
                email: user.email,
                verified: user.verified === true,
            });
        } catch (error) {
            console.log("me error:", error);
            return res.status(500).json({ error: "Unable to load user" });
        }
    });

    app.post("/api/additem", verifyAuth, upload.single("image"), async (req, res) => {
        const { name, type, tags, notes } = req.body;
        const db = client.db("OutfittrDB");

        try {
            const userResult = await findVerifiedUser(db, req.user.userId);
            if (!userResult.user) {
                return res.status(userResult.status).json({ error: userResult.error, accessToken: "" });
            }

            const imageURL = req.file
                ? req.file.path && req.file.path.startsWith("http")
                    ? req.file.path
                    : `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`
                : "";

            let parsedTags = [];
            if (Array.isArray(tags)) {
                parsedTags = tags;
            } else if (typeof tags === "string" && tags.length > 0) {
                try {
                    const decoded = JSON.parse(tags);
                    parsedTags = Array.isArray(decoded) ? decoded : tags.split(",").map((tag) => tag.trim()).filter(Boolean);
                } catch (error) {
                    parsedTags = tags.split(",").map((tag) => tag.trim()).filter(Boolean);
                }
            }

            const newItem = {
                UserId: req.user.userId,
                name,
                type,
                tags: parsedTags,
                notes,
                imageURL,
            };

            const result = await db.collection("Items").insertOne(newItem);
            const refreshedToken = req.token ? createJWT.refresh(req.token) : { accessToken: "" };

            return res.status(200).json({
                error: "",
                accessToken: refreshedToken.accessToken,
                id: String(result.insertedId),
                imageURL: newItem.imageURL,
                item: { ...newItem, itemId: String(result.insertedId) },
            });
        } catch (error) {
            console.log("additem error:", error);
            let refreshedToken = { accessToken: "" };

            try {
                if (req.token) {
                    refreshedToken = createJWT.refresh(req.token);
                }
            } catch (refreshError) {
                console.log("additem refresh error:", refreshError);
            }

            return res.status(500).json({ error: error.toString(), accessToken: refreshedToken.accessToken });
        }
    });

    app.post("/api/searchitems", verifyAuth, async (req, res) => {
        const { search } = req.body;
        const db = client.db("OutfittrDB");

        try {
            const userResult = await findVerifiedUser(db, req.user.userId);
            if (!userResult.user) {
                return res.status(userResult.status).json({ error: userResult.error, accessToken: "" });
            }

            const normalizedSearch = search ? String(search).trim() : "";
            const results = await db.collection("Items")
                .find({
                    UserId: req.user.userId,
                    name: { $regex: normalizedSearch, $options: "i" },
                })
                .toArray();

            let refreshedToken = { accessToken: "" };
            try {
                if (req.token) {
                    refreshedToken = createJWT.refresh(req.token);
                }
            } catch (refreshError) {
                console.log("searchitems refresh error:", refreshError);
            }

            return res.status(200).json({
                results,
                error: "",
                accessToken: refreshedToken.accessToken,
            });
        } catch (error) {
            console.log("searchitems error:", error);
            return res.status(500).json({ error: error.toString(), accessToken: "" });
        }
    });
};
