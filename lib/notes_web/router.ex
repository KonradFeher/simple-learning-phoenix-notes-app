defmodule NotesWeb.Router do
  use NotesWeb, :router

  import NotesWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NotesWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NotesWeb do
    pipe_through :browser

    resources "/notes", NoteController
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", NotesWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  # ? including this for prod as well, so I don't actually need to set up a mailer
  # if Application.compile_env(:notes, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NotesWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  # end

  ## Authentication routes

  scope "/", NotesWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{NotesWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password

    put "/notes/:note_id/add_author", NoteController, :add_author
    put "/notes/:note_id/add_sharee", NoteController, :add_sharee
    delete "/notes/:note_id/remove_author/:user_id", NoteController, :remove_author
    delete "/notes/:note_id/remove_sharee/:user_id", NoteController, :remove_sharee
  end

  scope "/", NotesWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{NotesWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  forward "/metrics", PromEx.Plug, prom_ex_module: Notes.PromEx
end
