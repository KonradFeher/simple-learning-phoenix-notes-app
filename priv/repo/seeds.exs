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


noteA1 = Repo.insert!(%Note{title: "Alice's ideas for vacatin", content: "I am looking for some ideas on what to do for vacation, help me out!", public: true, type: :plaintext, user_id: alice.id})
noteA2 = Repo.insert!(%Note{title: "Shopping list", content: "bread, milk, eggs, sausage, butter, coffee...", public: false, type: :plaintext, user_id: alice.id})

noteB1 = Repo.insert!(%Note{title: "How does this work", content: "is this Google?..", public: false, type: :plaintext, user_id: bob.id})

noteC1 = Repo.insert!(%Note{title: "We can now use Markdown!", content: "# Title  \n## Subtitle  \n _fancy italics_, **bolds**, ~~strikethrough!~~  \nLists:  \n- Item 1  \n- Item 2  \n- Item 3  \n I think tables and images should also work!!", public: true, type: :plaintext, user_id: john.id})

noteD1 = Repo.insert!(%Note{title: "Look! Scrungly!", content: "This is my cat scrungly and I will collect more images here about him!!  \n ![Scrugly Pose](https://i.kym-cdn.com/photos/images/newsfeed/002/349/699/077.jpg)", public: true, type: :plaintext, user_id: jakab.id})

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
