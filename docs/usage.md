# Usage

## APNS

Sending:

    alias Cartel.Pusher.Apns
    alias Cartel.Message.Apns, as: Message
    alias Message.Item

    Apns.send("appid", :sandbox, %Message{
      items: [
        %Item{
          id: Item.device_token,
          data: "devicetoken"
        },
        %Item{
          id: Item.payload,
          data: %{aps: %{alert: "Hello"}}
        }
      ]
    })

Consuming feedback:

    alias Cartel.Pusher.Apns

    Apns.feedback("appid", Apns, :sandbox)

## APNS HTTP/2 (experimental)

Sending notifications:

    alias Cartel.Pusher.Apns2
    alias Cartel.Message.Apns2, as: Message

    Apns2.send("appid", :sandbox, %Message{
      token: "devicetoken",
      payload: %{aps: %{alert: "Hello"}}
    })

## GCM

TBD

## WNS

TBD
