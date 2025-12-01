defmodule Notes.Repo.Migrations.CreateUserNoteJoinTables do
  use Ecto.Migration

  def change do
    create table(:notes_authors) do
      add :user_id, references(:users)
      add :note_id, references(:notes)
    end

    create table(:notes_sharees) do
      add :user_id, references(:users)
      add :note_id, references(:notes)
    end
  end
end
