# Usage

## APNS

Sending notifications:

    alias Cartel.Pusher.Apns2
    alias Cartel.Message.Apns2, as: Message

    Cartel.Dealer.send("com.mydomain1.myapp1", Apns2, :sandbox, %Message{
      token: "device token",
      payload: %{aps: %{alert: "Hello"}}
    })

## APNS (legacy)

Sending:

    alias Cartel.Pusher.Apns
    alias Cartel.Message.Apns, as: Message
    alias Message.Item

    Cartel.Pusher.send("appid", Apns, :sandbox, %Message{
      items: [
        %Item{
          id: Item.device_token,
          data: "device token"
        },
        %Item{
          id: Item.payload,
          data: %{aps: %{alert: "Hello"}}
        }
      ]
    })

Consuming feedback:

    alias Cartel.Pusher.Apns
    Cartel.Pusher.feedback("appid", Apns, :sandbox)

## GCM

TBD

## WNS

TBD
