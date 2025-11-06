defmodule Polly.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Polly.Accounts.User

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    case Polly.Storage.get_user_by_email(email) do
      nil -> nil
      user ->
        # Convert to User struct for compatibility
        struct(User, Map.put(user, :project, Polly.Storage.get_project(user.project_id)))
    end
  end

  # Hardcoded test credentials (for internal temporary deployment only)
  @test_credentials %{
    "admin@test.com" => "pass0",
    "team1@test.com" => "pass1",
    "team2@test.com" => "pass2",
    "team3@test.com" => "pass3",
    "team4@test.com" => "pass4",
    "team5@test.com" => "pass5",
    "team6@test.com" => "pass6",
    "team7@test.com" => "pass7",
    "team8@test.com" => "pass8"
  }

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    # Check hardcoded test credentials
    if Map.has_key?(@test_credentials, email) and @test_credentials[email] == password do
      get_user_by_email(email)
    else
      nil
    end
  end

  @doc """
  Gets a single user.

  Raises if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (error)

  """
  def get_user!(id) do
    case Polly.Storage.get_user(id) do
      nil -> raise "User not found"
      user -> struct(User, Map.put(user, :project, Polly.Storage.get_project(user.project_id)))
    end
  end
end
