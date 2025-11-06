defmodule Polly.Hackathon.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "votes" do
    field :count, :integer, default: 1

    belongs_to :user, Polly.Accounts.User
    belongs_to :project, Polly.Hackathon.Project, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:count, :user_id, :project_id])
    |> validate_required([:count, :user_id, :project_id])
    |> validate_number(:count, greater_than: 0, less_than_or_equal_to: 5)
    |> unique_constraint([:user_id, :project_id])
  end
end
