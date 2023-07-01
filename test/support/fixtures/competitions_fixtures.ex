defmodule MayIsBikeMonth.CompetitionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.Competitions` context.
  """

  @doc """
  Generate a competition.
  """
  def competition_fixture(attrs \\ %{}) do
    {:ok, competition} =
      attrs
      |> Enum.into(%{
        display_name: "some display_name",
        end_date: ~D[2023-06-30],
        start_date: ~D[2023-06-30]
      })
      |> MayIsBikeMonth.Competitions.create_competition()

    competition
  end
end
