# Hackathon Voting App - Quick Reference

## 🚀 Your App is Ready!

The Phoenix LiveView voting application is running at: **http://localhost:4000**

## ✅ What's Built

### Features
- ✅ 8 hackathon projects pre-seeded
- ✅ User registration with project selection
- ✅ Email-based authentication
- ✅ 5 votes per team to distribute
- ✅ Can't vote for own project
- ✅ Real-time vote updates (using Phoenix PubSub)
- ✅ Click any project to see who voted for it
- ✅ Modern gradient UI with Tailwind CSS
- ✅ One-time voting (can't change after submit)

### Tech Stack
- Phoenix 1.8 + LiveView
- PostgreSQL (port 5435)
- Tailwind CSS v4
- Phoenix PubSub for real-time

## 📝 Quick Test Steps

### 1. Register First Team
1. Go to http://localhost:4000/users/register
2. Email: `team1@example.com`
3. Select "CRM - Smart Notifications & Bonus"
4. Click "Create an account"

### 2. Get Login Link
1. Go to http://localhost:4000/dev/mailbox
2. Click the email
3. Click the login link

### 3. Vote
1. You'll see 7 projects (your own is excluded)
2. Distribute 5 votes (e.g., 2 to one project, 3 to another)
3. Click "Submit Votes"

### 4. See Real-time Updates
1. Register another team (team2@example.com)
2. Vote from that account
3. Watch votes update in real-time on both screens!

### 5. Check Who Voted
1. Click on any project card
2. Modal shows who voted and how many votes they gave

## 🌐 Deploy to Production (FREE)

### Option 1: Fly.io (Recommended)

```bash
# Install Fly CLI
brew install flyctl

# Login
fly auth login

# Launch app (follow prompts)
fly launch

# Set secret
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)

# Deploy
fly deploy

# Run migrations & seeds
fly ssh console -C "/app/bin/migrate"
fly ssh console -C '/app/bin/polly eval "Polly.Release.seed()"'
```

Your app: `https://your-app-name.fly.dev`

### Option 2: Railway.app

1. Push to GitHub
2. Go to https://railway.app
3. New Project → Deploy from GitHub
4. Add PostgreSQL service
5. Set `SECRET_KEY_BASE` env var
6. Deploy!

## 🎯 The 8 Projects

1. CRM - Smart Notifications & Bonus
2. RB - Tournament Hub
3. RB - Kambi Mosaic
4. RB - Trending Bet
5. CRM - Worldcup
6. CRM - Conversational AI
7. RG - Brave new world (AI-led lobby mgt incl boosting)
8. RG - New player casino recs model (soft Game)

## 🔧 Useful Commands

```bash
# Start server
mix phx.server

# Reset database
mix ecto.reset

# Re-seed projects
mix run priv/repo/seeds.exs

# Check routes
mix phx.routes

# Run tests
mix test
```

## 📁 Key Files

- `lib/polly_web/live/voting_live.ex` - Main voting page
- `lib/polly_web/live/user_live/registration.ex` - Registration
- `lib/polly/hackathon.ex` - Voting business logic
- `priv/repo/seeds.exs` - Project seeds
- `lib/polly_web/router.ex` - Routes

## 🐛 Troubleshooting

**Can't connect to database?**
- Make sure PostgreSQL is running on port 5435
- Check credentials in `config/dev.exs`

**Votes not updating in real-time?**
- Make sure you're opening in different browser tabs/windows
- Phoenix PubSub broadcasts to all connected clients

**Need to reset everything?**
```bash
mix ecto.reset
mix run priv/repo/seeds.exs
```

## 🎉 You're All Set!

The app is production-ready and can be deployed right now. Just follow the deployment steps above and share the URL with your teams!

**Need Help?** Check `DEPLOYMENT.md` for detailed deployment instructions.
