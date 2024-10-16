# frozen_string_literal: true
require 'spec_helper'
require 'thor'
require 'pathname'

RSpec.describe Cpiconfiles::Cmd do
  let(:cmd) { Thor::Runner.new }
  let(:top_dir_pn) { Pathname(__FILE__).parent + "test_data"}
  let(:yaml_fname_pn) { top_dir_pn + "a10.yaml"}
  let(:csv_fname_pn) { top_dir_pn + "a10.csv"}

  it 'calls the start method with yaml subcommand', :yaml => true  do
    expect{Cpiconfiles::Cmd.start(['yaml', top_dir_pn, '-x', '-o', yaml_fname_pn, '-c', csv_fname_pn])}.to output('').to_stdout
  end

  it 'calls the start method with fyaml subcommand', :fyaml => true do
    expect{Cpiconfiles::Cmd.start(['fyaml', '-o', yaml_fname_pn.to_s, '-c', csv_fname_pn.to_s])}.to output('').to_stdout
  end
end