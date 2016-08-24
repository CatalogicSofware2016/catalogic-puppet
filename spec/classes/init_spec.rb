require 'spec_helper'
describe 'ecx' do

  context 'with defaults for all parameters' do
    it { should contain_class('ecx') }
  end
end
