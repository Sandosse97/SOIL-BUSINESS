# Meetloview MVP

## Quick Links

- Users (coming soon)
- Matches (coming soon)
- Messages (live) (coming soon)

## Dev Setup

1. Install PNPM, Node 20+.
2. Copy `.env.example` to `.env` and edit.
3. `docker compose -f docker/compose.yml up -d` to start Postgres + Mailhog.
4. `pnpm i`
5. `pnpm prisma:deploy`
6. VS Code: `Tasks: Run Task -> Dev` (or `pnpm dev`).

## API

- `POST /auth/request-otp { email }` -> dev OTP in logs.
- `POST /auth/verify { email, code }` -> `{ token }`.
- `GET /me` Authorization: `Bearer <token>`.
- `POST /swipe { targetId, liked }`.
- WS (Socket.IO): `join(matchId)`, `message({matchId,senderId,content})`.

## Next Steps

- Add Stripe real subscription, voice uploads (S3), moderation (OpenAI/Google), geolocation search, admin tables, mobile app, e2e tests.
