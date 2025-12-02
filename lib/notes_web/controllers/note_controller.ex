defmodule NotesWeb.NoteController do
  use NotesWeb, :controller

  alias Notes.Accounts
  alias Notes.Content
  alias Notes.Content.Note

  def index(conn, _params) do
    notes = Content.list_notes(conn.assigns.current_scope)
    users = Accounts.list_users()

    render(conn, :index, notes: notes, users: users)
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

      {:error, :forbidden} ->
        send_resp(conn, 403, "Forbidden")
    end
  end

  def show(conn, %{"id" => id}) do
    current_scope = conn.assigns.current_scope

    note = Content.get_note!(current_scope, id)
    all_users = Accounts.list_users()
    owner = Enum.find(all_users, &(&1.id == note.user_id))

    selectable_users =
      case current_scope do
        nil ->
          all_users

        %{user: user} ->
          Enum.reject(all_users, &(&1.id == user.id))
      end

    can_modify =
      case current_scope do
        nil ->
          false

      %{user: user} ->
          Content.allowed_to_modify?(note, user.id)
      end

    render(conn, :show,
      note: note,
      owner: owner,
      users: selectable_users,
      can_modify: can_modify
    )
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

      {:error, :forbidden} ->
        send_resp(conn, 403, "Forbidden")
    end
  end

  def delete(conn, %{"id" => id}) do
    note = Content.get_note!(conn.assigns.current_scope, id)
    {:ok, _note} = Content.delete_note(conn.assigns.current_scope, note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: ~p"/notes")
  end

  def add_author(conn, %{"note_id" => id, "user_id" => user_id}) do
    case Content.add_author(id, user_id, conn.assigns.current_scope.user.id) do
      {:ok, _} ->
        redirect(conn, to: ~p"/notes/#{id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def remove_author(conn, %{"note_id" => id, "user_id" => user_id}) do
    case Content.remove_author(id, user_id, conn.assigns.current_scope.user.id) do
      {:ok, _} ->
        redirect(conn, to: ~p"/notes/#{id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def add_sharee(conn, %{"note_id" => id, "user_id" => user_id}) do
    case Content.add_sharee(id, user_id, conn.assigns.current_scope.user.id) do
      {:ok, _} ->
        redirect(conn, to: ~p"/notes/#{id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  def remove_sharee(conn, %{"note_id" => id, "user_id" => user_id}) do
    case Content.remove_sharee(id, user_id, conn.assigns.current_scope.user.id) do
      {:ok, _} ->
        redirect(conn, to: ~p"/notes/#{id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

end
