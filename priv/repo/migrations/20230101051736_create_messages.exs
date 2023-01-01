defmodule PicChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :from, :string

      timestamps()
    end
  end
end
