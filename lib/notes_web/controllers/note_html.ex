defmodule NotesWeb.NoteHTML do
  use NotesWeb, :html

  embed_templates "note_html/*"

  @doc """
  Renders a user badge with icon and name.
  """
  attr :user, Notes.Accounts.User, required: true
  attr :owner, :boolean, default: false
  attr :class, :string, default: ""

  def user_badge(assigns) do
    ~H"""
    <div class={"inline-flex items-center gap-2 px-3 py-1 rounded-lg bg-base-200 #{@class}"}>
      <.icon name="hero-user" class="w-4 h-4 text-gray" />
      <span class="font-medium text-white-800">{@user.name || @user.email}</span>
      <span :if={@owner} class="font-light text-white-800">(owner)</span>
    </div>
    """
  end

  @doc """
  Renders a note form.

  The form is defined in the template at
  note_html/note_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def note_form(assigns)

  def owner?(current_user, note), do:
    current_user && current_user.id == note.user_id

end
