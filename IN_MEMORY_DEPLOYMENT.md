# In-Memory Deployment Guide

## Overview

The Polly voting app has been converted to run **entirely in-memory** with no database dependencies. This allows for rapid deployment (a few minutes) for temporary hackathon voting events.

## Architecture Changes

### What Was Removed
- ❌ PostgreSQL database dependency
- ❌ Ecto queries and changesets (except User struct for compatibility)
- ❌ Token-based authentication
- ❌ Magic link login
- ❌ Email-based registration
- ❌ Password reset/change functionality

### What Was Added
- ✅ `Polly.Storage` - Agent-based in-memory storage module
- ✅ Session-based authentication (simple session[:user_id])
- ✅ Hardcoded test credentials
- ✅ In-memory vote tracking with real-time PubSub updates

## Test Credentials

8 teams with hardcoded credentials:

| Team | Email | Password |
|------|-------|----------|
| Team 1 | team1@test.com | pass1 |
| Team 2 | team2@test.com | pass2 |
| Team 3 | team3@test.com | pass3 |
| Team 4 | team4@test.com | pass4 |
| Team 5 | team5@test.com | pass5 |
| Team 6 | team6@test.com | pass6 |
| Team 7 | team7@test.com | pass7 |
| Team 8 | team8@test.com | pass8 |

## Projects

8 hardcoded projects are pre-loaded in memory:

1. EcoTrack - AI-powered carbon footprint tracking app
2. HealthHub - Telemedicine platform connecting patients and doctors
3. LearnLoop - Adaptive learning platform with gamification
4. FoodShare - Community food waste reduction marketplace
5. CityPulse - Real-time urban infrastructure monitoring
6. WorkWise - Remote team productivity and wellness tracker
7. SafeHome - IoT-based home security system
8. GreenRide - Electric vehicle charging network optimizer

## Storage Module

`lib/polly/storage.ex` manages all in-memory state using an Elixir Agent:

- **Users**: 8 hardcoded users mapped to projects 1-8
- **Projects**: 8 hardcoded projects  
- **Votes**: Dynamic map structure `%{user_id => %{project_id => count}}`

### Key Functions

- `cast_votes(user, votes)` - Update votes for a user
- `get_user_votes(user_id)` - Get all votes cast by user
- `get_user_total_votes(user_id)` - Get total vote count for user
- `list_projects_with_votes()` - Get all projects with vote counts
- `get_project_votes(project_id)` - Get total votes for a project
- `list_votable_projects(user_id)` - Get projects user can vote for (excludes own project)
- `reset_all_votes()` - Clear all votes (for testing/restart)

## Deployment

### Quick Start

```bash
# 1. Start the server
mix phx.server

# 2. Visit http://localhost:4000
# 3. Login with any team credentials (e.g., team1@test.com / pass1)
# 4. Cast votes!
```

### Production Deployment

```bash
# 1. Set secret key base
export SECRET_KEY_BASE=$(mix phx.gen.secret)

# 2. Set production port
export PHX_PORT=4000

# 3. Start in production
MIX_ENV=prod mix phx.server
```

## Voting Rules

- Each user gets **5 votes total**
- Votes can be distributed among any projects **except their own**
- Votes update in real-time via Phoenix PubSub
- All changes are lost on server restart (in-memory only)

## Limitations

⚠️ **IMPORTANT**: This is a **temporary deployment mode** for internal use only!

- ❌ No data persistence - all votes lost on restart
- ❌ No password security - credentials hardcoded
- ❌ No registration or user management
- ❌ Not suitable for production or public use
- ❌ Sessions cleared on restart

## Modified Files

Core changes made to support in-memory mode:

1. `lib/polly/storage.ex` - **NEW** - In-memory storage Agent
2. `lib/polly/application.ex` - Added Storage to supervision tree
3. `lib/polly/hackathon.ex` - Replaced all Ecto queries with Storage calls
4. `lib/polly/accounts.ex` - Simplified to hardcoded credentials
5. `lib/polly_web/user_auth.ex` - Session-based auth instead of tokens
6. `lib/polly_web/controllers/user_session_controller.ex` - Email/password login only
7. `lib/polly_web/live/user_live/login.ex` - Simplified login UI
8. `lib/polly_web/live/voting_live.ex` - Bug fixes for vote submission

## Reverting to Database Mode

To restore database functionality:

1. Check out the original code before in-memory changes
2. Run `mix ecto.setup` to create database
3. Seed with real data using `priv/repo/seeds.exs`

## Support

For the temporary hackathon deployment, contact the development team if you encounter issues.

---

**Last Updated**: January 2025  
**Mode**: In-Memory Only (No Database)
