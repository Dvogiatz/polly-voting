# Hackathon Voting App - Deployment Guide

## Quick Start (Local)

Your app is already running at http://localhost:4000

### Register Users

1. Go to http://localhost:4000/users/register
2. Create 8 accounts (one for each project team):
   - Enter email (e.g., team1@example.com)
   - Select the project for that team
   - Click "Create an account"
3. Check the mailbox at http://localhost:4000/dev/mailbox to get login links
4. Click the login link to confirm and login

### Vote

1. Once logged in, you'll see the voting page
2. Distribute your 5 votes among the OTHER 7 projects
3. You can give 1-5 votes to any project
4. Submit when you've used all 5 votes
5. Votes are shown in real-time to everyone
6. Click on any project to see who voted for it

## Deploy to Fly.io (Free)

### 1. Install Fly.io CLI

```bash
brew install flyctl
```

Or visit: https://fly.io/docs/hands-on/install-flyctl/

### 2. Sign up / Login to Fly.io

```bash
fly auth signup
# or if you have an account:
fly auth login
```

### 3. Launch the App

```bash
cd /Users/dv-vaix/Documents/Vaix/polly
fly launch --no-deploy
```

When prompted:
- App name: Choose a name (e.g., `hackathon-voting-yourname`)
- Region: Choose closest to you
- PostgreSQL: **YES** (choose free tier)
- Redis: **NO**

### 4. Set Production Secrets

```bash
# Generate a secret key
mix phx.gen.secret

# Set it as a secret in Fly.io
fly secrets set SECRET_KEY_BASE=<paste-the-generated-secret-here>
```

### 5. Deploy

```bash
fly deploy
```

### 6. Run Migrations and Seeds

```bash
# Run migrations
fly ssh console -C "/app/bin/migrate"

# Seed the 8 projects
fly ssh console
# Then inside the console:
/app/bin/polly eval "Polly.Release.seed()"
# or manually:
/app/bin/polly rpc 'File.read!("priv/repo/seeds.exs") |> Code.eval_string()'
```

### 7. Access Your App

Your app will be live at: `https://your-app-name.fly.dev`

## Alternative: Railway.app (Also Free)

If you prefer Railway:

1. Go to https://railway.app
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repo
5. Add PostgreSQL service
6. Set environment variables:
   - `SECRET_KEY_BASE` (generate with `mix phx.gen.secret`)
   - `DATABASE_URL` (automatically set by Railway)
7. Deploy!

## Features

✅ 8 projects seeded automatically
✅ Email/password authentication
✅ Each user belongs to a project
✅ 5 votes per user to distribute
✅ Can't vote for own project
✅ Real-time vote updates
✅ Click to see who voted
✅ Beautiful gradient UI
✅ Vote tracking (can't change after submit)

## Architecture

- **Phoenix LiveView** - Real-time updates without JavaScript
- **PostgreSQL** - Database
- **Tailwind CSS** - Modern styling
- **PubSub** - Real-time broadcasting

## Database Schema

- `projects` - 8 hackathon projects
- `users` - Team members (1 per project)
- `votes` - Vote records (user_id, project_id, count)

## Notes

- Free tier on Fly.io is perfect for this
- App will sleep after inactivity but wake up instantly
- No credit card required for Fly.io free tier
- Database persists between deployments
