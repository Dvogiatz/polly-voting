defmodule PollyWeb.VotingLive do
  use PollyWeb, :live_view

  alias Polly.Hackathon

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Polly.PubSub, "votes")
    end

    {:ok, load_data(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <%!-- Header --%>
          <div class="text-center mb-12">
            <h1 class="text-5xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent mb-4">
              Hackathon Voting
            </h1>
            <p class="text-xl text-gray-600">
              Vote for your favorite projects • You have
              <span class="font-bold text-indigo-600">{@votes_remaining}</span>
              votes remaining
            </p>
          </div>

          <%!-- Voting Section (only if user can vote) --%>
          <%= if @can_vote do %>
            <div class="bg-white rounded-2xl shadow-xl p-8 mb-12 border border-gray-100">
              <h2 class="text-2xl font-bold text-gray-900 mb-6">Cast Your Votes</h2>

              <.form
                for={@vote_form}
                id="voting-form"
                phx-change="update_votes"
                phx-submit="submit_votes"
              >
                <div class="space-y-4">
                  <%= for project <- @votable_projects do %>
                    <div class="flex items-center justify-between p-4 rounded-xl border-2 border-gray-200 hover:border-indigo-300 transition-all">
                      <div class="flex-1">
                        <h3 class="font-semibold text-gray-900">{project.name}</h3>
                        <p class="text-sm text-gray-500">{project.description}</p>
                      </div>
                      <div class="flex items-center gap-3 ml-4">
                        <label class="text-sm font-medium text-gray-700">Votes:</label>
                        <input
                          type="number"
                          name={"votes[#{project.id}]"}
                          value={Map.get(@current_votes, project.id, 0)}
                          min="0"
                          max="5"
                          class="w-20 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                        />
                      </div>
                    </div>
                  <% end %>
                </div>

                <div class="mt-6 flex items-center justify-between">
                  <div class={[
                    "text-sm font-medium px-4 py-2 rounded-lg",
                    @votes_remaining == 0 && "bg-green-100 text-green-800",
                    @votes_remaining > 0 && "bg-amber-100 text-amber-800",
                    @votes_remaining < 0 && "bg-red-100 text-red-800"
                  ]}>
                    <%= cond do %>
                      <% @votes_remaining == 0 -> %>
                        ✓ All votes allocated
                      <% @votes_remaining > 0 -> %>
                        {abs(@votes_remaining)} {if @votes_remaining == 1, do: "vote", else: "votes"} remaining
                      <% @votes_remaining < 0 -> %>
                        ⚠ Over by {abs(@votes_remaining)} {if abs(@votes_remaining) == 1,
                          do: "vote",
                          else: "votes"}
                    <% end %>
                  </div>

                  <button
                    type="submit"
                    disabled={@votes_remaining != 0 || @has_voted}
                    class={[
                      "px-8 py-3 rounded-lg font-semibold transition-all",
                      @votes_remaining == 0 && !@has_voted &&
                        "bg-indigo-600 hover:bg-indigo-700 text-white",
                      (@votes_remaining != 0 || @has_voted) &&
                        "bg-gray-300 text-gray-500 cursor-not-allowed"
                    ]}
                  >
                    {if @has_voted, do: "✓ Votes Submitted", else: "Submit Votes"}
                  </button>
                </div>
              </.form>
            </div>
          <% end %>

          <%!-- Results Section --%>
          <div class="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">Live Results</h2>

            <div class="space-y-4">
              <%= for {project, index} <- Enum.with_index(@projects_with_votes, 1) do %>
                <div
                  class="relative overflow-hidden rounded-xl border-2 border-gray-200 hover:border-indigo-300 transition-all cursor-pointer"
                  phx-click="show_voters"
                  phx-value-project-id={project.id}
                >
                  <div class="p-6">
                    <div class="flex items-start justify-between mb-3">
                      <div class="flex-1">
                        <div class="flex items-center gap-3 mb-2">
                          <span class="text-2xl font-bold text-gray-400">#{index}</span>
                          <h3 class="text-lg font-bold text-gray-900">{project.name}</h3>
                        </div>
                        <p class="text-sm text-gray-500">{project.description}</p>
                      </div>
                      <div class="text-right ml-4">
                        <div class="text-4xl font-bold text-indigo-600">
                          {project.vote_count || 0}
                        </div>
                        <div class="text-sm text-gray-500 font-medium">
                          {if project.vote_count == 1, do: "vote", else: "votes"}
                        </div>
                      </div>
                    </div>

                    <%!-- Progress bar --%>
                    <div class="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        class="h-full bg-gradient-to-r from-indigo-500 to-purple-500 transition-all duration-500"
                        style={"width: #{calculate_percentage(project.vote_count, @max_votes)}%"}
                      >
                      </div>
                    </div>
                  </div>

                  <div class="absolute top-4 right-4 text-xs text-gray-400 hover:text-indigo-600">
                    Click to see voters →
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <%!-- Voters Modal --%>
      <%= if @show_voters_modal do %>
        <div
          class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
          phx-click="close_modal"
        >
          <div
            class="bg-white rounded-2xl shadow-2xl max-w-md w-full mx-4 p-8"
            phx-click="stop_propagation"
          >
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-2xl font-bold text-gray-900">Who voted?</h3>
              <button
                phx-click="close_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>

            <div class="mb-4">
              <h4 class="font-semibold text-lg text-indigo-600">{@selected_project_name}</h4>
            </div>

            <%= if @project_voters == [] do %>
              <p class="text-gray-500 text-center py-8">No votes yet</p>
            <% else %>
              <div class="space-y-3">
                <%= for voter <- @project_voters do %>
                  <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div>
                      <div class="font-medium text-gray-900">{voter.user_email}</div>
                      <%= if voter.user_project do %>
                        <div class="text-sm text-gray-500">from {voter.user_project}</div>
                      <% end %>
                    </div>
                    <div class="text-2xl font-bold text-indigo-600">
                      {voter.count}
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("update_votes", %{"votes" => votes}, socket) do
    current_votes =
      votes
      |> Enum.reject(fn {key, _value} -> String.starts_with?(key, "_unused") end)
      |> Enum.map(fn {project_id, count} ->
        count_int = parse_count(count)
        # Cap each vote at 5
        count_int = min(count_int, 5)
        {String.to_integer(project_id), count_int}
      end)
      |> Map.new()

    # Cap total votes at 5
    total_votes = current_votes |> Map.values() |> Enum.sum()

    # If over 5 votes, proportionally reduce them
    current_votes =
      if total_votes > 5 do
        Enum.map(current_votes, fn {project_id, _count} ->
          {project_id, 0}
        end)
        |> Map.new()
      else
        current_votes
      end

    total_votes = current_votes |> Map.values() |> Enum.sum()
    votes_remaining = 5 - total_votes

    {:noreply,
     socket
     |> assign(:current_votes, current_votes)
     |> assign(:votes_remaining, votes_remaining)}
  end

  def handle_event("submit_votes", %{"votes" => votes}, socket) do
    current_votes =
      votes
      |> Enum.reject(fn {key, _value} -> String.starts_with?(key, "_unused") end)
      |> Enum.map(fn {project_id, count} ->
        count_int = parse_count(count)
        # Cap each vote at 5
        count_int = min(count_int, 5)
        {String.to_integer(project_id), count_int}
      end)
      |> Enum.filter(fn {_project_id, count} -> count > 0 end)
      |> Map.new()

    # Validate total is exactly 5
    total_votes = current_votes |> Map.values() |> Enum.sum()

    if total_votes != 5 do
      {:noreply, put_flash(socket, :error, "You must allocate exactly 5 votes!")}
    else
      case Hackathon.cast_votes(socket.assigns.current_scope.user, current_votes) do
        {:ok, _} ->
          Phoenix.PubSub.broadcast(Polly.PubSub, "votes", :votes_updated)

          {:noreply,
           socket
           |> assign(:has_voted, true)
           |> put_flash(:info, "Your votes have been submitted successfully!")
           |> load_data()}
      end
    end
  end

  def handle_event("show_voters", %{"project-id" => project_id}, socket) do
    project_id = String.to_integer(project_id)
    project = Enum.find(socket.assigns.projects_with_votes, &(&1.id == project_id))
    voters = Hackathon.get_project_votes(project_id)

    {:noreply,
     socket
     |> assign(:show_voters_modal, true)
     |> assign(:selected_project_name, project.name)
     |> assign(:project_voters, voters)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_voters_modal, false)
     |> assign(:selected_project_name, nil)
     |> assign(:project_voters, [])}
  end

  def handle_event("stop_propagation", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:votes_updated, socket) do
    {:noreply, load_data(socket)}
  end

  defp load_data(socket) do
    user = socket.assigns.current_scope.user
    projects_with_votes = Hackathon.list_projects_with_votes()
    max_votes = projects_with_votes |> Enum.map(& &1.vote_count) |> Enum.max(fn -> 0 end)

    votable_projects = Hackathon.list_votable_projects(user)
    user_votes = Hackathon.get_user_votes(user.id)
    current_votes = user_votes |> Enum.map(&{&1.project_id, &1.count}) |> Map.new()
    total_votes = Hackathon.get_user_total_votes(user.id)

    socket
    |> assign(:projects_with_votes, projects_with_votes)
    |> assign(:max_votes, max_votes)
    |> assign(:votable_projects, votable_projects)
    |> assign(:can_vote, length(votable_projects) > 0)
    |> assign(:current_votes, current_votes)
    |> assign(:votes_remaining, 5 - total_votes)
    |> assign(:has_voted, total_votes > 0)
    |> assign(:vote_form, to_form(%{}, as: "votes"))
    |> assign(:show_voters_modal, false)
    |> assign(:selected_project_name, nil)
    |> assign(:project_voters, [])
  end

  defp parse_count(""), do: 0
  defp parse_count(nil), do: 0

  defp parse_count(count) when is_binary(count) do
    case Integer.parse(count) do
      {num, _} -> num
      :error -> 0
    end
  end

  defp parse_count(count) when is_integer(count), do: count

  defp calculate_percentage(_count, 0), do: 0
  defp calculate_percentage(count, max), do: (count / max * 100) |> round()
end
