defmodule Polly.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :count, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:user_id])
    create index(:votes, [:project_id])
    create unique_index(:votes, [:user_id, :project_id])
  end
end
