# Create test users for quick testing
# Run with: mix run priv/repo/create_test_users.exs

import Ecto.Query

alias Polly.Repo
alias Polly.Accounts.User
alias Polly.Hackathon

# Get all projects
projects = Hackathon.list_projects()

# Create 8 test users (one for each project)
test_users = [
  %{email: "team1@test.com", project_id: Enum.at(projects, 0).id},
  %{email: "team2@test.com", project_id: Enum.at(projects, 1).id},
  %{email: "team3@test.com", project_id: Enum.at(projects, 2).id},
  %{email: "team4@test.com", project_id: Enum.at(projects, 3).id},
  %{email: "team5@test.com", project_id: Enum.at(projects, 4).id},
  %{email: "team6@test.com", project_id: Enum.at(projects, 5).id},
  %{email: "team7@test.com", project_id: Enum.at(projects, 6).id},
  %{email: "team8@test.com", project_id: Enum.at(projects, 7).id}
]

# Delete existing test users
Repo.delete_all(from u in User, where: like(u.email, "%@test.com"))

# Create users
Enum.each(test_users, fn user_attrs ->
  %User{}
  |> User.registration_changeset(user_attrs)
  |> Repo.insert!()
  |> IO.inspect(label: "Created user")
end)

IO.puts("\n✅ Created 8 test users!")
IO.puts("\nTo login, go to http://localhost:4000/users/log-in")
IO.puts("Enter any of these emails:")
Enum.each(test_users, fn user -> IO.puts("  - #{user.email}") end)
IO.puts("\nClick 'Log in with email' and check http://localhost:4000/dev/mailbox for the magic link!")
