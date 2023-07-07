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

    test "competition periods 2023" do
      assert Date.day_of_week(~D[2023-05-01]) == 1
      assert Date.day_of_week(~D[2023-05-07]) == 7
      competition = competition_fixture()
      assert competition.start_date == ~D[2023-05-01]
      assert competition.end_date == ~D[2023-05-31]
      assert competition.display_name == "May is Bike Month 2023"

      target_periods = [
        %{start_date: ~D[2023-05-01], end_date: ~D[2023-05-07]},
        %{start_date: ~D[2023-05-08], end_date: ~D[2023-05-14]},
        %{start_date: ~D[2023-05-15], end_date: ~D[2023-05-21]},
        %{start_date: ~D[2023-05-22], end_date: ~D[2023-05-28]},
        %{start_date: ~D[2023-05-29], end_date: ~D[2023-05-31]}
      ]

      assert Competitions.competition_periods(competition.start_date, competition.end_date) ==
               target_periods

      assert competition.periods == target_periods
    end

    test "competition periods 2022 with current_competition" do
      fixture = competition_fixture(start_date: ~D[2022-05-01], end_date: ~D[2022-05-31])
      competition = Competitions.current_competition()
      assert fixture == competition

      assert competition.periods == [
               %{start_date: ~D[2022-05-01], end_date: ~D[2022-05-01]},
               %{start_date: ~D[2022-05-02], end_date: ~D[2022-05-08]},
               %{start_date: ~D[2022-05-09], end_date: ~D[2022-05-15]},
               %{start_date: ~D[2022-05-16], end_date: ~D[2022-05-22]},
               %{start_date: ~D[2022-05-23], end_date: ~D[2022-05-29]},
               %{start_date: ~D[2022-05-30], end_date: ~D[2022-05-31]}
             ]
    end

    test "create_competition/1 with valid data creates a competition" do
      valid_attrs = %{
        slug: "some-slug",
        display_name: "some display_name",
        end_date: ~D[2024-05-31],
        start_date: ~D[2024-05-01]
      }

      assert {:ok, %Competition{} = competition} = Competitions.create_competition(valid_attrs)
      assert competition.display_name == "some display_name"
      assert competition.end_date == ~D[2024-05-31]
      assert competition.start_date == ~D[2024-05-01]
      assert competition.slug == "some-slug"
      periods = competition.periods
      assert List.first(periods) == %{start_date: ~D[2024-05-01], end_date: ~D[2024-05-05]}
      assert List.last(periods) == %{start_date: ~D[2024-05-27], end_date: ~D[2024-05-31]}
    end

    test "create_competition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_competition(@invalid_attrs)
    end

    test "update_competition/2 with valid data updates the competition" do
      competition = competition_fixture()

      update_attrs = %{
        display_name: "some updated display_name",
        end_date: ~D[2023-05-01],
        start_date: ~D[2023-05-31]
      }

      assert {:ok, %Competition{} = competition} =
               Competitions.update_competition(competition, update_attrs)

      assert competition.display_name == "some updated display_name"
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

    test "create_competition_participants/1 creates competition_participants for the competition" do
      competition = competition_fixture()
      MayIsBikeMonth.ParticipantsFixtures.participant_fixture()
      Competitions.create_competition_participants(competition)

      assert length(MayIsBikeMonth.CompetitionParticipants.list_competition_participants()) == 1
    end
  end
end
