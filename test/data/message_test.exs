defmodule Mensendi.Data.MessageTest do
  use ExUnit.Case
  doctest Mensendi.Data.Message

  test "from_string" do
    {:ok, message} = Mensendi.Data.Message.from_string(~s"""
MSH#^~\\&#CERNER##PriorityHealth####ORU^R01#Q479004375T431430612#P#2.3#
PID###001677980##SMITH^CURTIS##19680219#M##########929645156318#123456789#
PD1####1234567890^LAST^FIRST^M^^^^^NPI#
OBR#1#341856649^HNAM_ORDERID#000002006326002362#648088^Basic Metabolic Panel###20061122151600#########1620^Hooker^Robert^L######20061122154733###F###########20061122140000#
OBX#1#NM#GLU^Glucose Lvl#59#mg/dL#65-99^65^99#L###F###20061122154733#
""" |> String.replace("\n", "\r"))
    assert message.delimiters.fields == "#"
    assert Enum.count(message.segments) == 5
    assert Enum.map(message.segments, &(&1.name)) == ["MSH", "PID", "PD1", "OBR", "OBX"]

    output_message = message
    |> Mensendi.Data.Message.with_delimiters(%Mensendi.Data.Delimiters{})
    |> Mensendi.Data.Message.to_string

    expected_message = ~s"""
MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3
PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
PD1||||1234567890^LAST^FIRST^M^^^^^NPI
OBR|1|341856649^HNAM_ORDERID|000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
""" |> String.replace("\n", "\r")
    |> String.trim_trailing("\r")

    assert output_message == expected_message
  end

  test "with_structure" do
    {:ok, message} = Mensendi.Data.Message.from_string(~s"""
MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3
PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
PD1||||1234567890^LAST^FIRST^M^^^^^NPI
PV1|||
OBR|1|341856649^HNAM_ORDERID|000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
""" |> String.replace("\n", "\r")
    )

    expected_message = ~s"""
MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3
PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
PV1
""" |> String.replace("\n", "\r")
    |> String.trim_trailing("\r")

    {:ok, structured_message} = message |> Mensendi.Data.Message.with_structure("MSH <PID [PV1]>")

    assert (structured_message |> Mensendi.Data.Message.to_string) == expected_message
  end

  test "segments" do
    {:ok, message} = Mensendi.Data.Message.from_string(~s"""
MSH|^~\\&|CERNER||PriorityHealth||||ORU^R01|Q479004375T431430612|P|2.3
PID|||001677980||SMITH^CURTIS||19680219|M||||||||||929645156318|123456789
PD1||||1234567890^LAST^FIRST^M^^^^^NPI
PV1|||
PID|||
PID|||
PV1|||
OBR|1|341856649^HNAM_ORDERID|000002006326002362|648088^Basic Metabolic Panel|||20061122151600|||||||||1620^Hooker^Robert^L||||||20061122154733|||F|||||||||||20061122140000
OBX|1|NM|GLU^Glucose Lvl|59|mg/dL|65-99^65^99|L|||F|||20061122154733
""" |> String.replace("\n", "\r")
    )

    {:ok, structured_message} = message |> Mensendi.Data.Message.with_structure("MSH {<PID [PV1]>}")

    assert Enum.count(Mensendi.Data.Message.segments(structured_message, "MSH")) == 1
    assert Enum.count(Mensendi.Data.Message.segments(structured_message, "PID")) == 3
    assert Enum.count(Mensendi.Data.Message.segments(structured_message, "PV1")) == 0

    pids = Mensendi.Data.Message.segments(structured_message, "PID")

    assert Enum.count(Enum.fetch!(pids,0).children) == 1
    assert Enum.count(Enum.fetch!(pids,1).children) == 0
    assert Enum.count(Enum.fetch!(pids,2).children) == 1
  end
end
