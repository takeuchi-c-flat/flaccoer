require 'rails_helper'

RSpec.describe CsvExportService do
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

  example '#create_journals_export_csv_data' do
    journals =
      [
        FactoryGirl.create(
          :journal,
          fiscal_year: fiscal_year, journal_date: Date.new(2015, 4, 1),
          subject_debit: subjects[0], subject_credit: subjects[2],
          price: 10000, comment: '明細１'),
        FactoryGirl.create(
          :journal,
          fiscal_year: fiscal_year, journal_date: Date.new(2015, 10, 30),
          subject_debit: subjects[1], subject_credit: subjects[2],
          price: 20000, comment: '明細２')
      ]

    actual = CsvExportService.create_journals_export_csv_data(journals)
    rows = actual.split("\n")
    expect(rows.length).to eq(3)
    expect(rows[0]).to eq("\"取引日\",\"借方コード\",\"借方名称\",\"貸方コード\",\"貸方名称\",\"金額\",\"摘要\"")
    expect(rows[1]).to eq("\"2015-04-01\",\"101\",\"資産１\",\"201\",\"負債１\",\"10000\",\"明細１\"")
    expect(rows[2]).to eq("\"2015-10-30\",\"102\",\"資産２\",\"201\",\"負債１\",\"20000\",\"明細２\"")
  end

  example '#create_subjects_export_csv_data' do
    actual = CsvExportService.create_subjects_export_csv_data(subjects)
    rows = actual.split("\n")
    expect(rows.length).to eq(5)
    expect(rows[0]).to eq(
      "\"type_id\",\"コード\",\"名称\"," \
 + "\"帳票位置１\",\"帳票位置２\",\"帳票位置３\",\"帳票位置４\",\"帳票位置５\"," \
 + "\"テンプレート項目\",\"無効\",\"ダッシュボード表示\"")
    expect(rows[1]).to eq("\"1\",\"101\",\"資産１\",\"10\",\"20\",\"30\",\"40\",\"50\",\"true\",\"false\",\"false\"")
    expect(rows[2]).to eq("\"1\",\"102\",\"資産２\",\"0\",\"0\",\"0\",\"0\",\"0\",\"false\",\"false\",\"true\"")
    expect(rows[3]).to eq("\"2\",\"201\",\"負債１\",\"0\",\"0\",\"0\",\"0\",\"0\",\"false\",\"false\",\"false\"")
    expect(rows[4]).to eq("\"2\",\"202\",\"負債２\",\"0\",\"0\",\"0\",\"0\",\"0\",\"false\",\"true\",\"false\"")
  end

  example '#create_balances_export_csv_data' do
    balances =
      [
        FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[0], top_balance: 10000),
        FactoryGirl.create(:balance, fiscal_year: fiscal_year, subject: subjects[1], top_balance: 20000)
      ]

    actual = CsvExportService.create_balances_export_csv_data(balances)
    rows = actual.split("\n")
    expect(rows.length).to eq(3)
    expect(rows[0]).to eq("\"科目コード\",\"科目名称\",\"期首残高\"")
    expect(rows[1]).to eq("\"101\",\"資産１\",\"10000\"")
    expect(rows[2]).to eq("\"102\",\"資産２\",\"20000\"")
  end

  example '#create_badgets_export_csv_data' do
    badgets =
      [
        FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[0], total_badget: 10000),
        FactoryGirl.create(:badget, fiscal_year: fiscal_year, subject: subjects[1], total_badget: 20000)
      ]

    actual = CsvExportService.create_badgets_export_csv_data(badgets)
    rows = actual.split("\n")
    expect(rows.length).to eq(3)
    expect(rows[0]).to eq("\"科目コード\",\"科目名称\",\"年間予算\"")
    expect(rows[1]).to eq("\"101\",\"資産１\",\"10000\"")
    expect(rows[2]).to eq("\"102\",\"資産２\",\"20000\"")
  end
end
