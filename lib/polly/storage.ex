defmodule Polly.Storage do
  @moduledoc """
  In-memory storage for projects and votes (no database required).
  """
  use Agent

  @projects [
    %{id: 1, name: "CRM - Smart Notifications & Bonus", description: "Smart notification system with bonus features"},
    %{id: 2, name: "RB - Tournament Hub", description: "Centralized tournament management platform"},
    %{id: 3, name: "RB - Kambi Mosaic", description: "Kambi integration mosaic view"},
    %{id: 4, name: "RB - Trending Bet", description: "Trending betting analysis and recommendations"},
    %{id: 5, name: "CRM - Worldcup", description: "World Cup customer relationship features"},
    %{id: 6, name: "CRM - Conversational AI", description: "AI-powered conversational interfaces for CRM"},
    %{id: 7, name: "RG - Brave new world (AI-led lobby mgt incl boosting)", description: "AI-driven lobby management with boosting capabilities"},
    %{id: 8, name: "RG - New player casino recs model (soft Game)", description: "Casino recommendation model for new players"}
  ]

  @users [
    %{id: "user1", email: "team1@test.com", project_id: 1},
    %{id: "user2", email: "team2@test.com", project_id: 2},
    %{id: "user3", email: "team3@test.com", project_id: 3},
    %{id: "user4", email: "team4@test.com", project_id: 4},
    %{id: "user5", email: "team5@test.com", project_id: 5},
    %{id: "user6", email: "team6@test.com", project_id: 6},
    %{id: "user7", email: "team7@test.com", project_id: 7},
    %{id: "user8", email: "team8@test.com", project_id: 8}
  ]

  def start_link(_opts) do
    Agent.start_link(fn -> %{votes: %{}} end, name: __MODULE__)
  end

  # Projects
  def list_projects do
    @projects
  end

  def get_project(id) do
    Enum.find(@projects, &(&1.id == id))
  end

  # Users
  def get_user_by_email(email) do
    Enum.find(@users, &(&1.email == email))
  end

  def get_user(id) do
    Enum.find(@users, &(&1.id == id))
  end

  # Votes - stored as %{user_id => %{project_id => count}}
  def cast_votes(user_id, votes_map) do
    Agent.update(__MODULE__, fn state ->
      %{state | votes: Map.put(state.votes, user_id, votes_map)}
    end)
    :ok
  end

  def get_user_votes(user_id) do
    votes = Agent.get(__MODULE__, fn state ->
      Map.get(state.votes, user_id, %{})
    end)

    votes
    |> Enum.map(fn {project_id, count} ->
      project = get_project(project_id)
      %{project_id: project_id, project_name: project.name, count: count}
    end)
  end

  def get_user_total_votes(user_id) do
    Agent.get(__MODULE__, fn state ->
      state.votes
      |> Map.get(user_id, %{})
      |> Map.values()
      |> Enum.sum()
    end)
  end

  def list_projects_with_votes do
    all_votes = Agent.get(__MODULE__, fn state -> state.votes end)

    # Calculate vote counts per project
    vote_counts =
      all_votes
      |> Enum.flat_map(fn {_user_id, votes} -> votes end)
      |> Enum.reduce(%{}, fn {project_id, count}, acc ->
        Map.update(acc, project_id, count, &(&1 + count))
      end)

    @projects
    |> Enum.map(fn project ->
      Map.put(project, :vote_count, Map.get(vote_counts, project.id, 0))
    end)
    |> Enum.sort_by(&{-&1.vote_count, &1.name})
  end

  def get_project_votes(project_id) do
    all_votes = Agent.get(__MODULE__, fn state -> state.votes end)

    all_votes
    |> Enum.filter(fn {_user_id, votes} ->
      Map.has_key?(votes, project_id)
    end)
    |> Enum.map(fn {user_id, votes} ->
      user = get_user(user_id)
      user_project = get_project(user.project_id)

      %{
        count: votes[project_id],
        user_email: user.email,
        user_project: user_project.name
      }
    end)
  end

  def list_votable_projects(user) do
    @projects
    |> Enum.reject(&(&1.id == user.project_id))
  end

  def reset_all_votes do
    Agent.update(__MODULE__, fn state ->
      %{state | votes: %{}}
    end)
  end
end
