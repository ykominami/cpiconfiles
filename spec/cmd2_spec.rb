require 'spec_helper'
# require 'thor'

Rspec.describe Cpiconfiles::Cmd do
  let(:cmd) { Thor::Runner.new }

  it 'calls the start method with arguments' do
    expect(cmd).to true
  end
end