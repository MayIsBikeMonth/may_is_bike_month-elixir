defmodule MayIsBikeMonth.Competitions.Competition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competitions" do
    field :display_name, :string
    field :end_date, :date
    field :start_date, :date

    timestamps()
  end

  @doc false
  def changeset(competition, attrs) do
    competition
    |> cast(attrs, [:display_name, :start_date, :end_date])
    |> validate_required([:display_name, :start_date, :end_date])
  end
end
