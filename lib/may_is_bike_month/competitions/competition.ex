defmodule MayIsBikeMonth.Competitions.Competition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competitions" do
    field :display_name, :string
    field :end_date, :date
    field :start_date, :date
    field :slug, :string
    field :periods, {:array, :map}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(competition, attrs) do
    competition
    |> cast(attrs, [:display_name, :slug, :start_date, :end_date])
    |> validate_required([:slug, :start_date, :end_date])
    |> with_periods()
    |> with_display_name()
  end

  defp with_periods(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    periods =
      if start_date && end_date do
        MayIsBikeMonth.Competitions.competition_periods(start_date, end_date)
      else
        []
      end

    put_change(changeset, :periods, periods)
  end

  defp with_display_name(changeset) do
    display_name = get_field(changeset, :display_name)
    slug = get_field(changeset, :slug)
    put_change(changeset, :display_name, display_name || "May is Bike Month #{slug}")
  end
end
