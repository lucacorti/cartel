# Usage

## Common API

All the `Cartel.Pusher` types share a common interface for message sending.
`send/3` for single recipient and `send_bulk/4` for bulk sending.

    alias Cartel.Pusher.<Type>, as: Pusher
    alias Cartel.Message.<Type>, as: Message
    alias Message.Item

    Pusher.send("appid", :sandbox, %Message{
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

    Pusher.send_bulk("appid", :sandbox, ["devicetoken", "devicetoken"], %Message {
      items: [
        %Item{
          id: Item.payload,
          data: %{aps: %{alert: "Hello"}}
        }
      ]
    })


## Apns specific API

`Cartel.Pusher.Apns` allows consuming feedback as a `Stream.t`:

    alias Cartel.Pusher.Apns

    {:ok, stream} = Apns.feedback("appid", :sandbox)
