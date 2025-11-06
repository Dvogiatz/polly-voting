# Deploy to Render - Step by Step

This guide will help you deploy the in-memory Polly voting app to Render.

## Prerequisites

- GitHub account
- Render account (free tier available at https://render.com)

## Step 1: Prepare the Repository

1. **Initialize git (if not already done):**
```bash
cd /Users/dv-vaix/Documents/Vaix/polly
git init
git add .
git commit -m "Initial commit - In-memory voting app"
```

2. **Create a GitHub repository:**
   - Go to https://github.com/new
   - Create a new repository (e.g., `polly-voting`)
   - **Do NOT** initialize with README, .gitignore, or license

3. **Push to GitHub:**
```bash
git remote add origin https://github.com/YOUR_USERNAME/polly-voting.git
git branch -M main
git push -u origin main
```

## Step 2: Deploy to Render

1. **Go to Render Dashboard:**
   - Visit https://dashboard.render.com
   - Sign up or log in

2. **Create New Web Service:**
   - Click "New +" button
   - Select "Web Service"
   - Click "Connect a repository" or "Configure account" to connect GitHub
   - Select your `polly-voting` repository

3. **Configure the Service:**
   
   **Basic Settings:**
   - **Name:** `polly-voting` (or your preferred name)
   - **Region:** Oregon (US West) or closest to you
   - **Branch:** `main`
   - **Root Directory:** (leave blank)
   - **Runtime:** Elixir

   **Build & Deploy:**
   - **Build Command:**
     ```
     mix deps.get --only prod && mix assets.deploy && mix phx.digest
     ```
   
   - **Start Command:**
     ```
     mix phx.server
     ```

   **Environment Variables:**
   Add these in the "Environment" section:
   
   | Key | Value |
   |-----|-------|
   | `MIX_ENV` | `prod` |
   | `SECRET_KEY_BASE` | (Click "Generate" - Render will auto-generate) |
   | `DATABASE_URL` | `ecto://localhost/polly_dev` |
   | `PHX_SERVER` | `true` |

   **Instance Type:**
   - Select **Free** tier

4. **Deploy:**
   - Click "Create Web Service"
   - Render will automatically build and deploy your app
   - This may take 5-10 minutes for the first deployment

## Step 3: Access Your App

Once deployed, you'll get a URL like:
```
https://polly-voting.onrender.com
```

## Test Credentials

Share these with your hackathon teams:

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

## Important Notes

⚠️ **Free Tier Limitations:**
- Service spins down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds
- **All votes are lost when service restarts** (in-memory only)

✅ **For Active Hackathon:**
- Keep a browser tab open to prevent spin-down
- Or upgrade to paid tier ($7/month) for always-on service

## Troubleshooting

### Build Fails

Check the build logs in Render dashboard. Common issues:
- Missing environment variables
- Compilation errors (should be caught locally first)

### App Won't Start

1. Check the logs in Render dashboard
2. Verify all environment variables are set
3. Ensure `PHX_SERVER=true` is set

### Can't Access App

1. Check if service is running (not spinning down)
2. Verify the URL is correct
3. Check Render status page

## Updating the App

To deploy changes:

```bash
git add .
git commit -m "Your update message"
git push origin main
```

Render will automatically detect the push and redeploy.

## Alternative: Blueprint Deployment

Alternatively, you can use the included `render.yaml` file for one-click deployment:

1. In Render dashboard, click "New +"
2. Select "Blueprint"
3. Connect your GitHub repo
4. Render will auto-configure from `render.yaml`

---

**Quick Start Commands:**

```bash
# 1. Initialize and commit
git init
git add .
git commit -m "Initial commit"

# 2. Create GitHub repo and push
git remote add origin https://github.com/YOUR_USERNAME/polly-voting.git
git push -u origin main

# 3. Then follow Render dashboard setup above
```
