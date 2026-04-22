import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import AuthSprayLayer from "../components/AuthSprayLayer";
import { buildApiPath } from "../utils/api";

const PASSWORD_REQUIREMENTS_MESSAGE =
  "Password must contain at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character.";

function isPasswordValid(password: string) {
  return /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$/.test(
    password || "",
  );
}

export default function ResetPasswordPage() {
  const [searchParams] = useSearchParams();
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const navigate = useNavigate();
  const resetToken = searchParams.get("token") ?? "";

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setMessage("");

    if (!resetToken) {
      setError("Missing reset token. Please request a new reset link.");
      return;
    }

    if (!isPasswordValid(password)) {
      setError(PASSWORD_REQUIREMENTS_MESSAGE);
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch(buildApiPath("api/reset-password"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token: resetToken, password }),
      });

      const result = await response.json();

      if (!response.ok) {
        setError(result.error || "Unable to reset password.");
        return;
      }

      setMessage(result.message || "Password reset. You can now sign in.");
      window.setTimeout(() => navigate("/"), 3000);
    } catch {
      setError("We couldn't reach the server. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="graffiti-wrapper auth-backdrop">
        <AuthSprayLayer />
        <div className="paint-orb orb-one" />
        <div className="paint-orb orb-two" />
        <div className="spray-cluster spray-left">
          <span />
          <span />
          <span />
          <span />
        </div>
        <div className="spray-cluster spray-right">
          <span />
          <span />
          <span />
          <span />
        </div>
      </div>

      <div className="login-container auth-container">
        <div className="login-card">
          <h2 className="graffiti-title bubble-title" aria-label="NEW PASS">
            <span className="bubble-title-line">
              <span className="bubble-char">N</span>
              <span className="bubble-char">E</span>
              <span className="bubble-char">W</span>
            </span>
            <span className="bubble-title-line">
              <span className="bubble-char">P</span>
              <span className="bubble-char">A</span>
              <span className="bubble-char">S</span>
              <span className="bubble-char">S</span>
            </span>
          </h2>
          <p className="card-copy bubble-copy" aria-label="Choose a new password for your account.">
            <span className="copy-word">Choose</span>
            <span className="copy-word">a</span>
            <span className="copy-word">new</span>
            <span className="copy-word">password</span>
            <span className="copy-word">for</span>
            <span className="copy-word">your</span>
            <span className="copy-word">account.</span>
          </p>

          <form onSubmit={handleSubmit}>
            <input
              type="password"
              placeholder="NEW PASSWORD"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            <p className="form-feedback">{PASSWORD_REQUIREMENTS_MESSAGE}</p>

            <input
              type="password"
              placeholder="CONFIRM PASSWORD"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />

            {error ? <p className="form-feedback error-text">{error}</p> : null}
            {message ? <p className="form-feedback">{message}</p> : null}
            {message ? <p className="form-feedback">Redirecting to sign in in 3 seconds...</p> : null}

            <button type="submit" disabled={isSubmitting || !!message}>
              {isSubmitting ? "SAVING..." : "SET PASSWORD"}
            </button>
          </form>

          <p className="link-text">
            <span className="doodle-link" onClick={() => navigate("/")}>
              BACK TO SIGN IN
            </span>
          </p>
        </div>
      </div>
    </div>
  );
}
