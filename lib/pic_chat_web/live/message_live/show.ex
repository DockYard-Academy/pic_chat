defmodule PicChatWeb.MessageLive.Show do
  use PicChatWeb, :live_view

  alias PicChat.Chat

  @impl true
  def mount(_params, _session, socket) do
    {:ok, allow_upload(socket, :picture, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:message, Chat.get_message!(id))}
  end

  defp page_title(:show), do: "Show Message"
  defp page_title(:edit), do: "Edit Message"
end
