defmodule BumblebeeTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BumblebeeTestWeb.Telemetry,
      # Start the Ecto repository
      BumblebeeTest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BumblebeeTest.PubSub},
      # Start Finch
      {Finch, name: BumblebeeTest.Finch},
      {Nx.Serving, serving: serving(), name: MyServing},
      # Start the Endpoint (http/https)
      BumblebeeTestWeb.Endpoint
      # Start a worker by calling: BumblebeeTest.Worker.start_link(arg)
      # {BumblebeeTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BumblebeeTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def serving do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-emotion-analysis"})

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    Bumblebee.Text.text_classification(model_info, tokenizer,
      compile: [batch_size: 10, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BumblebeeTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
