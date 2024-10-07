# frozen_string_literal: true
require 'spec_helper'
require 'thor'

RSpec.describe Cpiconfiles::Cmd do
  let(:cmd) { Thor::Runner.new }
  let(:top_dir) {"E:/X/dev/ICONSZ/lifetime-icons-png/PNG/Bebo Badoo Blogger"}
  let(:yaml_fname) {"a10.yaml"}

  it 'calls the start method with yaml subcommand' do
    expect{Cpiconfiles::Cmd.start(['yaml', top_dir, '-x', '-o', yaml_fname])}.to output('').to_stdout
  end

  it 'calls the start method with fyaml subcommand' do
    expect{Cpiconfiles::Cmd.start(['fyaml', '-o', yaml_fname])}.to output('').to_stdout
  end
end