require 'rails_helper'

RSpec.describe SubjectsCacheService do
  let(:fiscal_year) { create(:fiscal_year) }

  describe '#clear_subjects_cache' do
    example 'clear' do
      SubjectsCacheService.clear_subjects_cache(fiscal_year)

      key1 = "SubjectsCacheService#get_subject_list(#{fiscal_year.id})"
      expect(Rails.cache.delete(key1)).to be_nil
      key2 = "SubjectsCacheService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-debit)"
      expect(Rails.cache.delete(key2)).to be_nil
      key3 = "SubjectsCacheService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-debit)"
      expect(Rails.cache.delete(key3)).to be_nil
    end
  end

  describe '#get_subject_list' do
    example 'get' do
      expect(SubjectsService).to receive(:get_subject_list).with(fiscal_year, true).and_return(['DUMMY'])
      actual = SubjectsCacheService.get_subject_list(fiscal_year)
      expect(actual).to eq(['DUMMY'])

      key = "SubjectsCacheService#get_subject_list(#{fiscal_year.id})"
      from_cache = Rails.cache.fetch(key)
      expect(from_cache).to eq(['DUMMY'])
    end
  end

  describe '#get_subject_list_with_usage_ranking' do
    example 'get for debit' do
      expect(SubjectsService).to \
        receive(:create_subject_list_with_usage_ranking).with(fiscal_year, true).and_return(['DUMMY'])
      actual = SubjectsCacheService.get_subject_list_with_usage_ranking(fiscal_year, true)
      expect(actual).to eq(['DUMMY'])

      key = "SubjectsCacheService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-debit)"
      from_cache = Rails.cache.fetch(key)
      expect(from_cache).to eq(['DUMMY'])
    end

    example 'get for credit' do
      expect(SubjectsService).to \
        receive(:create_subject_list_with_usage_ranking).with(fiscal_year, false).and_return(['DUMMY'])
      actual = SubjectsCacheService.get_subject_list_with_usage_ranking(fiscal_year, false)
      expect(actual).to eq(['DUMMY'])

      key = "SubjectsCacheService#get_subject_list_with_usage_ranking(#{fiscal_year.id}-credit)"
      from_cache = Rails.cache.fetch(key)
      expect(from_cache).to eq(['DUMMY'])
    end
  end
end
