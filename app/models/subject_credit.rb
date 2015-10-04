class SubjectCredit < Subject
  # 貸方用科目 (Subjectを貸借両方で使っています)
  self.table_name = 'subjects'

  def to_s
    name
  end
end
