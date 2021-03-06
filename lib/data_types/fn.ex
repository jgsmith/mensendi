defmodule Mensendi.DataTypes.FN do
  use Mensendi.DSL.DataType

  component :surname, :ST
  component :own_surname_prefix, :ST
  component :own_surname, :ST
  component :surname_prefix_from_spouse, :ST
  component :surname_from_spouse, :ST
end
