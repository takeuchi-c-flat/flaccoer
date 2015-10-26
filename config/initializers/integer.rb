class Integer
  def jpy_comma
    to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end
