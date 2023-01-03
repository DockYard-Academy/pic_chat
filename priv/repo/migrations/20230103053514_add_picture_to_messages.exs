defmodule PicChat.Repo.Migrations.AddPictureToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :picture, :string
    end
  end
end
