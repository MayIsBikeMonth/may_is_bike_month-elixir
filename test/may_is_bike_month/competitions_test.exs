defmodule MayIsBikeMonth.CompetitionsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.Competitions

  describe "competitions" do
    alias MayIsBikeMonth.Competitions.Competition

    import MayIsBikeMonth.CompetitionsFixtures

    @invalid_attrs %{display_name: nil, end_date: nil, start_date: nil}

    test "list_competitions/0 returns all competitions" do
      competition = competition_fixture()
      assert Competitions.list_competitions() == [competition]
    end

    test "get_competition!/1 returns the competition with given id" do
      competition = competition_fixture()
      assert Competitions.get_competition!(competition.id) == competition
    end

    test "create_competition/1 with valid data creates a competition" do
      valid_attrs = %{
        display_name: "some display_name",
        end_date: ~D[2023-06-30],
        start_date: ~D[2023-06-30]
      }

      assert {:ok, %Competition{} = competition} = Competitions.create_competition(valid_attrs)
      assert competition.display_name == "some display_name"
      assert competition.end_date == ~D[2023-06-30]
      assert competition.start_date == ~D[2023-06-30]
    end

    test "create_competition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_competition(@invalid_attrs)
    end

    test "update_competition/2 with valid data updates the competition" do
      competition = competition_fixture()

      update_attrs = %{
        display_name: "some updated display_name",
        end_date: ~D[2023-07-01],
        start_date: ~D[2023-07-01]
      }

      assert {:ok, %Competition{} = competition} =
               Competitions.update_competition(competition, update_attrs)

      assert competition.display_name == "some updated display_name"
      assert competition.end_date == ~D[2023-07-01]
      assert competition.start_date == ~D[2023-07-01]
    end

    test "update_competition/2 with invalid data returns error changeset" do
      competition = competition_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Competitions.update_competition(competition, @invalid_attrs)

      assert competition == Competitions.get_competition!(competition.id)
    end

    test "delete_competition/1 deletes the competition" do
      competition = competition_fixture()
      assert {:ok, %Competition{}} = Competitions.delete_competition(competition)
      assert_raise Ecto.NoResultsError, fn -> Competitions.get_competition!(competition.id) end
    end

    test "change_competition/1 returns a competition changeset" do
      competition = competition_fixture()
      assert %Ecto.Changeset{} = Competitions.change_competition(competition)
    end
  end
end
