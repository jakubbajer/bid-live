if Code.ensure_loaded?(Jason.Encoder.Decimal) do
  # Jason already provides this encoder
else
  defimpl Jason.Encoder, for: Decimal do
    def encode(value, opts) do
      value |> Decimal.to_string() |> Jason.Encode.string(opts)
    end
  end
end
