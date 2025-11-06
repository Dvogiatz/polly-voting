defmodule Polly.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
