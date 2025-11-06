# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Polly.Repo.insert!(%Polly.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Polly.Repo
alias Polly.Hackathon.Project

# Clear existing data
Repo.delete_all(Project)

# Insert the 8 hackathon projects
projects = [
  %{
    name: "CRM - Smart Notifications & Bonus",
    description: "Smart notification system with bonus features"
  },
  %{
    name: "RB - Tournament Hub",
    description: "Centralized tournament management platform"
  },
  %{
    name: "RB - Kambi Mosaic",
    description: "Kambi integration mosaic view"
  },
  %{
    name: "RB - Trending Bet",
    description: "Trending betting analysis and recommendations"
  },
  %{
    name: "CRM - Worldcup",
    description: "World Cup customer relationship features"
  },
  %{
    name: "CRM - Conversational AI",
    description: "AI-powered conversational interfaces for CRM"
  },
  %{
    name: "RG - Brave new world (AI-led lobby mgt incl boosting)",
    description: "AI-driven lobby management with boosting capabilities"
  },
  %{
    name: "RG - New player casino recs model (soft Game)",
    description: "Casino recommendation model for new players"
  }
]

Enum.each(projects, fn project_attrs ->
  %Project{}
  |> Project.changeset(project_attrs)
  |> Repo.insert!()
end)

IO.puts("Seeded #{length(projects)} projects successfully!")
