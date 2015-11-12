module SubjectsCacheService
  module_function

  CLASS_NAME = 'SubjectsCacheService'

  # 勘定科目に関するCacheをクリアします。(勘定科目変更時など)
  def clear_subjects_cache(fiscal_year)
    Rails.cache.delete("#{CLASS_NAME}#get_subject_list(#{fiscal_year.id})")
    Rails.cache.delete("#{CLASS_NAME}#get_subject_list_with_usage_ranking(#{fiscal_year.id}-debit)")
    Rails.cache.delete("#{CLASS_NAME}#get_subject_list_with_usage_ranking(#{fiscal_year.id}-credit)")
  end

  # 会計年度分の勘定科目のリストを取得します。(Cache有効)
  def get_subject_list(fiscal_year)
    cache_key = "#{CLASS_NAME}#get_subject_list(#{fiscal_year.id})"
    Rails.cache.fetch(cache_key, expires_in: 1.day) {
      SubjectsService.get_subject_list(fiscal_year, true)
    }
  end

  # 使用ランキング順の借方・貸方勘定科目のListを取得します。(Cache有効)
  def get_subject_list_with_usage_ranking(fiscal_year, for_debit)
    debit_credit = for_debit ? 'debit' : 'credit'
    cache_key = "#{CLASS_NAME}#get_subject_list_with_usage_ranking(#{fiscal_year.id}-#{debit_credit})"
    Rails.cache.fetch(cache_key, expires_in: 1.day) {
      SubjectsService.create_subject_list_with_usage_ranking(fiscal_year, for_debit)
    }
  end
end
