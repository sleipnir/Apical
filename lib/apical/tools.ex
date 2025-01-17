defmodule Apical.Tools do
  @default_content_mapping [{"application/yaml", YamlElixir}, {"application/json", Jason}]
  def decode(string, opts) do
    # content_type defaults to "application/yaml"
    content_type = Keyword.get(opts, :content_type, "application/yaml")

    opts
    |> Keyword.get(:decoders, [])
    |> List.keyfind(content_type, 0, List.keyfind(@default_content_mapping, content_type, 0))
    |> case do
      {_, YamlElixir} -> YamlElixir.read_from_string!(string)
      {_, Jason} -> Jason.decode!(string)
      nil -> raise "decoder for #{content_type} not found"
    end
  end

  @spec maybe_dump(Macro.t(), keyword) :: Macro.t()
  def maybe_dump(quoted, opts) do
    if Keyword.get(opts, :dump, false) do
      quoted
      |> Macro.to_string()
      |> IO.puts()

      quoted
    else
      quoted
    end
  end

  def assert(condition, message, opts \\ []) do
    # todo: consider adding jsonschema path information here.
    unless condition do
      explained =
        if opts[:apical] do
          "Apical does not recognize your schema: #{message}"
        else
          "Your schema violates OpenAPI: #{message}"
        end

      raise CompileError, description: explained
    end
  end
end
