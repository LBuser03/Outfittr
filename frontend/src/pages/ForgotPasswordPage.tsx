import { useState } from "react";
import { useNavigate } from "react-router-dom";
import AuthSprayLayer from "../components/AuthSprayLayer";
import { buildApiPath } from "../utils/api";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setIsSubmitting(true);

    try {
      const response = await fetch(buildApiPath("api/forgot-password"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: email.trim() }),
      });

      const result = await response.json();

      if (!response.ok) {
        setError(result.error || "Unable to process request.");
        return;
      }

      setMessage(result.message || "Check your email for a reset link.");
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
          <h2 className="graffiti-title bubble-title" aria-label="RESET">
            <span className="bubble-title-line">
              <span className="bubble-char">R</span>
              <span className="bubble-char">E</span>
              <span className="bubble-char">S</span>
              <span className="bubble-char">E</span>
              <span className="bubble-char">T</span>
            </span>
          </h2>
          <p className="card-copy bubble-copy" aria-label="Enter your email and we'll send you a reset link.">
            <span className="copy-word">Enter</span>
            <span className="copy-word">your</span>
            <span className="copy-word">email</span>
            <span className="copy-word">and</span>
            <span className="copy-word">we'll</span>
            <span className="copy-word">send</span>
            <span className="copy-word">you</span>
            <span className="copy-word">a</span>
            <span className="copy-word">reset</span>
            <span className="copy-word">link.</span>
          </p>

          <form onSubmit={handleSubmit}>
            <input
              type="email"
              placeholder="EMAIL"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />

            {error ? <p className="form-feedback error-text">{error}</p> : null}
            {message ? <p className="form-feedback">{message}</p> : null}

            <button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "SENDING..." : "SEND RESET LINK"}
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
