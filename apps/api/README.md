# API (Fastify) - Meetloview MVP

Quick start:

1. Copy `.env.example` to `.env` and adjust if needed.
2. Start Postgres: `docker compose up -d` (from repo root).
3. Install dependencies: `pnpm install` at repo root.
4. Generate Prisma client: `pnpm --filter api prisma:generate` then `pnpm --filter api prisma:migrate`.
5. Run API in dev: `pnpm --filter api dev`.

VS Code: use workspace `pnpm` and the included `.vscode` launch/tasks to build and debug.
