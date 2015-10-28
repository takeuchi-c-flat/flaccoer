require 'rails_helper'

RSpec.describe CsvImportService do
  let(:fiscal_year) { create(:fiscal_year) }
  let(:type_property) { SubjectType.find_by(debit: true, debit_and_credit: true) }
  let(:type_debt) { SubjectType.find_by(credit: true, debit_and_credit: true) }
  let(:subjects) {
    [
      FactoryGirl.create(
        :subject,
        fiscal_year: fiscal_year, subject_type: type_property,
        code: '101', name: '資産１',
        report1_location: 10, report2_location: 20, report3_location: 30, report4_location: 40, report5_location: 50,
        from_template: true, dash_board: false),
      FactoryGirl.create(
        :subject,
        fiscal_year: fiscal_year, subject_type: type_property,
        code: '102', name: '資産２',
        from_template: false, dash_board: true),
      FactoryGirl.create(
        :subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '201', name: '負債１'),
      FactoryGirl.create(
        :subject, fiscal_year: fiscal_year, subject_type: type_debt, code: '202', name: '負債２', disabled: true)
    ]
  }

  describe '#import_csv_data' do
    example 'no-data' do
      csv_data = "取引日,借方コード,貸方コード\n"
      (result, infos) = CsvImportService.import_csv_data(fiscal_year, :journals, csv_data)
      expect(result).to eq(false)
      expect(infos).to eq('内容がありません。')
    end

    example 'journals and file-type error' do
      csv_data = "取引日,借方コード,貸方コード\n2015-01-01,100,300"
      (result, infos) = CsvImportService.import_csv_data(fiscal_year, :journals, csv_data)
      expect(result).to eq(false)
      expect(infos).to eq('ファイル形式が正しくありません。')
    end

    example 'journals with error' do
      _base_subjects = subjects
      csv_data = "取引日,借方コード,\"借方名称\",貸方コード,貸方名称.....\n" \
+ "2015-01-01,101,,102,,1200,摘要１\n" \
+ "2014-12-31,102,,101,,1200,摘要２\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :journals, csv_data)
      expect(result).to eq(false)
      expect(info).to eq('3行目でエラーが発生しました。[バリデーションに失敗しました 取引日 日付が年度の範囲外です。]')
      expect(Journal.where(fiscal_year: fiscal_year).length).to eq(0)
    end

    example 'journals with success' do
      base_subjects = subjects
      csv_data = "取引日,借方コード,\"借方名称\",貸方コード,貸方名称.....\n" \
+ "2015-01-01,101,,102,,1200,摘要１\n" \
+ "2015-01-02,102,,101,,1200,摘要２\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :journals, csv_data)
      expect(result).to eq(true)
      expect(info).to eq('2行を取り込みました。')
      journals = Journal.where(fiscal_year: fiscal_year)
      expect(journals.length).to eq(2)
      expect(journals[0]).to have_attributes(
        journal_date: Date.new(2015, 1, 1),
        subject_debit: base_subjects[0],
        subject_credit: base_subjects[1],
        price: 1200,
        comment: '摘要１')
    end

    example 'subjects and file-type error' do
      csv_data = "type_id,コード,帳票位置１\n1,300,"
      (result, infos) = CsvImportService.import_csv_data(fiscal_year, :subjects, csv_data)
      expect(result).to eq(false)
      expect(infos).to eq('ファイル形式が正しくありません。')
    end

    example 'subjects with error' do
      base_subjects = subjects
      csv_data = "type_id,コード,名称,帳票位置１,帳票位置２.....\n" \
+ "3,300,収入１,0,0,0,0,0,true,true,true\n" \
+ "99,300,収入１,0,0,0,0,0,true,true,true\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :subjects, csv_data)
      expect(result).to eq(false)
      expect(info).to eq('3行目でエラーが発生しました。[科目種別が正しくありません。]')
      expect(Subject.where(fiscal_year: fiscal_year).length).to eq(base_subjects.length)
    end

    example 'subjects with success' do
      base_subjects = subjects
      csv_data = "type_id,コード,名称,帳票位置１,帳票位置２.....\n" \
+ "3,300,収入１,11,12,13,14,15,true,false,true\n" \
+ "4,400,支出１,0,0,0,0,0,false,true,false\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :subjects, csv_data)
      expect(result).to eq(true)
      expect(info).to eq('2行を取り込みました。')
      subjects = Subject.where(fiscal_year: fiscal_year)
      expect(subjects.length).to eq(base_subjects.length + 2)
      expect(subjects.find { |s| s.code == '300' }).to have_attributes(
        subject_type: SubjectType.find(3),
        code: '300',
        name: '収入１',
        report1_location: 11,
        report2_location: 12,
        report3_location: 13,
        report4_location: 14,
        report5_location: 15,
        from_template: true,
        disabled: false,
        dash_board: true)
    end

    example 'balances and file-type error' do
      csv_data = "科目コード,期首残高\n300,30000,"
      (result, infos) = CsvImportService.import_csv_data(fiscal_year, :balances, csv_data)
      expect(result).to eq(false)
      expect(infos).to eq('ファイル形式が正しくありません。')
    end

    example 'balances with error' do
      _base_subjects = subjects
      csv_data = "科目コード,科目名称,期首残高\n" \
+ "101,,0\n" \
+ "109,,0\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :balances, csv_data)
      expect(result).to eq(false)
      expect(info).to eq('3行目でエラーが発生しました。[科目コード(109)は存在しません。]')
      expect(Balance.where(fiscal_year: fiscal_year).length).to eq(0)
    end

    example 'balances with success' do
      _base_subjects = subjects
      csv_data = "科目コード,科目名称,期首残高\n" \
+ "101,,10100\n" \
+ "102,,10200\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :balances, csv_data)
      expect(result).to eq(true)
      expect(info).to eq('2行を取り込みました。')
      balances = Balance.where(fiscal_year: fiscal_year)
      expect(balances.length).to eq(2)
      expect(balances.find { |s| s.subject.code == '101' }.top_balance).to eq(10100)
      expect(balances.find { |s| s.subject.code == '102' }.top_balance).to eq(10200)
    end

    example 'badgets and file-type error' do
      csv_data = "科目コード,年間予算\n300,30000,"
      (result, infos) = CsvImportService.import_csv_data(fiscal_year, :badgets, csv_data)
      expect(result).to eq(false)
      expect(infos).to eq('ファイル形式が正しくありません。')
    end

    example 'badgets with error' do
      _base_subjects = subjects
      csv_data = "科目コード,科目名称,年間予算\n" \
+ "101,,0\n" \
+ "202,,0\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :badgets, csv_data)
      expect(result).to eq(false)
      expect(info).to eq('3行目でエラーが発生しました。[科目コード(202)は無効になっています。]')
      expect(Badget.where(fiscal_year: fiscal_year).length).to eq(0)
    end

    example 'badgets with success' do
      _base_subjects = subjects
      csv_data = "科目コード,科目名称,年間予算\n" \
+ "101,,10100\n" \
+ "102,,10200\n"

      (result, info) = CsvImportService.import_csv_data(fiscal_year, :badgets, csv_data)
      expect(result).to eq(true)
      expect(info).to eq('2行を取り込みました。')
      badgets = Badget.where(fiscal_year: fiscal_year)
      expect(badgets.length).to eq(2)
      expect(badgets.find { |s| s.subject.code == '101' }.total_badget).to eq(10100)
      expect(badgets.find { |s| s.subject.code == '102' }.total_badget).to eq(10200)
    end
  end
end
