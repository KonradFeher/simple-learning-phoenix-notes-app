# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Notes.Repo.insert!(%Notes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


alias Notes.Accounts.User
alias Notes.Content.Note
alias Notes.Repo

Repo.delete_all("notes_authors")
Repo.delete_all(Note)
Repo.delete_all(User)

alice = Repo.insert!(%User{
  name: "Alice",
  email: "alice@example.com",
})

bob = Repo.insert!(%User{
  name: "Bobbert",
  email: "bob.20@example.com",
})

john = Repo.insert!(%User{
  name: "John Doe",
  email: "john_doe@example.com",
})

jakab = Repo.insert!(%User{
  name: "Gipsz_Jakab",
  email: "gipsz_j@example.com",
})


noteA1 = Repo.insert!(%Note{title: "Note A 1", content: "Owned by Alice", public: true, type: :plaintext, user_id: alice.id})

noteA2 = Repo.insert!(%Note{title: "Note A 2", content: "Owned by Alice 2", public: false, type: :plaintext, user_id: alice.id})

noteB1 = Repo.insert!(%Note{title: "Note B 1", content: "Owned by Bob", public: false, type: :markdown, user_id: bob.id})

noteA1 = Repo.preload(noteA1, :authors)
noteA2 = Repo.preload(noteA2, :authors)
noteB1 = Repo.preload(noteB1, :authors)

noteA1
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:authors, [bob, jakab])
|> Repo.update!()

noteA2
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:authors, [jakab, john])
|> Repo.update!()

noteB1
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:authors, [alice, jakab, john])
|> Repo.update!()
