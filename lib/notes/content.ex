defmodule Notes.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Notes.Repo

  alias Notes.Content.Note
  alias Notes.Accounts.Scope
  alias Notes.Accounts.User

  @doc """
  Subscribes to scoped notifications about any note changes.

  The broadcasted messages match the pattern:

    * {:created, %Note{}}
    * {:updated, %Note{}}
    * {:deleted, %Note{}}

  """
  def subscribe_notes(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Notes.PubSub, "user:#{key}:notes")
  end

  defp broadcast_note(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Notes.PubSub, "user:#{key}:notes", message)
  end

  @doc """
  Returns the list of notes.

  ## Examples

      iex> list_notes(scope)
      [%Note{}, ...]

  """
  def list_notes(%Scope{} = scope) do
    query = from n in Note,
              distinct: true,
              left_join: a in assoc(n, :authors),
              left_join: s in assoc(n, :sharees),
              where: n.user_id == ^scope.user.id
                or a.id == ^scope.user.id
                or s.id == ^scope.user.id
                or n.public == true,
              order_by: n.title
    Repo.all(query) |> Repo.preload([:authors, :sharees])
  end

  def list_notes(nil) do
    Repo.all_by(Note, public: true)
  end

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(scope, 123)
      %Note{}

      iex> get_note!(scope, 456)
      ** (Ecto.NoResultsError)

  """

  def get_note!(%Scope{} = scope, id) do
    note =
      Note
      |> Repo.get!(id)
      |> Repo.preload([:authors, :sharees])
    if allowed_to_view?(note, scope.user.id) do
      note
    else
      {:error, :forbidden}
    end
  end

  def get_note!(nil, id) do
    note =
      Note
      |> Repo.get!(id)
      |> Repo.preload([:authors, :sharees])
    if note.public do
      note
    else
      {:error, :forbidden}
    end
  end

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(scope, %{field: value})
      {:ok, %Note{}}

      iex> create_note(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(%Scope{} = scope, attrs) do
    with {:ok, note = %Note{}} <-
           %Note{}
           |> Note.changeset(attrs)
           |> Ecto.Changeset.change(%{user_id: scope.user.id})
           |> Repo.insert() do
      broadcast_note(scope, {:created, note})
      {:ok, note}
    end
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(scope, note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(scope, note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Scope{} = scope, %Note{} = note, attrs) do
    if not allowed_to_modify?(note, scope.user.id) do
      {:error, :forbidden}
    else
      with {:ok, note = %Note{}} <-
            note
            |> Note.changeset(attrs)
            |> Repo.update() do
        broadcast_note(scope, {:updated, note})
        {:ok, note}
      end
    end
  end

  @doc """
  Deletes a note.

  ## Examples

      iex> delete_note(scope, note)
      {:ok, %Note{}}

      iex> delete_note(scope, note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Scope{} = scope, %Note{} = note) do
    true = note.user_id == scope.user.id

    with {:ok, note = %Note{}} <-
           Repo.delete(note) do
      broadcast_note(scope, {:deleted, note})
      {:ok, note}
    end
  end

  @doc """
  Adds an author to a Note.
  """
  def add_author(note_id, new_author_id, acting_user_id) do
    note =
      Note
      |> Repo.get!(note_id)
      |> Repo.preload(:authors)

    if not allowed_to_modify?(note, acting_user_id) do
      {:error, :forbidden}
    else
      user = Repo.get!(User, new_author_id)

      changeset =
        note
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:authors, note.authors ++ [user])

      Repo.update(changeset)
    end
  end

  @doc """
  Removes an author from a Note.
  """
  def remove_author(note_id, author_id, acting_user_id) do
    note =
      Note
      |> Repo.get!(note_id)
      |> Repo.preload(:authors)

    if note.user_id != acting_user_id, do: {:error, :forbidden}

    author_id = String.to_integer(author_id)
    new_authors = Enum.reject(note.authors, &(&1.id == author_id))

    changeset =
      note
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:authors, IO.inspect(new_authors))

    Repo.update(changeset)
  end


  @doc """
  Adds a sharee to a Note.
  """
  def add_sharee(note_id, new_sharee_id, acting_user_id) do
    note =
      Note
      |> Repo.get!(note_id)
      |> Repo.preload(:sharees)

    if not allowed_to_modify?(note, acting_user_id), do: {:error, :forbidden}

    user = Repo.get!(User, new_sharee_id)

    changeset =
      note
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:sharees, note.sharees ++ [user])

    Repo.update(changeset)
  end

  @doc """
  Removes a sharee from a Note.
  """
  def remove_sharee(note_id, sharee_id, acting_user_id) do
    note =
      Note
      |> Repo.get!(note_id)
      |> Repo.preload(:sharees)

    if not allowed_to_modify?(note, acting_user_id), do: {:error, :forbidden}

    sharee_id = String.to_integer(sharee_id)
    new_sharees = Enum.reject(note.sharees, &(&1.id == sharee_id))

    changeset =
      note
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:sharees, new_sharees)

    Repo.update(changeset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(scope, note)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_note(%Scope{} = scope, %Note{} = note, attrs \\ %{}) do
    if not allowed_to_modify?(note, scope.user.id), do: {:error, :forbidden}

    Note.changeset(note, attrs)
  end

  def allowed_to_modify?(note, user_id) do
    note.user_id == user_id or Enum.any?(note.authors, &(&1.id == user_id))
  end

  def allowed_to_view?(note, user_id) do
    allowed_to_modify?(note, user_id) or note.public or Enum.any?(note.sharees, &(&1.id == user_id))
  end

end
