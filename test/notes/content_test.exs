defmodule Notes.ContentTest do
  use Notes.DataCase

  alias Notes.Content

  describe "notes" do
    alias Notes.Content.Note

    import Notes.AccountsFixtures, only: [user_scope_fixture: 0]
    import Notes.ContentFixtures

    @invalid_attrs %{public: nil, type: nil, title: nil, content: nil}

    test "list_notes/1 returns all scoped notes" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      note = note_fixture(scope)
      other_note = note_fixture(other_scope)
      assert Content.list_notes(scope) == [note]
      assert Content.list_notes(other_scope) == [other_note]
    end

    test "get_note!/2 returns the note with given id" do
      scope = user_scope_fixture()
      note = note_fixture(scope)
      other_scope = user_scope_fixture()
      assert Content.get_note!(scope, note.id) == note
      assert_raise Ecto.NoResultsError, fn -> Content.get_note!(other_scope, note.id) end
    end

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

    test "update_note/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      note = note_fixture(scope)

      assert_raise MatchError, fn ->
        Content.update_note(other_scope, note, %{})
      end
    end

    test "update_note/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      note = note_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Content.update_note(scope, note, @invalid_attrs)
      assert note == Content.get_note!(scope, note.id)
    end

    test "delete_note/2 deletes the note" do
      scope = user_scope_fixture()
      note = note_fixture(scope)
      assert {:ok, %Note{}} = Content.delete_note(scope, note)
      assert_raise Ecto.NoResultsError, fn -> Content.get_note!(scope, note.id) end
    end

    test "delete_note/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      note = note_fixture(scope)
      assert_raise MatchError, fn -> Content.delete_note(other_scope, note) end
    end

    test "change_note/2 returns a note changeset" do
      scope = user_scope_fixture()
      note = note_fixture(scope)
      assert %Ecto.Changeset{} = Content.change_note(scope, note)
    end
  end
end
