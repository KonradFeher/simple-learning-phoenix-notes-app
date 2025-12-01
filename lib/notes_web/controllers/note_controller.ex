defmodule NotesWeb.NoteController do
  use NotesWeb, :controller

  alias Notes.Content
  alias Notes.Content.Note

  def index(conn, _params) do
    notes = Content.list_notes(conn.assigns.current_scope)
    render(conn, :index, notes: notes)
  end

  def new(conn, _params) do
    changeset =
      Content.change_note(conn.assigns.current_scope, %Note{
        user_id: conn.assigns.current_scope.user.id
      })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"note" => note_params}) do
    case Content.create_note(conn.assigns.current_scope, note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note created successfully.")
        |> redirect(to: ~p"/notes/#{note}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    note = Content.get_note!(conn.assigns.current_scope, id)
    render(conn, :show, note: note)
  end

  def edit(conn, %{"id" => id}) do
    note = Content.get_note!(conn.assigns.current_scope, id)
    changeset = Content.change_note(conn.assigns.current_scope, note)
    render(conn, :edit, note: note, changeset: changeset)
  end

  def update(conn, %{"id" => id, "note" => note_params}) do
    note = Content.get_note!(conn.assigns.current_scope, id)

    case Content.update_note(conn.assigns.current_scope, note, note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: ~p"/notes/#{note}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, note: note, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    note = Content.get_note!(conn.assigns.current_scope, id)
    {:ok, _note} = Content.delete_note(conn.assigns.current_scope, note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: ~p"/notes")
  end
end
