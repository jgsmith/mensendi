defmodule Mensendi.DataTypes.PT do
  use Mensendi.DSL.DataType

  component :processing_id, :ID
  component :processing_mode, :ID
end
