defmodule SoLoudEx.Server do
  use GenServer

  require Logger
  require SoLoudEx.Constants

  alias SoLoudEx.{AudioSource, Voice}
  alias SoLoudEx.AudioSource.Wavstream
  alias SoLoudEx.Constants

  ## Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def load_wavstream(filepath) when is_binary(filepath) do
    GenServer.call(__MODULE__, {:load_wavstream, filepath, nil})
  end

  @doc false
  def load_wavstream_to_slot(filepath, slot) when is_binary(filepath) and is_integer(slot) do
    GenServer.call(__MODULE__, {:load_wavstream, filepath, slot})
  end

  def audio_play(%Wavstream{} = wavstream) do
    GenServer.call(__MODULE__, {:audio_play, wavstream})
  end

  def audio_stop(%Voice{handle: handle}) do
    GenServer.call(__MODULE__, {:audio_stop, handle})
  end

  def audio_seek(%Voice{handle: handle}, seek_position) when seek_position >= 0
                                                            and seek_position <= 32767 do
    GenServer.call(__MODULE__, {:audio_seek, handle, seek_position})
  end

  ## Server API

  @impl true
  def init(_) do
    {port, ref} = setup_port()
    table = :ets.new(:soloudex, [:set])

    {:ok, %{port: port,
            monitor: ref,
            last_request: nil,
            ets: table,
            loaded_wavstreams: []}}
  end

  def setup_port() do
    opts = [:stream, :binary, {:packet, 2}]
    port = Port.open({:spawn, :code.priv_dir(:soloudex) ++ '/cpp/soloud'}, opts)
    ref = Port.monitor(port)

    {port, ref}
  end

  @impl true
  def handle_call({:load_wavstream, path, slot}, from, %{loaded_wavstreams: wavstream_list} = state), do:
    send_message(state, from, :load_wavstream, {path, slot || length(wavstream_list)})

  @impl true
  def handle_call({:audio_play, wavstream}, from, state), do:
    send_message(state, from, :audio_play, AudioSource.identify(wavstream), source: wavstream)

  @impl true
  def handle_call({:audio_stop, sound_handle}, from, state), do:
    send_message(state, from, :audio_stop, sound_handle)

  @impl true
  def handle_call({:audio_seek, sound_handle, seek_position}, from, state), do:
    send_message(state, from, :audio_seek, {sound_handle, seek_position / 1})

  @impl true
  def handle_info({port, {:data, data}}, %{port: port, last_request: {type, from, msg, opts}} = state) do
    return_data = :erlang.binary_to_term(data)
    {processed_return, updated_state} = handle_return(type, msg, return_data, state, opts)
    GenServer.reply(from, processed_return)

    {:noreply, %{updated_state | last_request: nil}}
  end

  @impl true
  def handle_info({port, {:data, _data}}, %{port: port, last_request: nil} = state) do
    {:noreply, state} # Can't trace back request, so discard the result
  end

  @impl true
  def handle_info({:DOWN, ref, :port, port, reason}, %{port: port, monitor: ref} = state) do
    Logger.warn("Port #{inspect port} has exited due to reason #{inspect reason}. Restarting...")
    {new_port, new_ref} = setup_port()

    {:noreply,
     %{state | port: new_port, monitor: new_ref, last_request: nil},
     {:continue, :reload_wavstreams}}
  end

  @impl true
  def handle_continue(:reload_wavstreams, state) do
    Logger.warn("Reloading previously loaded wavstreams...")
    Task.start_link(fn ->
      reload_wavstreams(state.loaded_wavstreams)
    end)

    {:noreply, %{state | loaded_wavstreams: []}}
  end

  defp handle_return(:load_wavstream, path_and_slot, {:ok, slot},
                     %{loaded_wavstreams: files} = state, _opts) do
    {
      {:ok, AudioSource.create_wavstream(slot)},
      %{state | loaded_wavstreams: [path_and_slot | files]}
    }
  end

  defp handle_return(:audio_play, _params, {:ok, handle}, state, opts) do
    {
      {:ok, AudioSource.create_voice(opts[:source], handle)},
      state
    }
  end

  defp handle_return(_type, _params, return_data, state, _opts), do: {return_data, state}

  defp send_message(%{port: port} = state, from, type, message, opts \\ []) do
    Port.command(port, <<Constants.opcodes()[type]>> <> :erlang.term_to_binary(message))

    {:noreply, %{state | last_request: {type, from, message, opts}}}
  end

  defp reload_wavstreams(path_list) do
    Enum.each(path_list, fn {path, slot} -> load_wavstream_to_slot(path, slot) end)
  end
end
