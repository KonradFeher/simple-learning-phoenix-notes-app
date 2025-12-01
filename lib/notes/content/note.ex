defmodule Notes.Content.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :title, :string
    field :content, :string
    field :public, :boolean, default: false
    field :type, Ecto.Enum, values: [:plaintext, :markdown, :checklist]
    field :user_id, :id

    many_to_many :authors, Notes.Accounts.User, join_through: "notes_authors"
    many_to_many :sharees, Notes.Accounts.User, join_through: "notes_sharees"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs, user_scope) do
    note
    |> cast(attrs, [:title, :content, :public, :type])
    |> validate_required([:title, :content, :public, :type])
    |> put_change(:user_id, user_scope.user.id)
  end
end
