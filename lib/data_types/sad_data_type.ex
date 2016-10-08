defmodule SADDataType do
  # Address
  use DataTypeDSL

  component :street_or_mailing_address, :ST
  component :street_name, :ST
  component :dwelling_number, :ST
end