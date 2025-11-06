defmodule Polly.Hackathon do
  @moduledoc """
  The Hackathon context.
  """

  @doc """
  Returns the list of projects.
  """
  def list_projects do
    Polly.Storage.list_projects()
  end

  @doc """
  Gets a single project.
  """
  def get_project!(id), do: Polly.Storage.get_project(id)

  @doc """
  Returns the list of projects with their vote counts.
  """
  def list_projects_with_votes do
    Polly.Storage.list_projects_with_votes()
  end

  @doc """
  Gets votes for a specific project with user information.
  """
  def get_project_votes(project_id) do
    Polly.Storage.get_project_votes(project_id)
  end

  @doc """
  Gets all votes for a user.
  """
  def get_user_votes(user_id) do
    Polly.Storage.get_user_votes(user_id)
  end

  @doc """
  Gets the total votes a user has cast.
  """
  def get_user_total_votes(user_id) do
    Polly.Storage.get_user_total_votes(user_id)
  end

  @doc """
  Casts votes for a user. Replaces all existing votes.
  """
  def cast_votes(user, votes_params) do
    # Filter out zero votes
    votes_map =
      votes_params
      |> Enum.filter(fn {_project_id, count} -> count > 0 end)
      |> Map.new()

    Polly.Storage.cast_votes(user.id, votes_map)
    {:ok, :votes_cast}
  end

  @doc """
  Returns projects that a user can vote for (all except their own).
  """
  def list_votable_projects(user) do
    Polly.Storage.list_votable_projects(user)
  end
end
