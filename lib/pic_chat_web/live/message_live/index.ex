defmodule PicChatWeb.MessageLive.Index do
  use PicChatWeb, :live_view

  alias PicChat.Chat
  alias PicChat.Chat.Message

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PicChatWeb.Endpoint.subscribe("messages")
    end

    {:ok,
     socket
     |> assign(:messages, list_messages())
     |> allow_upload(:picture, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Message")
    |> assign(:message, Chat.get_message!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message")
    |> assign(:message, %Message{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Messages")
    |> assign(:message, nil)
  end

  @impl true
  def handle_info(%{topic: "messages", event: _, payload: _}, socket) do
    {:noreply, assign(socket, :messages, list_messages())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Chat.get_message!(id)
    {:ok, _} = Chat.delete_message(message)

    PicChatWeb.Endpoint.broadcast("messages", "delete_message", id)

    {:noreply, assign(socket, :messages, list_messages())}
  end

  defp list_messages do
    Chat.list_messages()
  end
end
