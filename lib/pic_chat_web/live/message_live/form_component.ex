defmodule PicChatWeb.MessageLive.FormComponent do
  use PicChatWeb, :live_component

  alias PicChat.Chat

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Chat.change_message(message)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> Chat.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :picture, fn %{path: path}, _entry ->
        file_name = Path.basename(path)
        File.cp!(path, "priv/static/images/#{file_name}")

        {:ok, Routes.static_path(socket, "/images/#{file_name}")}
      end)

    message_params = Map.put(message_params, "picture", List.first(uploaded_files))

    save_message(socket, socket.assigns.action, message_params)
  end

  defp save_message(socket, :edit, message_params) do
    case Chat.update_message(socket.assigns.message, message_params) do
      {:ok, message} ->
        PicChatWeb.Endpoint.broadcast("messages", "update_message", message)

        {:noreply,
         socket
         |> put_flash(:info, "Message updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_message(socket, :new, message_params) do
    case Chat.create_message(message_params) do
      {:ok, message} ->
        PicChatWeb.Endpoint.broadcast("messages", "create_message", message)

        {:noreply,
         socket
         |> put_flash(:info, "Message created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
