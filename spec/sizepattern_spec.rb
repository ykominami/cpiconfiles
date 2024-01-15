# frozen_string_literal: true

RSpec.describe Cpiconfiles::Sizepattern do
  before(:all) do
    @sizepat = Cpiconfiles::Sizepattern.new()
  end

  it "test1" do
    pat = "a"
    str = "a-hdpi"
    ret = @sizepat.mat(pat, str)
    p "ret=#{ret}"

    expect(ret).to eq(1)
  end

  it "test2" do
    pat = "h"
    str = "h-hdpi"
    ret = @sizepat.mat(pat, str)
    # p "result=#{result}"
    p "ret=#{ret}"

    expect(ret).to eq(1)
  end

  it "test3" do
    pat = "d"
    str = "a-hdpi"
    ret = @sizepat.mat(pat, str)
    # p "result=#{result}"
    p "ret=#{ret}"

    expect(ret).to eq(1)
  end

  it "get string" do
    str = "a-hdpi"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    expect(pat).to eq("hdpi")
  end

  it "get string2" do
    str = "bc-mdpi"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    expect(pat).to eq("mdpi")
  end

  it "get string3" do
    str = "def-xhdpi"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    expect(pat).to eq("xhdpi")
  end

  it "get string4" do
    str = "def-xxhdpi"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    expect(pat).to eq("xxhdpi")
  end

  it "get string7", str: 1 do
    str = "1-24"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    expect(pat).to eq("24")
  end

  it "get string8", str: 2 do
    str = "1-24-Hover"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("24")
  end

  it "get string9", str: 3 do
    str = "1-32"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("32")
  end

  it "get string10", str: 4 do
    str = "48"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("48")
  end

  it "get string11", str: 5 do
    str = "25x25"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("25")
  end

  it "get string12", str: 6 do
    str = "button_icons_pack_icons_pack_120577"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("120577")
  end

  it "get string13", str: 7 do
    str = "abc-2525"
    # 返値を way, pat, head_str 受け取るように変数を変更
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # 期待値をチェックするための expect 文も pat を使って修正
    expect(pat).to eq("2525")
  end

  it "get string14", str: 8 do
    str = "logo192"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("192")
  end

  it "get string15", str: 9 do
    str = "._1-128-Hover"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("128")
  end

  it "get string16", str: 10 do
    str = "._3-128"
    way, pat, head_str, tail_str = @sizepat.size_specified_name_pattern?(str)
    p "str=#{str}"
    p "way=#{way}"
    p "pat=#{pat}"
    p "head_str=#{head_str}"
    p "tail_str=#{tail_str}"

    # expect(result).to eq(3)
    expect(pat).to eq("128")
  end
end
