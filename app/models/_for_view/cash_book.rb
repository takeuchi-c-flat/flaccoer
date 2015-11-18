class CashBook
  # 現預金出納帳用のクラスです。
  attr_accessor :date, :code, :name, :comment, :price1, :balance1, :price2, :balance2

  class << self
    def from_journal(journal, subjects_info)
      CashBook.new.tap { |m|
        m.date = journal.journal_date
        m.comment = journal.comment
        subjects = subjects_info.subjects
        if subjects.include?(journal.subject_debit) && subjects.include?(journal.subject_credit)
          # 科目１・科目２間の資金移動の場合
          set_values_when_property_move(m, journal, subjects_info)
        elsif [journal.subject_debit, journal.subject_credit].include?(subjects_info.subject1)
          # 科目１が該当する取引の場合
          set_partner_subject_info(m, journal, subjects_info.subject1)
          set_values_when_subject1_journal(m, journal, subjects_info)
        else
          # 科目２が該当する取引の場合
          set_partner_subject_info(m, journal, subjects_info.subject2)
          set_values_when_subject2_journal(m, journal, subjects_info)
        end
      }
    end

    def set_values_when_property_move(cash_book, journal, subjects_info)
      first_is_debit = subjects_info.subject1 == journal.subject_debit
      cash_book.price1 = journal.price * (first_is_debit ? 1 : -1)
      subjects_info.balance1 += cash_book.price1
      cash_book.balance1 = subjects_info.balance1
      cash_book.price2 = journal.price * (first_is_debit ? -1 : 1)
      subjects_info.balance2 += cash_book.price2
      cash_book.balance2 = subjects_info.balance2
    end

    def set_values_when_subject1_journal(cash_book, journal, subjects_info)
      cash_book.price1 = journal.price_for_balance(subjects_info.subject1)
      subjects_info.balance1 += cash_book.price1
      cash_book.balance1 = subjects_info.balance1
      cash_book.price2 = 0
      cash_book.balance2 = subjects_info.balance2
    end

    def set_values_when_subject2_journal(cash_book, journal, subjects_info)
      cash_book.price1 = 0
      cash_book.balance1 = subjects_info.balance1
      cash_book.price2 = journal.price_for_balance(subjects_info.subject2)
      subjects_info.balance2 += cash_book.price2
      cash_book.balance2 = subjects_info.balance2
    end

    def set_partner_subject_info(cash_book, journal, subject)
      partner_subject = journal.subject_debit == subject ? journal.subject_credit : journal.subject_debit
      cash_book.code = partner_subject.code
      cash_book.name = partner_subject.name
    end
  end
end
