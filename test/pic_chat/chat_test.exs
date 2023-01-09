defmodule PicChat.ChatTest do
  use PicChat.DataCase

  alias PicChat.Chat

  describe "messages" do
    alias PicChat.Chat.Message

    import PicChat.ChatFixtures

    @invalid_attrs %{content: nil, from: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "list_messages/0 returns paginated messages" do
      messages =
        Enum.map(1..100, fn _ ->
          message_fixture()
        end)
        |> Enum.reverse()

      assert Chat.list_messages(per_page: 10, page: 1) == Enum.slice(messages, 0..9)
      assert Chat.list_messages(per_page: 10, page: 2) == Enum.slice(messages, 10..19)
      assert Chat.list_messages(per_page: 10, page: 5) == Enum.slice(messages, 40..49)
      assert Chat.list_messages(per_page: 10, page: 9) == Enum.slice(messages, 80..89)
      assert Chat.list_messages(per_page: 10, page: 10) == Enum.slice(messages, 90..99)
      assert Chat.list_messages(per_page: 10, page: 11) == []
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{content: "some content", from: "some from", picture: "images/picture_url"}

      assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
      assert message.content == "some content"
      assert message.from == "some from"
      assert message.picture == "images/picture_url"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content", from: "some updated from"}

      assert {:ok, %Message{} = message} = Chat.update_message(message, update_attrs)
      assert message.content == "some updated content"
      assert message.from == "some updated from"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
