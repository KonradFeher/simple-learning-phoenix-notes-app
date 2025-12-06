defmodule Notes.ContentTest do
  use Notes.DataCase

  alias Notes.Content

  describe "notes" do
    alias Notes.Content.Note

    import Notes.AccountsFixtures, only: [user_scope_fixture: 0]
    import Notes.ContentFixtures

    @invalid_attrs %{public: nil, type: nil, title: nil, content: nil}

    test "create_note/2 with valid data creates a note" do
      valid_attrs = %{public: true, type: :plaintext, title: "some title", content: "some content"}
      scope = user_scope_fixture()

      assert {:ok, %Note{} = note} = Content.create_note(scope, valid_attrs)
      assert note.public == true
      assert note.type == :plaintext
      assert note.title == "some title"
      assert note.content == "some content"
      assert note.user_id == scope.user.id
    end

    test "create_note/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.create_note(scope, @invalid_attrs)
    end

    test "update_note/3 with valid data updates the note" do
      scope = user_scope_fixture()
      note = note_fixture(scope)
      update_attrs = %{public: false, type: :markdown, title: "some updated title", content: "some updated content"}

      assert {:ok, %Note{} = note} = Content.update_note(scope, note, update_attrs)
      assert note.public == false
      assert note.type == :markdown
      assert note.title == "some updated title"
      assert note.content == "some updated content"
    end
  end
end
