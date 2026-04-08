const { Resend } = require('resend');

let resend = null;

function getClient() {
  if (!resend && process.env.RESEND_API_KEY) {
    resend = new Resend(process.env.RESEND_API_KEY);
  }
  return resend;
}

async function sendPasswordResetEmail(to, code) {
  const client = getClient();

  const fromAddress = process.env.EMAIL_FROM || 'noreply@plagit.com';
  const subject = `Plagit Admin — Password Reset Code: ${code}`;
  const html = `
    <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <div style="text-align: center; margin-bottom: 24px;">
        <div style="width: 48px; height: 48px; border-radius: 50%; background: #00B5B0; display: inline-flex; align-items: center; justify-content: center;">
          <span style="color: white; font-size: 22px; font-weight: bold;">P</span>
        </div>
      </div>
      <h2 style="color: #1a1c24; text-align: center; margin-bottom: 8px;">Password Reset</h2>
      <p style="color: #70757f; text-align: center; margin-bottom: 24px;">Use this code to reset your Plagit Admin password:</p>
      <div style="text-align: center; margin: 24px 0;">
        <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #1a1c24; background: #f6f7f8; padding: 16px 32px; border-radius: 12px; display: inline-block;">${code}</span>
      </div>
      <p style="color: #9ea0a5; text-align: center; font-size: 13px;">This code expires in 15 minutes. If you didn't request this, ignore this email.</p>
    </div>
  `;

  if (!client) {
    // No email provider configured — log the code to console for development
    console.log(`[Email] Password reset code for ${to}: ${code}`);
    console.log('[Email] Set RESEND_API_KEY env var to send real emails.');
    return;
  }

  try {
    await client.emails.send({ from: fromAddress, to, subject, html });
    console.log(`[Email] Reset code sent to ${to}`);
  } catch (err) {
    console.error(`[Email] Failed to send to ${to}:`, err.message);
    // Don't throw — the API should still respond generically to avoid leaking info
  }
}

module.exports = { sendPasswordResetEmail };
