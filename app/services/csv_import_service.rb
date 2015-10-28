require 'csv'
require 'kconv'

module CsvImportService
  module_function

  IMPORT_METHODS = {
    journals: :import_journals_csv_data,
    subjects: :import_subjects_csv_data,
    balances: :import_balances_csv_data,
    badgets: :import_badgets_csv_data
  }
  CHECK_HEADER_COLUMNS = {
    journals: %w(取引日 借方コード 借方名称),
    subjects: %w(type_id コード 名称 帳票位置１),
    balances: %w(科目コード 科目名称 期首残高),
    badgets: %w(科目コード 科目名称 年間予算)
  }

  # 各種CSVデータをImportします。
  def import_csv_data(fiscal_year, type, csv_data)
    # ヘッダのチェック
    rows = csv_data_to_rows(csv_data)
    return [false, '内容がありません。'] if rows.length < 2
    header_columns = CHECK_HEADER_COLUMNS[type]
    return [false, 'ファイル形式が正しくありません。'] unless check_header(rows, header_columns)

    # 取り込みの実施
    import_method = IMPORT_METHODS[type]
    send(import_method, [fiscal_year, rows])
  end

  # 取引明細のCSVデータをImportします。
  def import_journals_csv_data(params)
    fiscal_year = params[0]
    count = 0
    begin
      ActiveRecord::Base.transaction do
        params[1].drop(1).map { |row| row_to_columns(row) }.each { |row|
          count += 1
          subject_debit = get_subject(fiscal_year, row[1])
          subject_credit = get_subject(fiscal_year, row[3])
          Journal.
            create(
              fiscal_year: fiscal_year,
              journal_date: Date.strptime(row[0], '%Y-%m-%d'),
              subject_debit: subject_debit,
              subject_credit: subject_credit,
              price: row[5].to_i,
              comment: row[6]).
            save!
        }
      end
    rescue => ex
      info = "#{count + 1}行目でエラーが発生しました。[#{ex.message}]"
    end

    return [false, info] unless info.nil?
    [true, "#{count}行を取り込みました。"]
  end

  # 勘定科目のCSVデータをImportします。
  # rubocop:disable Metrics/AbcSize
  def import_subjects_csv_data(params)
    fiscal_year = params[0]
    count = 0
    begin
      ActiveRecord::Base.transaction do
        params[1].drop(1).map { |row| row_to_columns(row) }.each { |row|
          count += 1
          subject_type = SubjectType.find_by(id: row[0])
          fail '科目種別が正しくありません。' if subject_type.nil?
          Subject.
            create(
              fiscal_year: fiscal_year,
              subject_type: subject_type,
              code: row[1], name: row[2],
              report1_location: row[3].to_i,
              report2_location: row[4].to_i,
              report3_location: row[5].to_i,
              report4_location: row[6].to_i,
              report5_location: row[7].to_i,
              from_template: row[8] == 'true',
              disabled: row[9] == 'true',
              dash_board: row[10] == 'true').
            save!
        }
      end
    rescue => ex
      info = "#{count + 1}行目でエラーが発生しました。[#{ex.message}]"
    end

    return [false, info] unless info.nil?
    [true, "#{count}行を取り込みました。"]
  end
  # rubocop:enable Metrics/AbcSize

  # 期首残高のCSVデータをImportします。
  def import_balances_csv_data(params)
    fiscal_year = params[0]
    count = 0
    begin
      ActiveRecord::Base.transaction do
        params[1].drop(1).map { |row| row_to_columns(row) }.each { |row|
          count += 1
          subject = get_subject(fiscal_year, row[0])
          Balance.create(fiscal_year: fiscal_year, subject: subject, top_balance: row[2].to_i).save!
        }
      end
    rescue => ex
      info = "#{count + 1}行目でエラーが発生しました。[#{ex.message}]"
    end

    return [false, info] unless info.nil?
    [true, "#{count}行を取り込みました。"]
  end

  # 年間予算のCSVデータをImportします。
  def import_badgets_csv_data(params)
    fiscal_year = params[0]
    count = 0
    begin
      ActiveRecord::Base.transaction do
        params[1].drop(1).map { |row| row_to_columns(row) }.each { |row|
          count += 1
          subject = get_subject(fiscal_year, row[0])
          Badget.create(fiscal_year: fiscal_year, subject: subject, total_badget: row[2].to_i).save!
        }
      end
    rescue => ex
      info = "#{count + 1}行目でエラーが発生しました。[#{ex.message}]"
    end

    return [false, info] unless info.nil?
    [true, "#{count}行を取り込みました。"]
  end

  # CSVデータを行のArrayに変換します。
  def csv_data_to_rows(csv_data)
    Kconv.toutf8(csv_data).split("\n")
  end

  # CSVデータを行のArrayに変換します。
  def row_to_columns(row)
    row.split(',').map { |column| column.gsub(/^(“|”|\")/, '').gsub(/(“|”|\")$/, '') }.to_a
  end

  # ヘッダ部の先頭をチェックします。
  def check_header(rows, column_titles)
    titles = column_titles.join(',')
    header = row_to_columns(rows[0]).join(',')
    header.start_with?(titles)
  end

  def get_subject(fiscal_year, subject_code)
    subject = Subject.find_by(fiscal_year: fiscal_year, code: subject_code)
    fail "科目コード(#{subject_code})は存在しません。" if subject.nil?
    fail "科目コード(#{subject_code})は無効になっています。" if subject.disabled?
    subject
  end
end
