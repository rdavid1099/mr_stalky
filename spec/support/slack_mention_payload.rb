module SlackMentionPayload
  def payload(injection = {})
    {
      token: "ZZZZZZWSxiZZZ2yIvs3peJ",
      team_id: "T061EG9R6",
      api_app_id: "A0MDYCDME",
      event: {
        type: "app_mention",
        user: "U061F7AUR",
        text: "<@U0LAN0Z89> whatsup",
        ts: "1515449522.000016",
        channel: "C0LAN2Q65",
        event_ts: "1515449522000016",
      },
      type: "event_callback",
      event_id: "Ev0LAN670R",
      event_time: 1_515_449_522_000_016,
      authed_users: [
        "U0LAN0Z89",
      ],
    }.merge(injection)
  end
end
