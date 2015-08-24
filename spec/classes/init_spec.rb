require 'spec_helper'
describe 'sfu_fw' do

  context 'with defaults for all parameters' do
    it { should contain_class('sfu_fw') }
  end
end
