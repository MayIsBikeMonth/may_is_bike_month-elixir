defmodule MayIsBikeMonth.Participants.ParticipantAdmin do
  def widgets(_schema, _conn) do
    user_count = MayIsBikeMonth.Participants.count_participants()

    competition_participants_count =
      MayIsBikeMonth.CompetitionParticipants.count_competition_participants()

    [
      %{
        type: "tidbit",
        title: "Users",
        content: "#{user_count}",
        icon: "rocket",
        order: 1,
        width: 6
      },
      %{
        type: "tidbit",
        title: "Competition Participants",
        content: "#{competition_participants_count}",
        icon: "rocket",
        order: 2,
        width: 6
      }
    ]
  end
end
