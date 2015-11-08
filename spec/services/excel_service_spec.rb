require 'rails_helper'

RSpec.describe ExcelService do
  describe '#create_temp_file_name' do
    example 'create' do
      expect(ExcelService.create_temp_file_name('aaa.xlsx')).to eq('tmp/aaa.xlsx')
    end
  end
end
