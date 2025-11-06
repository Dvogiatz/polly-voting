# Polly - Hackathon Voting App

A real-time voting application built with Phoenix LiveView for hackathon project voting.

## Features

- 🗳️ **5 votes per team** to distribute among other projects
- 🔐 **Email authentication** with project assignment
- ⚡ **Real-time updates** - see votes as they come in
- 👀 **Transparent voting** - click any project to see who voted
- 🎨 **Modern UI** with Tailwind CSS and gradients
- 🚫 **Can't vote for own project**
- ✅ **One-time voting** - can't change after submission

## Quick Start

### Local Development

1. **Install dependencies**
   ```bash
   mix setup
   ```

2. **Start the server**
   ```bash
   mix phx.server
   ```

3. **Visit** http://localhost:4000

4. **Register teams**: Go to http://localhost:4000/users/register
   - Create 8 accounts (one per project)
   - Each user selects their project
   - Check http://localhost:4000/dev/mailbox for login links

5. **Vote!** After logging in, distribute your 5 votes and click Submit

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions to Fly.io or Railway.

### Quick Deploy to Fly.io

```bash
# Install Fly.io CLI
brew install flyctl

# Login
fly auth login

# Launch (follow prompts, choose PostgreSQL free tier)
fly launch

# Set secrets
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)

# Deploy
fly deploy

# Run migrations and seeds
fly ssh console -C "/app/bin/migrate"
fly ssh console -C '/app/bin/polly eval "Polly.Release.seed()"'
```

Your app will be live at `https://your-app-name.fly.dev`

## The 8 Projects

1. CRM - Smart Notifications & Bonus
2. RB - Tournament Hub
3. RB - Kambi Mosaic
4. RB - Trending Bet
5. CRM - Worldcup
6. CRM - Conversational AI
7. RG - Brave new world (AI-led lobby mgt incl boosting)
8. RG - New player casino recs model (soft Game)

## Tech Stack

- **Phoenix 1.8** with LiveView
- **Elixir** 
- **PostgreSQL**
- **Tailwind CSS**
- **Phoenix PubSub** for real-time updates

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix

