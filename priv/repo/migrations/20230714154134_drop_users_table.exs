defmodule MayIsBikeMonth.Repo.Migrations.DropUsersTable do
  use Ecto.Migration

  def change do
    drop table(:users_tokens)
    drop table(:users)
  end
end
