defmodule PicChatWeb.MessageLive.Index do
  use PicChatWeb, :live_view

  alias PicChat.Chat
  alias PicChat.Chat.Message

  @per_page 20

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PicChatWeb.Endpoint.subscribe("messages")
    end

    {:ok,
     socket
     |> assign(:messages, Chat.list_messages(page: 1, per_page: @per_page))
     |> assign(:page, 1)
     |> assign(:all_loaded, false)
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
  def handle_info(%{topic: "messages", event: "create_message", payload: message}, socket) do
    {:noreply,
     socket
     |> assign(:messages, [message | socket.assigns.messages])
     |> push_event("highlight", %{id: message.id})}
  end

  @impl true
  def handle_info(
        %{topic: "messages", event: "update_message", payload: updated_message},
        socket
      ) do
    updated_messages =
      Enum.map(socket.assigns.messages, fn message ->
        if message.id == updated_message.id do
          updated_message
        else
          message
        end
      end)

    {:noreply, socket |> assign(:messages, updated_messages)}
  end

  @impl true
  def handle_info(%{topic: "messages", event: "delete_message", payload: id}, socket) do
    {:noreply,
     socket
     |> assign(:messages, Enum.reject(socket.assigns.messages, &(&1.id == String.to_integer(id))))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Chat.get_message!(id)
    {:ok, _} = Chat.delete_message(message)

    PicChatWeb.Endpoint.broadcast("messages", "delete_message", id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("load-more", _params, %{assigns: %{all_loaded: true}} = socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    next_page = socket.assigns.page + 1
    messages = Chat.list_messages(page: next_page, per_page: @per_page)

    {:noreply,
     socket
     |> assign(:messages, socket.assigns.messages ++ messages)
     |> assign(:page, next_page)
     |> assign(:all_loaded, Enum.count(messages) < @per_page)}
  end
end
